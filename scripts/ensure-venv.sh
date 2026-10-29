#!/usr/bin/env bash
# Create, or repair, a docs-tooling venv at the repo root.
#
#   scripts/ensure-venv.sh docs        # .venv-docs: mkdocs site stack
#
# Uses $PYTHON if set, else python3 from PATH. The venv carries a stamp of the
# interpreter and requirement list it was built from, and is rebuilt whenever
# that stamp no longer matches or its interpreter does not run. That covers a
# venv built by another Python (e.g. inside a distrobox, then used on the host),
# an edited requirement list, a nixpkgs bump, and an interrupted install.
# Called by the flake's default shell hook.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "${1:-}" in
    docs)
        venv="$REPO/.venv-docs"
        reqs=(mkdocs-material "mkdocstrings-matlab==2.0.0" mkdocs-awesome-nav)
        ;;
    *)
        echo "usage: $0 docs" >&2
        exit 2
        ;;
esac

python="$(command -v "${PYTHON:-python3}")" || {
    echo "ensure-venv: ${PYTHON:-python3} not found on PATH" >&2
    exit 1
}
python="$(readlink -f "$python")"
want="$python ${reqs[*]}"
stamp="$venv/.cimtool-stamp"

if [ -f "$stamp" ] && [ "$(cat "$stamp")" = "$want" ] && "$venv/bin/python" -c '' 2>/dev/null; then
    exit 0
fi

echo "ensure-venv: building ${venv#"$REPO"/} with $python ..." >&2
rm -rf "$venv"
"$python" -m venv "$venv"
if ! "$venv/bin/pip" install --quiet --disable-pip-version-check "${reqs[@]}"; then
    rm -rf "$venv"
    echo "ensure-venv: pip install failed; removed ${venv#"$REPO"/} so the next run retries" >&2
    exit 1
fi

printf '%s\n' "$want" > "$stamp"
