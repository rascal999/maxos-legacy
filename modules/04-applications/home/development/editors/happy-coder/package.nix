{
  lib,
  buildNpmPackage,
  fetchurl,
}:

# happy-coder 1.1.9 — nixpkgs (26.05 and unstable) still ships 0.11.2.
# 0.11.2 drives codex through the legacy `codex mcp-server` bridge, which
# cannot answer codex >= 0.13x MCP tool approvals (elicitation) and hangs
# every turn that calls a happy MCP tool (slopus/happy#1134, #987).
# 1.1.9 uses `codex app-server` and answers `mcpServer/elicitation/request`
# correctly. The upstream repo builds with pnpm and publishes no npm
# lockfile, so package-lock.json here is generated from the published
# package.json (npm install --package-lock-only --legacy-peer-deps).
buildNpmPackage (finalAttrs: {
  pname = "happy-coder";
  version = "1.1.9";

  src = fetchurl {
    url = "https://registry.npmjs.org/happy-coder/-/happy-coder-${finalAttrs.version}.tgz";
    hash = "sha256-dvaFYNqgucwjL4oVdI6p/tt94vlTdhPfX2HAj5hAIko=";
  };

  sourceRoot = "package";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-bQgnrzFNpCJ0nW1phHTboLNiKj0BzwW787QIEHITcQo=";

  # dist/ ships prebuilt; do not re-run pkgroll. Postinstall unpacks bundled
  # ripgrep/difftastic from tools/, which already ship unpacked.
  dontNpmBuild = true;
  npmFlags = [
    "--ignore-scripts"
    "--legacy-peer-deps"
  ];

  meta = {
    description = "Happy Coder — mobile and web client for Codex and Claude Code";
    homepage = "https://github.com/slopus/happy";
    license = lib.licenses.mit;
    mainProgram = "happy";
  };
})