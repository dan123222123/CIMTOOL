{
  description = "CIMTOOL docs dev shell: mkdocs site";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Native toolchain a few pip packages need to build C extensions
        # (tree-sitter for mkdocstrings-matlab, etc.) plus their runtime libs.
        commonPackages = with pkgs; [
          python311
          git
          gcc
          gnumake
          pkg-config
          stdenv.cc.cc.lib
          linux-pam
        ];

        # The venv lives at the repo root even when the shell is entered from a
        # subdirectory. The library path is only extended, never given an
        # empty entry (which the loader would read as the current directory).
        commonEnv = ''
          export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.linux-pam}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
          CIMTOOL_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
        '';
      in
      {
        devShells = {
          # ── Docs site (default): build/preview the mkdocs site. ──────────────
          # No MATLAB — mkdocstrings-matlab only *parses* src/ for
          # docstrings, so this shell works on any machine.
          default = pkgs.mkShell {
            packages = commonPackages;
            shellHook = commonEnv + ''
              if bash "$CIMTOOL_ROOT/scripts/ensure-venv.sh" docs; then
                source "$CIMTOOL_ROOT/.venv-docs/bin/activate"
              else
                echo "warning: .venv-docs is not ready; mkdocs is unavailable in this shell" >&2
              fi

              echo ""
              echo "CIMTOOL docs site shell (no MATLAB needed)"
              echo "  mkdocs serve    # live preview at http://localhost:8000"
              echo "  mkdocs build    # static site in ./site"
            '';
          };
        };
      }
    );
}
