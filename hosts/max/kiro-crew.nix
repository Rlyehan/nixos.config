# kiro-crew.nix — Home-manager module for KiroCrew dashboard customizations
#
# What this does:
#   1. Deploys custom global steering files (python-conventions, quality-gates)
#   2. Creates skill symlinks (databricks from ~/.claude/skills, clickhouse from ~/.clickhouse-agent-skills)
#   3. Ensures ~/.mcp-auth is NOT managed (it's runtime OAuth state, must persist imperatively)
#
# NOTE: ~/.kiro/agents/*.json are NOT managed here. home-manager deploys files as
# Nix-store symlinks, and the KiroCrew gateway fences symlinked agent specs (safety),
# which makes the agent policy "unreadable" and blocks history/session/skill tools.
# So agent JSONs (incl. kirocrew.json, which KiroCrew regenerates anyway) stay as
# plain imperative files. MCP server additions to kirocrew.json must be re-applied
# after AppImage upgrades — see the post-upgrade script below.
#
# Usage:
#   imports = [ ./kiro-crew.nix ];
#
{ config, lib, pkgs, ... }:

let
  homeDir = config.home.homeDirectory;

  # Steering files — auto-loaded into every session
  steeringFiles = {
    ".kiro/steering/engineering/python-conventions.md" = {
      source = ./kiro-crew-files/steering/python-conventions.md;
    };
    ".kiro/steering/engineering/quality-gates.md" = {
      source = ./kiro-crew-files/steering/quality-gates.md;
    };
    ".kiro/steering/engineering/agent-practices.md" = {
      source = ./kiro-crew-files/steering/agent-practices.md;
    };
  };

  # Specialist crew agents are deliberately NOT managed here.
  # home-manager deploys home.file entries as symlinks into the read-only Nix
  # store, and the KiroCrew gateway's agent-spec reader fences symlinks for
  # safety (a spec behind a symlink could point anywhere). A symlinked agent
  # spec makes the gateway report the agent policy "unreadable" and blocks
  # history/session/skill tools for every session on that agent. So agent JSONs
  # stay as plain imperative files in ~/.kiro/agents/, same as kirocrew.json.
  # Sanitized copies live in the kiro-crew-config repo; re-register via the UI.

  # Hand-authored global skills (recursive: a skill is a directory of files)
  skillFiles = {
    ".kiro/skills/aidlc-workflow" = {
      source = ./kiro-crew-files/skills/aidlc-workflow;
      recursive = true;
    };
  };

  # Skill symlinks — these point to git-managed repos that update independently
  # Note: home.file symlinks from nix store won't work for pointing to mutable
  # paths, so we use an activation script instead.
  skillSymlinks = ''
    # Databricks skills (from databricks aitools install -> ~/.claude/skills)
    for skill in ~/.claude/skills/databricks-*; do
      name=$(basename "$skill")
      target="$HOME/.kiro/skills/$name"
      if [ -d "$skill" ] && [ ! -e "$target" ]; then
        ln -sfn "$skill" "$target"
      fi
    done

    # ClickHouse skills (from git clone -> ~/.clickhouse-agent-skills)
    for skill in clickhouse-best-practices clickhouse-architecture-advisor; do
      src="$HOME/.clickhouse-agent-skills/skills/$skill"
      target="$HOME/.kiro/skills/$skill"
      if [ -d "$src" ] && [ ! -e "$target" ]; then
        ln -sfn "$src" "$target"
      fi
    done
  '';

  # Post-upgrade script to re-patch kirocrew.json after AppImage regenerates it
  kiroPatchScript = pkgs.writeShellScriptBin "kiro-crew-patch" ''
    set -euo pipefail
    AGENT_FILE="$HOME/.kiro/agents/kirocrew.json"

    if [ ! -f "$AGENT_FILE" ]; then
      echo "[kiro-crew-patch] kirocrew.json not found — run KiroCrew first"
      exit 0
    fi

    ${pkgs.python3}/bin/python3 - "$AGENT_FILE" << 'PY'
    import json, sys
    path = sys.argv[1]
    agent = json.load(open(path))

    # Ensure mcp-clickhouse and context7 are enabled
    modified = False

    # Add mcp-clickhouse if missing
    if 'mcp-clickhouse' not in agent.get('mcpServers', {}):
        print("[kiro-crew-patch] Would need ClickHouse MCP credentials — skipping auto-add")
    elif agent['mcpServers']['mcp-clickhouse'].get('disabled'):
        agent['mcpServers']['mcp-clickhouse']['disabled'] = False
        modified = True

    # Add context7 if missing
    if 'context7' not in agent.get('mcpServers', {}):
        agent['mcpServers']['context7'] = {
            "url": "https://mcp.context7.com/mcp",
            "type": "http",
            "disabled": False,
            "autoApprove": ["resolve-library-id", "query-docs"]
        }
        modified = True

    # Ensure @mcp-clickhouse and @context7 in tools/allowedTools
    for ref in ['@mcp-clickhouse', '@context7']:
        if ref not in agent.get('tools', []):
            agent['tools'].append(ref)
            modified = True
        if ref not in agent.get('allowedTools', []):
            agent['allowedTools'].append(ref)
            modified = True

    if modified:
        json.dump(agent, open(path, 'w'), indent=2)
        print(f"[kiro-crew-patch] Patched {path}")
    else:
        print(f"[kiro-crew-patch] {path} already correct")
    PY
  '';

  # Aikido Safe Chain (Tech Radar Vol 35 #99) — supply-chain install blocker.
  # Option B: setup-ci PATH shims, so NON-INTERACTIVE Kiro Crew *agent* installs
  # (uv/npm/pip run by workers) are routed through safe-chain's malware proxy,
  # not just the interactive terminal. Pinned; re-run on rebuild. See the trial
  # + apply/verify guide: ~/.kiro/crew/workspace-member-setup/safe-chain-optionB.md
  safeChainVersion = "1.5.27";

  # The generated shims exec `safe-chain`; it must resolve on PATH or they fall
  # through to the real tool UNPROTECTED. Provide it as a pinned npx wrapper in
  # ~/.local/bin (which the worker PATH already ranks early). Node is already in
  # hosts/max/packages.nix.
  safeChainBin = pkgs.writeShellScriptBin "safe-chain" ''
    exec ${pkgs.nodejs}/bin/npx -y @aikidosec/safe-chain@${safeChainVersion} "$@"
  '';

in
{
  home.packages = [ kiroPatchScript safeChainBin ];

  # NOTE: we deliberately do NOT put ~/.safe-chain/shims on home.sessionPath.
  # That dir contains shims for RUN-path tools too (npx, node, python, python3,
  # uvx, …); putting the whole dir on PATH shadows them for every process,
  # including MCP servers that launch via `npx` — which broke MCP startup after
  # the first rebuild (safe-chain proxies every npx launch). Instead the
  # activation step below symlinks ONLY the install-verb shims into ~/.local/bin,
  # so package installs are gated but tool execution (MCP launch) is untouched.

  # Deploy steering files and skills (agent JSONs stay imperative — see note above)
  home.file = steeringFiles // skillFiles;

  # Activation script for skill symlinks (can't use home.file for mutable targets)
  home.activation.kiroCrewSkillSymlinks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${skillSymlinks}
  '';

  # Safe Chain Option B (Tech Radar Vol 35 #99): generate the setup-ci shims +
  # local CA at activation (needs network; fails soft offline), then symlink ONLY
  # the INSTALL-verb shims into ~/.local/bin (which the worker PATH ranks ahead of
  # the real npm/uv), so package installs are gated but tool EXECUTION is not.
  #
  # Why an allowlist: a shim for a run-path tool (npx, node, python, python3, and
  # the run-variants uvx/pnpx/bunx/rushx) routes EVERY invocation through the
  # safe-chain proxy — including MCP servers that launch via `npx` on each start.
  # That broke MCP after the first rebuild. So we shim only the commands that
  # actually INSTALL packages and leave the runtimes alone. `npx` is excluded on
  # purpose: it is the MCP launch path, and `npm install` already covers the real
  # install route. The CA keypair is machine-local (never vendored into the Nix
  # store), which is why this is an activation step, not a home.file of shims.
  #
  # Post-rebuild verify (install still blocked, MCP launch unaffected):
  #   command -v npx node python3            # real binaries, NOT ~/.local/bin shims
  #   command -v npm uv pip                  # ~/.local/bin shims (install gating on)
  #   sh -c 'cd $(mktemp -d) && npm init -y >/dev/null && npm install safe-chain-test --no-save'  # BLOCKED
  #   sh -c 'cd $(mktemp -d) && npm init -y >/dev/null && npm install left-pad --no-save'         # installs
  home.activation.safeChainShims = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.nodejs}/bin:$PATH"
    if ${pkgs.nodejs}/bin/npx -y @aikidosec/safe-chain@${safeChainVersion} setup-ci; then
      shims="$HOME/.safe-chain/shims"
      mkdir -p "$HOME/.local/bin"
      # INSTALL-verb allowlist only — NOT npx/node/python/python3/uvx/pnpx/bunx/rushx
      # (those are run-path tools MCP servers launch through; shimming them breaks MCP).
      for name in npm pip pip3 uv pnpm yarn poetry pdm pipx bun; do
        if [ -e "$shims/$name" ]; then
          ln -sfn "$shims/$name" "$HOME/.local/bin/$name"
        fi
      done
      # Remove any stale run-path shim symlinks a previous (shim-everything) build left behind.
      for name in npx node python python3 uvx pnpx bunx rush rushx; do
        if [ -L "$HOME/.local/bin/$name" ] && [ "$(readlink "$HOME/.local/bin/$name")" = "$shims/$name" ]; then
          rm -f "$HOME/.local/bin/$name"
        fi
      done
    else
      echo "[safe-chain] setup-ci failed (offline rebuild? npm unreachable?) — " \
           "leaving existing shims in place; agent protection may be stale." >&2
    fi
  '';
}
