{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "yiffwtf-frontend-dev";

  # Minimal set of developer tools for this Node/Vue frontend
  buildInputs = with pkgs; [
    nodejs-16_x     # stable-ish Node that works with older webpack/babel setups
    yarn
    git
    gnumake
    python3
    pkgconfig
    gcc
    openssl
  ];

  # Useful environment settings and a lightweight auto-install helper.
  # Note: nix shells should avoid heavy side-effects, but a convenience
  # install when `node_modules` is missing is often helpful for development.
  shellHook = ''
    export NODE_ENV=development

    # Prefer yarn if lockfile present or yarn is installed; otherwise fall back to npm.
    if command -v yarn >/dev/null 2>&1; then
      PKG_MANAGER="yarn"
    else
      PKG_MANAGER="npm"
    fi

    # If using yarn but project has package-lock.json, prefer npm to avoid conflicts.
    if [ -f package-lock.json ] && [ -f yarn.lock ]; then
      echo "Both package-lock.json and yarn.lock are present. Defaulting to the available package manager: $PKG_MANAGER"
    fi

    # Auto-install only if node_modules is not present. This keeps repeated enters fast.
    if [ ! -d node_modules ]; then
      echo "No node_modules found in the project root."
      if [ -f yarn.lock ] && command -v yarn >/dev/null 2>&1; then
        echo "Installing dependencies with yarn..."
        yarn install || echo "yarn install failed. You can run 'yarn install' manually."
      elif [ -f package-lock.json ] || command -v npm >/dev/null 2>&1; then
        echo "Installing dependencies with npm..."
        npm install || echo "npm install failed. You can run 'npm install' manually."
      else
        echo "No package manager found. Please install yarn or npm."
      fi
    fi

    echo "Dev shell ready. Use 'yarn dev' or 'npm run dev' to start the dev server."
  '';
}
