{
  description = "CIMTOOL docs dev shell: Quarto + mkdocs + MATLAB Jupyter kernel";

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
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            quarto
            python311
            # C toolchain for pip packages with native extensions (tree-sitter, etc.)
            gcc
            gnumake
            pkg-config
            stdenv.cc.cc.lib
            pkgs.linux-pam
          ];

          shellHook = ''
            #alias matlab="distrobox enter matlab -- ~/MATLAB/2025b/bin/matlab -nodesktop"

            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"
            export LD_LIBRARY_PATH="${pkgs.linux-pam}/lib:$LD_LIBRARY_PATH"
            export PYTHONPATH="$PWD/.venv/bin/python"
            export QUARTO_PYTHON="$PWD/.venv/bin/python"

            export VENV_DIR="$PWD/.venv"
            if [ ! -d "$VENV_DIR" ]; then
              echo "Creating venv and installing docs dependencies..."
              python -m venv "$VENV_DIR"
              "$VENV_DIR/bin/pip" install \
                mkdocs-material \
                "mkdocstrings-matlab==2.0.0" \
                mkdocs-awesome-nav \
                jupyter
              #"$VENV_DIR/bin/python" -m mkernel install --user \
              #  || echo "Warning: MATLAB kernel registration failed — ensure 'matlab' is on PATH."
            fi

            source "$VENV_DIR/bin/activate"

            echo ""
            echo "CIMTOOL docs dev shell"
            echo "  quarto render docs/examples/acoustic_wave_1d.qmd   # single page"
            echo "  quarto render docs/                                  # all .qmd files"
            echo "  mkdocs serve                                         # preview site"

            quarto render docs/examples/acoustic_wave_1d.qmd --execute-dir=./

            distrobox enter matlab -- bash --norc
            export PATH=~/MATLAB/2025b/bin/:$PATH
            export LD_LIBRARY_PATH=:$LD_LIBRARY_PATH:~/MATLAB/2025b/bin/glnxa64/
          '';
        };
      }
    );
}
