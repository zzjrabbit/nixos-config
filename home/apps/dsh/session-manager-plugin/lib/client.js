window.__ModuleLoader__.load({
  id: "@raca/dsh-session-manager",
  factory: (require) => {
    var module = { exports: {} };
    var exports = module.exports;
    Object.defineProperty(exports, Symbol.toStringTag, { value: "Module" });

    const React = require("react");
    const h = React.createElement;
    const PLUGIN_ID = "@raca/dsh-session-manager";
    const LIST_URL = "/session-manager/api/sessions";
    const ACTION_URL = "/session-manager/api/action";

    const css = `
.dsm-page{width:100%;max-width:920px;color:var(--dsw-alias-label-primary);display:flex;flex-direction:column;gap:16px;padding-bottom:28px}
.dsm-heading{display:flex;flex-wrap:wrap;align-items:flex-start;justify-content:space-between;gap:12px}
.dsm-heading h2,.dsm-heading p{margin:0}.dsm-heading h2{font-size:20px;line-height:28px}.dsm-heading p{margin-top:4px;color:var(--dsw-alias-label-tertiary);font-size:13px;line-height:20px}
.dsm-toolbar{display:flex;flex-wrap:wrap;align-items:center;gap:8px}.dsm-tabs{display:flex;gap:4px;padding:3px;border-radius:9px;background:var(--dsw-alias-bg-layer-2)}
.dsm-tab,.dsm-button,.dsm-headerButton{border:1px solid transparent;color:var(--dsw-alias-label-primary);font:inherit;cursor:pointer;background:transparent;border-radius:7px}
.dsm-tab{padding:5px 11px;font-size:13px}.dsm-tab[data-active=true]{background:var(--dsw-alias-bg-layer-1);box-shadow:var(--dsw-shadow-lv1)}
.dsm-search{min-width:220px;flex:1;height:34px;border:1px solid var(--dsw-alias-border-l2);color:var(--dsw-alias-label-primary);background:var(--dsw-alias-bg-layer-1);border-radius:8px;outline:none;padding:0 11px;font:inherit;font-size:13px}
.dsm-search:focus{border-color:var(--dsw-alias-state-business-primary);box-shadow:0 0 0 2px color-mix(in srgb,var(--dsw-alias-state-business-primary) 18%,transparent)}
.dsm-status{margin:0;color:var(--dsw-alias-label-tertiary);font-size:13px;line-height:20px}.dsm-error{color:var(--dsw-alias-state-error-primary)}
.dsm-list{display:flex;flex-direction:column;gap:9px;margin:0;padding:0;list-style:none}.dsm-card{display:flex;align-items:center;justify-content:space-between;gap:14px;border:1px solid var(--dsw-alias-border-l2);background:var(--dsw-alias-bg-layer-3);border-radius:11px;padding:12px 14px}
.dsm-main{min-width:0;display:flex;flex:1;flex-direction:column;gap:5px}.dsm-titleRow{min-width:0;display:flex;flex-wrap:wrap;align-items:center;gap:7px}.dsm-title{min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:14px;font-weight:600}.dsm-id{overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:var(--dsw-alias-label-tertiary);font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:11px}
.dsm-meta{display:flex;flex-wrap:wrap;gap:5px 12px;color:var(--dsw-alias-label-tertiary);font-size:12px;line-height:18px}.dsm-path{max-width:540px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.dsm-badge{border-radius:999px;padding:1px 7px;background:var(--dsw-alias-bg-layer-2);color:var(--dsw-alias-label-secondary);font-size:11px;line-height:18px}.dsm-badgeWarn{color:var(--dsw-alias-state-warning-primary)}.dsm-badgeDanger{color:var(--dsw-alias-state-error-primary)}
.dsm-actions{display:flex;flex-shrink:0;flex-wrap:wrap;justify-content:flex-end;gap:7px}.dsm-button{border-color:var(--dsw-alias-border-l2);padding:5px 10px;font-size:12px}.dsm-button:hover,.dsm-headerButton:hover{background:var(--dsw-alias-bg-layer-2)}.dsm-button:disabled,.dsm-headerButton:disabled{cursor:not-allowed;opacity:.5}.dsm-danger{color:var(--dsw-alias-state-error-primary)}
.dsm-notice{border:1px solid var(--dsw-alias-border-l2);background:var(--dsw-alias-bg-layer-2);border-radius:9px;padding:9px 11px;color:var(--dsw-alias-label-secondary);font-size:12px;line-height:19px}
.dsm-headerButton{height:28px;border-color:var(--dsw-alias-border-l2);padding:0 9px;font-size:12px}
@media(max-width:700px){.dsm-card{align-items:stretch;flex-direction:column}.dsm-actions{justify-content:flex-start}.dsm-search{min-width:100%}}
`;
    const styleId = `${PLUGIN_ID}/style`;
    if (typeof document !== "undefined" && document.querySelector(`style[data-plugin-css=${JSON.stringify(styleId)}]`) === null) {
      const tag = document.createElement("style");
      tag.dataset.plugin = PLUGIN_ID;
      tag.dataset.pluginCss = styleId;
      tag.textContent = css;
      document.head.appendChild(tag);
    }

    async function decode(response) {
      const body = await response.json().catch(() => ({ ok: false, error: `HTTP ${response.status}` }));
      if (!response.ok || !body.ok) throw new Error(body.error || `HTTP ${response.status}`);
      return body.value;
    }

    async function loadSnapshot() {
      return decode(await fetch(LIST_URL, { headers: { accept: "application/json" }, cache: "no-store" }));
    }

    async function runAction(action, payload) {
      return decode(await fetch(ACTION_URL, {
        method: "POST",
        headers: { "content-type": "application/json", accept: "application/json" },
        body: JSON.stringify({ action, ...payload }),
      }));
    }

    function formatDate(value) {
      if (value === null || value === undefined) return "未知时间";
      const date = new Date(value);
      return Number.isNaN(date.getTime()) ? String(value) : date.toLocaleString();
    }

    function sessionName(item) {
      return item.title || "未命名会话";
    }

    function matches(item, query) {
      if (query.length === 0) return true;
      const haystack = [item.title, item.sessionId, item.cwd, item.workspace?.title, item.origin]
        .filter(Boolean)
        .join("\n")
        .toLocaleLowerCase();
      return haystack.includes(query);
    }

    function Badge({ children, tone }) {
      const className = tone === "danger" ? "dsm-badge dsm-badgeDanger" : tone === "warn" ? "dsm-badge dsm-badgeWarn" : "dsm-badge";
      return h("span", { className }, children);
    }

    function Button({ children, danger, disabled, onClick, title }) {
      return h("button", {
        type: "button",
        className: danger ? "dsm-button dsm-danger" : "dsm-button",
        disabled,
        onClick,
        title,
      }, children);
    }

    function SessionCard({ item, busy, act }) {
      const deleting = busy === item.sessionId;
      const askArchive = () => act("archive", { sessionId: item.sessionId });
      const askUnarchive = () => act("unarchive", { sessionId: item.sessionId });
      const askDelete = () => {
        const mode = "该会话会立即归档，并在下次启动 Harness 时安全移入回收站；其子代理会话会一并处理。";
        if (window.confirm(`${mode}\n\n会话：${sessionName(item)}\n${item.sessionId}`)) {
          act("delete", { sessionId: item.sessionId });
        }
      };
      const cancelDelete = () => act("cancel-delete", { sessionId: item.sessionId });
      return h("li", { className: "dsm-card" },
        h("div", { className: "dsm-main" },
          h("div", { className: "dsm-titleRow" },
            h("span", { className: "dsm-title", title: sessionName(item) }, sessionName(item)),
            item.archived ? h(Badge, null, "已归档") : null,
            item.running ? h(Badge, { tone: "warn" }, "运行中") : item.live ? h(Badge, null, "已加载") : null,
            item.pendingDelete ? h(Badge, { tone: "danger" }, "待删除") : null,
            item.origin === "subagent" ? h(Badge, null, "子代理") : null,
          ),
          h("div", { className: "dsm-id", title: item.sessionId }, item.sessionId),
          h("div", { className: "dsm-meta" },
            h("span", null, formatDate(item.createdAt)),
            item.workspace ? h("span", null, `工作区：${item.workspace.title}`) : h("span", null, "未分组"),
            item.cwd ? h("span", { className: "dsm-path", title: item.cwd }, item.cwd) : null,
          ),
        ),
        h("div", { className: "dsm-actions" },
          item.pendingDelete
            ? h(Button, { disabled: deleting, onClick: cancelDelete }, deleting ? "处理中…" : "取消待删除")
            : item.archived
              ? h(Button, { disabled: deleting, onClick: askUnarchive }, deleting ? "处理中…" : "恢复显示")
              : h(Button, { disabled: deleting, onClick: askArchive }, deleting ? "处理中…" : "归档"),
          h(Button, {
            danger: true,
            disabled: deleting,
            onClick: askDelete,
            title: "归档后在下次启动时移入回收站",
          }, deleting ? "处理中…" : "删除"),
        ),
      );
    }

    function TrashCard({ item, busy, act }) {
      const deleting = busy === item.trashId;
      const restore = () => act("restore", { trashId: item.trashId });
      const purge = () => {
        if (window.confirm(`永久删除后无法恢复。\n\n会话：${item.title || item.sessionId}\n${item.sessionId}`)) {
          act("purge", { trashId: item.trashId });
        }
      };
      return h("li", { className: "dsm-card" },
        h("div", { className: "dsm-main" },
          h("div", { className: "dsm-titleRow" },
            h("span", { className: "dsm-title" }, item.title || "未命名会话"),
            h(Badge, { tone: "danger" }, "回收站"),
            item.origin === "subagent" ? h(Badge, null, "子代理") : null,
          ),
          h("div", { className: "dsm-id", title: item.sessionId }, item.sessionId),
          h("div", { className: "dsm-meta" },
            h("span", null, `删除于 ${formatDate(item.deletedAt)}`),
            item.cwd ? h("span", { className: "dsm-path", title: item.cwd }, item.cwd) : null,
          ),
        ),
        h("div", { className: "dsm-actions" },
          h(Button, { disabled: deleting, onClick: restore }, deleting ? "处理中…" : "恢复"),
          h(Button, { danger: true, disabled: deleting, onClick: purge }, deleting ? "处理中…" : "永久删除"),
        ),
      );
    }

    function SessionManagerPage() {
      const [tab, setTab] = React.useState("sessions");
      const [query, setQuery] = React.useState("");
      const [state, setState] = React.useState({ phase: "loading" });
      const [busy, setBusy] = React.useState(null);
      const [notice, setNotice] = React.useState("");

      const refresh = React.useCallback(() => {
        setState({ phase: "loading" });
        loadSnapshot().then(
          (data) => setState({ phase: "ready", data }),
          (error) => setState({ phase: "error", error: error.message }),
        );
      }, []);

      React.useEffect(refresh, [refresh]);

      const act = React.useCallback(async (action, payload) => {
        const key = payload.sessionId || payload.trashId || action;
        setBusy(key);
        setNotice("");
        try {
          const value = await runAction(action, payload);
          if (value.result?.scheduled) {
            setNotice("会话已归档，并将在下次启动 DeepSeek Harness 时移入回收站。");
          }
          if (value.result?.reload) {
            window.location.reload();
            return;
          }
          setState({ phase: "ready", data: value.snapshot });
        } catch (error) {
          setNotice(`操作失败：${error.message}`);
        } finally {
          setBusy(null);
        }
      }, []);

      const normalized = query.trim().toLocaleLowerCase();
      const sessions = state.phase === "ready" ? state.data.sessions.filter((item) => matches(item, normalized)) : [];
      const trash = state.phase === "ready" ? state.data.trash.filter((item) => matches(item, normalized)) : [];
      const countSessions = state.phase === "ready" ? state.data.sessions.length : 0;
      const countTrash = state.phase === "ready" ? state.data.trash.length : 0;
      const rows = tab === "sessions" ? sessions : trash;

      return h("section", { className: "dsm-page" },
        h("div", { className: "dsm-heading" },
          h("div", null,
            h("h2", null, "会话管理"),
            h("p", null, "归档会话、计划删除仍在运行的会话，以及从回收站恢复或永久清除会话。"),
          ),
          h(Button, { disabled: state.phase === "loading", onClick: refresh }, "刷新"),
        ),
        h("div", { className: "dsm-toolbar" },
          h("div", { className: "dsm-tabs", role: "tablist" },
            h("button", { type: "button", className: "dsm-tab", "data-active": tab === "sessions", onClick: () => setTab("sessions") }, `会话 ${countSessions}`),
            h("button", { type: "button", className: "dsm-tab", "data-active": tab === "trash", onClick: () => setTab("trash") }, `回收站 ${countTrash}`),
          ),
          h("input", {
            type: "search",
            className: "dsm-search",
            value: query,
            placeholder: "搜索标题、ID、路径或工作区",
            onChange: (event) => setQuery(event.currentTarget.value),
          }),
        ),
        notice ? h("div", { className: notice.startsWith("操作失败") ? "dsm-notice dsm-error" : "dsm-notice", role: "status" }, notice) : null,
        state.phase === "loading" ? h("p", { className: "dsm-status" }, "正在读取会话…") : null,
        state.phase === "error" ? h("p", { className: "dsm-status dsm-error", role: "alert" }, `读取失败：${state.error}`) : null,
        state.phase === "ready" && rows.length === 0 ? h("p", { className: "dsm-status" }, normalized ? "没有匹配项。" : tab === "sessions" ? "没有持久化会话。" : "回收站为空。") : null,
        state.phase === "ready" ? h("ul", { className: "dsm-list" },
          tab === "sessions"
            ? rows.map((item) => h(SessionCard, { key: item.sessionId, item, busy, act }))
            : rows.map((item) => h(TrashCard, { key: item.trashId, item, busy, act })),
        ) : null,
        tab === "sessions" ? h("div", { className: "dsm-notice" }, "为避免绕过 Harness 的会话写入与缓存生命周期，删除操作不会在当前进程内直接移动日志：会话会先归档，并在下次启动 Harness、尚未恢复会话之前安全移入回收站。删除父会话时，其子代理会话会一并处理。") : null,
      );
    }

    function ArchiveCurrentAction({ sessionId }) {
      const [busy, setBusy] = React.useState(false);
      const archive = async () => {
        if (!window.confirm("归档当前会话？归档后可在“设置 → 会话管理”中恢复显示或删除。")) return;
        setBusy(true);
        try {
          await runAction("archive", { sessionId });
        } catch (error) {
          window.alert(`归档失败：${error.message}`);
          setBusy(false);
        }
      };
      return h("button", {
        type: "button",
        className: "dsm-headerButton",
        disabled: busy,
        onClick: archive,
        title: "归档当前会话",
      }, busy ? "归档中…" : "归档");
    }

    const inject = ["slots"];
    function apply(ctx) {
      ctx.slots.inject("settings.section", () => ctx.slots.register({
        name: "settings.section",
        id: "session-manager",
        order: 35,
        label: "会话管理",
      }, SessionManagerPage));
      ctx.slots.inject("conversation.session.header.actions", () => ctx.slots.register({
        name: "conversation.session.header.actions",
        id: "session-manager-archive",
        order: 80,
        label: "归档",
      }, ArchiveCurrentAction));
    }

    exports.apply = apply;
    exports.inject = inject;
    return module.exports;
  }
});
