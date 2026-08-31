import { mkdir, readFile, readdir, rename, rm, stat, writeFile } from 'node:fs/promises'
import { basename, dirname, join, resolve } from 'node:path'

export const inject = [
  'webServer',
  'sessionPersistence',
  'workspaceRegistry',
  'agents',
  'sessions',
]

const API_LIST = '/session-manager/api/sessions'
const API_ACTION = '/session-manager/api/action'
const MANIFEST = '.dsh-session-trash.json'
const MAX_BODY_BYTES = 32 * 1024

function sendJson(res, status, value) {
  const body = JSON.stringify(value)
  res.statusCode = status
  res.setHeader('content-type', 'application/json; charset=utf-8')
  res.setHeader('cache-control', 'no-store')
  res.setHeader('content-length', Buffer.byteLength(body))
  res.end(body)
}

function errorMessage(error) {
  return error instanceof Error ? error.message : String(error)
}

function assertSameOrigin(req) {
  const origin = req.headers.origin
  const host = req.headers.host
  if (origin === undefined || host === undefined) return
  let originHost
  try {
    originHost = new URL(origin).host
  } catch {
    throw new Error('invalid request origin')
  }
  if (originHost !== host) throw new Error('cross-origin session-manager request rejected')
}

async function readJson(req) {
  const chunks = []
  let size = 0
  for await (const chunk of req) {
    size += chunk.length
    if (size > MAX_BODY_BYTES) throw new Error('request body is too large')
    chunks.push(chunk)
  }
  if (chunks.length === 0) return {}
  const value = JSON.parse(Buffer.concat(chunks).toString('utf8'))
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    throw new Error('request body must be a JSON object')
  }
  return value
}

function requireString(value, name) {
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new Error(`${name} must be a non-empty string`)
  }
  return value
}

function latestTitle(events) {
  for (let index = events.length - 1; index >= 0; index -= 1) {
    const event = events[index]
    if (event?.type === 'session/title' && typeof event.data?.title === 'string') {
      return event.data.title
    }
  }
  return null
}

async function pathExists(path) {
  try {
    await stat(path)
    return true
  } catch (error) {
    if (error?.code === 'ENOENT') return false
    throw error
  }
}

async function readJsonFile(path, fallback) {
  try {
    return JSON.parse(await readFile(path, 'utf8'))
  } catch (error) {
    if (error?.code === 'ENOENT') return fallback
    throw error
  }
}

async function writeJsonAtomic(path, value) {
  await mkdir(dirname(path), { recursive: true })
  const temp = `${path}.tmp-${process.pid}-${Date.now()}`
  await writeFile(temp, `${JSON.stringify(value, null, 2)}\n`, { encoding: 'utf8', mode: 0o600 })
  await rename(temp, path)
}

function assertTrashChild(trashRoot, candidate) {
  const root = resolve(trashRoot)
  const path = resolve(candidate)
  if (path === root || !path.startsWith(`${root}/`)) {
    throw new Error('trash entry escaped the configured trash root')
  }
  return path
}

export async function apply(ctx, config = {}) {
  const trashRoot = requireString(config.trashRoot, 'config.trashRoot')
  const pendingPath = requireString(config.pendingPath, 'config.pendingPath')
  const logger = ctx.logger('session-manager')

  async function pendingEntries() {
    const value = await readJsonFile(pendingPath, { entries: [] })
    const source = Array.isArray(value?.entries)
      ? value.entries
      : Array.isArray(value?.sessionIds)
        ? value.sessionIds.map((sessionId) => ({ sessionId, title: null }))
        : []
    const entries = []
    const seen = new Set()
    for (const candidate of source) {
      const sessionId = typeof candidate === 'string' ? candidate : candidate?.sessionId
      if (typeof sessionId !== 'string' || sessionId.length === 0 || seen.has(sessionId)) continue
      seen.add(sessionId)
      entries.push({
        sessionId,
        title: typeof candidate?.title === 'string' ? candidate.title : null,
      })
    }
    return entries
  }

  async function setPendingEntries(entries) {
    const unique = []
    const seen = new Set()
    for (const entry of entries) {
      if (seen.has(entry.sessionId)) continue
      seen.add(entry.sessionId)
      unique.push({ sessionId: entry.sessionId, title: entry.title ?? null })
    }
    await writeJsonAtomic(pendingPath, { entries: unique })
    return unique
  }

  async function removeArchived(ids) {
    const targets = new Set(ids)
    if (targets.size === 0) return
    const registry = ctx.workspaceRegistry
    // DSH 0.1.1-rc.2 has no public unarchive API. Its own archive method is
    // serialized through these ordinary (TypeScript-private) methods; using the
    // same write path preserves domain/changed notifications and durability.
    if (
      typeof registry.enqueueOperation !== 'function'
      || typeof registry.requireState !== 'function'
      || typeof registry.setState !== 'function'
    ) {
      throw new Error('this DSH version does not expose the workspace state path required for unarchive')
    }
    await registry.enqueueOperation(async () => {
      const state = registry.requireState()
      const archivedSessionIds = state.archivedSessionIds.filter((id) => !targets.has(id))
      if (archivedSessionIds.length === state.archivedSessionIds.length) return
      await registry.setState({ ...state, archivedSessionIds })
    })
  }

  async function sessionMetas() {
    return await ctx.sessionPersistence.list()
  }

  function descendantsOf(rootId, metas) {
    const result = new Set([rootId])
    let changed = true
    while (changed) {
      changed = false
      for (const meta of metas) {
        if (meta.parentSession !== undefined && result.has(meta.parentSession) && !result.has(meta.id)) {
          result.add(meta.id)
          changed = true
        }
      }
    }
    return [...result]
  }

  async function listTrash() {
    let names
    try {
      names = await readdir(trashRoot)
    } catch (error) {
      if (error?.code === 'ENOENT') return []
      throw error
    }
    const entries = []
    for (const name of names) {
      const trashDir = assertTrashChild(trashRoot, join(trashRoot, name))
      try {
        const manifest = JSON.parse(await readFile(join(trashDir, MANIFEST), 'utf8'))
        if (typeof manifest?.sessionId !== 'string' || typeof manifest?.originalDir !== 'string') continue
        entries.push({
          trashId: name,
          sessionId: manifest.sessionId,
          title: typeof manifest.title === 'string' ? manifest.title : null,
          cwd: typeof manifest.cwd === 'string' ? manifest.cwd : null,
          createdAt: manifest.createdAt ?? null,
          deletedAt: manifest.deletedAt ?? null,
          origin: manifest.origin ?? null,
          parentSession: manifest.parentSession ?? null,
        })
      } catch (error) {
        logger.warn(`ignoring unreadable trash entry ${trashDir}: ${errorMessage(error)}`)
      }
    }
    entries.sort((left, right) => Number(right.deletedAt ?? 0) - Number(left.deletedAt ?? 0))
    return entries
  }

  async function inspectTitle(meta) {
    const live = ctx.sessions.get(meta.id)
    if (live !== undefined) return latestTitle(live.events)
    try {
      return latestTitle((await ctx.sessionPersistence.inspect(meta.id)).events)
    } catch (error) {
      logger.warn(`failed to inspect title for ${meta.id}: ${errorMessage(error)}`)
      return null
    }
  }

  async function snapshot() {
    const [metas, pending, trash] = await Promise.all([
      sessionMetas(),
      pendingEntries(),
      listTrash(),
    ])
    const pendingSet = new Set(pending.map((entry) => entry.sessionId))
    const archivedSet = new Set(ctx.workspaceRegistry.archivedSessionIds)
    const workspaces = ctx.workspaceRegistry.list()
    const rows = []
    for (const meta of metas) {
      const agent = ctx.agents.get(meta.id)
      const workspace = workspaces.find((candidate) => candidate.sessionIds.includes(meta.id))
      rows.push({
        sessionId: meta.id,
        title: await inspectTitle(meta),
        cwd: meta.cwd ?? null,
        createdAt: meta.createdAt,
        parentSession: meta.parentSession ?? null,
        origin: meta.origin ?? null,
        archived: archivedSet.has(meta.id),
        pendingDelete: pendingSet.has(meta.id),
        live: agent !== undefined,
        running: agent?.status === 'running',
        workspace: workspace === undefined ? null : { id: workspace.id, title: workspace.title },
      })
    }
    rows.sort((left, right) => Number(right.createdAt ?? 0) - Number(left.createdAt ?? 0))
    return { sessions: rows, trash }
  }

  async function softDeleteOne(meta, title = null) {
    if (ctx.agents.get(meta.id) !== undefined || ctx.sessions.get(meta.id) !== undefined) {
      throw new Error(`session "${meta.id}" is live and can only be deleted after the next Harness restart`)
    }
    const location = ctx.sessionPersistence.locate(meta)
    if (location === undefined) throw new Error(`session "${meta.id}" has no independently removable artifact`)
    const sourceDir = dirname(location.path)
    if (basename(sourceDir) !== meta.id) {
      throw new Error(`refusing to delete unexpected session directory "${sourceDir}"`)
    }
    const workspaces = ctx.workspaceRegistry.list()
    const workspaceIds = workspaces
      .filter((workspace) => workspace.sessionIds.includes(meta.id))
      .map((workspace) => workspace.id)
    const trashId = `${meta.id}-${Date.now()}`
    const trashDir = assertTrashChild(trashRoot, join(trashRoot, trashId))
    await mkdir(trashRoot, { recursive: true })
    await rename(sourceDir, trashDir)
    const manifest = {
      version: 1,
      sessionId: meta.id,
      title,
      cwd: meta.cwd ?? null,
      createdAt: meta.createdAt,
      parentSession: meta.parentSession ?? null,
      origin: meta.origin ?? null,
      originalDir: sourceDir,
      workspaceIds,
      deletedAt: Date.now(),
    }
    await writeFile(join(trashDir, MANIFEST), `${JSON.stringify(manifest, null, 2)}\n`, {
      encoding: 'utf8',
      mode: 0o600,
    })
    for (const workspaceId of workspaceIds) {
      const workspace = ctx.workspaceRegistry.get(workspaceId)
      if (workspace !== undefined) await workspace.detachSession(meta.id)
    }
    await removeArchived([meta.id])
    return { trashId, sessionId: meta.id }
  }

  async function deleteSessions(rootId) {
    const metas = await sessionMetas()
    const byId = new Map(metas.map((meta) => [meta.id, meta]))
    if (!byId.has(rootId)) throw new Error(`unknown persisted session "${rootId}"`)
    const ids = descendantsOf(rootId, metas)
    const pending = await pendingEntries()
    const pendingById = new Map(pending.map((entry) => [entry.sessionId, entry]))
    for (const id of ids) {
      await ctx.workspaceRegistry.archiveSession(id)
      const meta = byId.get(id)
      pendingById.set(id, {
        sessionId: id,
        title: meta === undefined ? null : await inspectTitle(meta),
      })
    }
    await setPendingEntries([...pendingById.values()])
    const live = ids.filter((id) => ctx.agents.get(id) !== undefined || ctx.sessions.get(id) !== undefined)
    return { scheduled: true, sessionIds: ids, liveSessionIds: live, reload: false }
  }

  async function cancelDelete(rootId) {
    const metas = await sessionMetas()
    const ids = descendantsOf(rootId, metas)
    const pending = await pendingEntries()
    await setPendingEntries(pending.filter((entry) => !ids.includes(entry.sessionId)))
    return { sessionIds: ids }
  }

  async function restoreTrash(trashId) {
    const trashDir = assertTrashChild(trashRoot, join(trashRoot, requireString(trashId, 'trashId')))
    const manifest = JSON.parse(await readFile(join(trashDir, MANIFEST), 'utf8'))
    const originalDir = requireString(manifest.originalDir, 'trash manifest originalDir')
    if (await pathExists(originalDir)) throw new Error(`cannot restore because "${originalDir}" already exists`)
    await mkdir(dirname(originalDir), { recursive: true })
    await rename(trashDir, originalDir)
    await rm(join(originalDir, MANIFEST), { force: true })
    await removeArchived([manifest.sessionId])
    for (const workspaceId of Array.isArray(manifest.workspaceIds) ? manifest.workspaceIds : []) {
      const workspace = ctx.workspaceRegistry.get(workspaceId)
      if (workspace === undefined) continue
      try {
        await workspace.attachSession(manifest.sessionId)
      } catch (error) {
        logger.warn(`restored ${manifest.sessionId} but could not reattach workspace ${workspaceId}: ${errorMessage(error)}`)
      }
    }
    return { sessionId: manifest.sessionId, reload: true }
  }

  async function purgeTrash(trashId) {
    const trashDir = assertTrashChild(trashRoot, join(trashRoot, requireString(trashId, 'trashId')))
    const manifest = JSON.parse(await readFile(join(trashDir, MANIFEST), 'utf8'))
    await rm(trashDir, { recursive: true, force: false })
    return { sessionId: manifest.sessionId, reload: false }
  }

  async function processPendingDeletes() {
    const pending = await pendingEntries()
    if (pending.length === 0) return
    const metas = await sessionMetas()
    const byId = new Map(metas.map((meta) => [meta.id, meta]))
    const remaining = []
    for (const entry of pending) {
      const meta = byId.get(entry.sessionId)
      if (meta === undefined) continue
      if (ctx.agents.get(entry.sessionId) !== undefined || ctx.sessions.get(entry.sessionId) !== undefined) {
        remaining.push(entry)
        continue
      }
      try {
        await softDeleteOne(meta, entry.title)
      } catch (error) {
        remaining.push(entry)
        logger.warn(`pending deletion failed for ${entry.sessionId}: ${errorMessage(error)}`)
      }
    }
    await setPendingEntries(remaining)
  }

  try {
    await processPendingDeletes()
  } catch (error) {
    logger.warn(`pending deletion startup pass failed: ${errorMessage(error)}`)
  }

  ctx.effect(() => ctx.webServer.register({
    kind: 'exact',
    path: API_LIST,
    async handler(req, res) {
      try {
        assertSameOrigin(req)
        if (req.method !== 'GET') {
          sendJson(res, 405, { ok: false, error: 'method not allowed' })
          return
        }
        sendJson(res, 200, { ok: true, value: await snapshot() })
      } catch (error) {
        sendJson(res, 400, { ok: false, error: errorMessage(error) })
      }
    },
  }), 'session-manager: list route')

  ctx.effect(() => ctx.webServer.register({
    kind: 'exact',
    path: API_ACTION,
    async handler(req, res) {
      try {
        assertSameOrigin(req)
        if (req.method !== 'POST') {
          sendJson(res, 405, { ok: false, error: 'method not allowed' })
          return
        }
        const body = await readJson(req)
        let result
        switch (body.action) {
          case 'archive':
            await ctx.workspaceRegistry.archiveSession(requireString(body.sessionId, 'sessionId'))
            result = { reload: false }
            break
          case 'unarchive':
            await removeArchived([requireString(body.sessionId, 'sessionId')])
            result = { reload: false }
            break
          case 'delete':
            result = await deleteSessions(requireString(body.sessionId, 'sessionId'))
            break
          case 'cancel-delete':
            result = await cancelDelete(requireString(body.sessionId, 'sessionId'))
            break
          case 'restore':
            result = await restoreTrash(body.trashId)
            break
          case 'purge':
            result = await purgeTrash(body.trashId)
            break
          default:
            throw new Error('unknown session-manager action')
        }
        sendJson(res, 200, { ok: true, value: { result, snapshot: await snapshot() } })
      } catch (error) {
        sendJson(res, 400, { ok: false, error: errorMessage(error) })
      }
    },
  }), 'session-manager: action route')
}
