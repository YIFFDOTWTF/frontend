{
  description = "flake providing a development shell for the yiffwtf frontend (Vue + webpack)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        description = "Dev shell for the frontend (system: ${system})";

        devShells.default = pkgs.mkShell {
          name = "yiffwtf-frontend-dev";

          # Node selection: 18.x is conservative and supported for older webpack/babel setups.
          buildInputs = with pkgs; [
            nodejs-18_x
            yarn
            git
            gnumake
            python3
            pkg-config
            gcc
            openssl
          ];

          shellHook = ''
            export NODE_ENV=development

            # Pick package manager: prefer yarn if available.
            if command -v yarn >/dev/null 2>&1; then
              PKG_MANAGER="yarn"
            else
              PKG_MANAGER="npm"
            fi

            # Warn if both lockfiles exist
            if [ -f package-lock.json ] && [ -f yarn.lock ]; then
              echo "Warning: both package-lock.json and yarn.lock are present. Choose one to avoid conflicts."
            fi

            # Auto-install only when node_modules is absent (convenience).
            if [ -f package.json ] && [ ! -d node_modules ]; then
              echo "No node_modules found. Installing JS dependencies with $PKG_MANAGER..."
              if [ -f yarn.lock ] && command -v yarn >/dev/null 2>&1; then
                yarn install || echo "yarn install failed; run 'yarn install' manually."
              elif command -v npm >/dev/null 2>&1; then
                npm install || echo "npm install failed; run 'npm install' manually."
              else
                echo "No package manager found inside the shell. Ensure yarn or npm is available."
              fi
            fi

            echo "Dev shell ready. Run 'yarn dev' or 'npm run dev' to start the dev server."
          '';
        };
      }
    );
}
