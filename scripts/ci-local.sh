#!/usr/bin/env bash
#
# Local mirror of .github/workflows/ci.yml so CI failures can be caught before
# pushing to main. Runs the same two jobs the GitHub workflow runs:
#
#   ./scripts/ci-local.sh test    # Job 1: MATLAB smoke check (exactly as CI runs it)
#   ./scripts/ci-local.sh docs    # Job 2: mkdocs static build (build only, no deploy)
#   ./scripts/ci-local.sh all     # both (default)
#
# How this maps to the real CI:
#   - test job   -> matlab-actions/run-command on a GitHub runner.
#                   Here MATLAB runs via the host 'matlab' wrapper, which
#                   forwards into the 'matlab' distrobox. Launch is slow
#                   (~30-90s), so the call is timeout-guarded.
#                   NOTE: like CI, this only loads src/ and cd's into tests/ —
#                   it does not execute the test scripts yet. Use `realtest`
#                   below to actually run them.
#   - deploy job -> pip install mkdocs-* + `mkdocs gh-deploy --force`.
#                   The build is pure Python: mkdocstrings-matlab parses .m
#                   files statically (no MATLAB engine), so it runs fully on
#                   the host in a throwaway .ci-venv. We `build` instead of
#                   `gh-deploy` to avoid pushing to the gh-pages branch.
#
# Not covered here: the Quarto/mkernel "reactive docs" pipeline. That lives on
# the doc_overhaul branch and needs a MATLAB license the hosted runners don't
# grant to a standalone engine, so it is intentionally off main.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

VENV="$ROOT/.ci-venv"
SITE="$ROOT/.ci-site"

job_test() {
  echo "== Job 1: test (MATLAB smoke check, as CI runs it) =="
  if ! command -v matlab >/dev/null 2>&1; then
    echo "  ERROR: 'matlab' wrapper not on PATH (expected the distrobox forwarder)." >&2
    return 1
  fi
  timeout 200 matlab -batch "addpath(genpath('src')); cd('tests');"
  echo "  test: OK"
}

job_realtest() {
  # Not part of CI yet — actually executes the test scripts documented in
  # CLAUDE.md. Kept separate because these may need NLEVP / a display and can
  # fail for reasons the CI smoke check never exercises.
  echo "== (extra) run the real test scripts =="
  timeout 400 matlab -batch "addpath(genpath('src')); cd('tests'); \
    testCIMEigensystemRealization; \
    hankel_exactVquadrature; mploewner_exactVquadrature; sploewner_exactVquadrature;"
  echo "  realtest: OK"
}

ensure_venv() {
  if [ ! -x "$VENV/bin/mkdocs" ]; then
    echo "  creating docs venv ($VENV) ..."
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install --quiet --upgrade pip
    "$VENV/bin/pip" install --quiet \
      mkdocs-material \
      "mkdocstrings-matlab==2.0.1" \
      mkdocs-awesome-nav
  fi
}

job_docs() {
  echo "== Job 2: docs (mkdocs build, no deploy) =="
  ensure_venv
  "$VENV/bin/mkdocs" build --clean --site-dir "$SITE"
  echo "  docs: OK -> $SITE"
}

case "${1:-all}" in
  test)     job_test ;;
  realtest) job_realtest ;;
  docs)     job_docs ;;
  all)      job_test; job_docs ;;
  *) echo "usage: $0 {test|realtest|docs|all}" >&2; exit 2 ;;
esac
