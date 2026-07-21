set -euo pipefail

usage() {
  cat <<'EOF'
Manage one-value SOPS secrets in this NixOS repository.

Usage:
  sops-secret add NAME [--from-file FILE]
  sops-secret edit NAME
  sops-secret remove NAME [--yes]
  sops-secret list

NAME must start with a lowercase letter and contain only lowercase letters,
digits, and underscores.

Without --from-file, "add" reads a hidden value interactively. When standard
input is redirected, it reads the value from standard input instead.
EOF
}

die() {
  echo "sops-secret: $*" >&2
  exit 1
}

validate_name() {
  [[ $1 =~ ^[a-z][a-z0-9_]*$ ]] \
    || die "invalid name '$1' (expected [a-z][a-z0-9_]*)"
}

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) \
  || die "run this command inside the configuration repository"
[[ -f "$repo_root/.sops.yaml" ]] \
  || die "cannot find .sops.yaml at repository root"

secrets_dir="$repo_root/secrets"
mkdir -p "$secrets_dir"
umask 077

command=${1:-}
case "$command" in
  add)
    [[ $# -eq 2 || $# -eq 4 ]] || { usage >&2; exit 2; }
    name=$2
    validate_name "$name"
    relative_file="secrets/$name.yaml"
    secret_file="$repo_root/$relative_file"
    [[ ! -e "$secret_file" ]] || die "secret '$name' already exists; use 'edit'"

    source_file=
    if [[ $# -eq 4 ]]; then
      [[ $3 == --from-file ]] || { usage >&2; exit 2; }
      source_file=$4
      [[ -f "$source_file" ]] || die "input file does not exist: $source_file"
    fi

    temporary_file=$(mktemp "$secrets_dir/.$name.yaml.XXXXXX")
    cleanup() {
      rm -f -- "$temporary_file"
    }
    trap cleanup EXIT

    encrypt() {
      jq -Rs --arg key "$name" '{($key): .}' \
        | sops --config "$repo_root/.sops.yaml" --encrypt \
            --filename-override "$relative_file" \
            --input-type json \
            --output-type yaml \
            /dev/stdin > "$temporary_file"
    }

    if [[ -n "$source_file" ]]; then
      encrypt < "$source_file"
    elif [[ -t 0 ]]; then
      read -r -s -p "Value for $name: " value
      echo >&2
      read -r -s -p "Repeat value: " repeated_value
      echo >&2
      [[ $value == "$repeated_value" ]] || die "values do not match"
      [[ -n $value ]] || die "refusing to create an empty secret"
      printf %s "$value" | encrypt
      unset value repeated_value
    else
      encrypt
    fi

    mv -- "$temporary_file" "$secret_file"
    trap - EXIT
    git -C "$repo_root" add -- "$relative_file"
    echo "Added $relative_file and staged it for commit."
    ;;

  edit)
    [[ $# -eq 2 ]] || { usage >&2; exit 2; }
    name=$2
    validate_name "$name"
    relative_file="secrets/$name.yaml"
    secret_file="$repo_root/$relative_file"
    [[ -f "$secret_file" ]] || die "secret '$name' does not exist"
    sops "$secret_file"
    git -C "$repo_root" add -- "$relative_file"
    echo "Updated $relative_file and staged it for commit."
    ;;

  remove|delete|rm)
    [[ $# -eq 2 || $# -eq 3 ]] || { usage >&2; exit 2; }
    name=$2
    validate_name "$name"
    relative_file="secrets/$name.yaml"
    secret_file="$repo_root/$relative_file"
    [[ -f "$secret_file" ]] || die "secret '$name' does not exist"

    confirmed=false
    if [[ ${3:-} == --yes ]]; then
      confirmed=true
    elif [[ $# -eq 3 ]]; then
      usage >&2
      exit 2
    elif [[ -t 0 ]]; then
      read -r -p "Delete secret '$name'? [y/N] " answer
      [[ $answer == y || $answer == Y || $answer == yes || $answer == YES ]] \
        && confirmed=true
    fi
    [[ $confirmed == true ]] || die "not removed (use --yes in a non-interactive script)"

    rm -- "$secret_file"
    git -C "$repo_root" add -u -- "$relative_file"
    echo "Removed $relative_file and staged the deletion."
    ;;

  list)
    [[ $# -eq 1 ]] || { usage >&2; exit 2; }
    found=false
    for secret_file in "$secrets_dir"/*.yaml; do
      [[ -e "$secret_file" ]] || continue
      name=$(basename "$secret_file" .yaml)
      validate_name "$name"
      printf '%s\n' "$name"
      found=true
    done
    [[ $found == true ]] || echo "No secrets found."
    ;;

  -h|--help|help)
    usage
    ;;

  *)
    usage >&2
    exit 2
    ;;
esac
