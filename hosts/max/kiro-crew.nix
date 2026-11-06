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

in
{
  home.packages = [ kiroPatchScript ];

  # Deploy steering files and skills (agent JSONs stay imperative — see note above)
  home.file = steeringFiles // skillFiles;

  # Activation script for skill symlinks (can't use home.file for mutable targets)
  home.activation.kiroCrewSkillSymlinks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${skillSymlinks}
  '';
}
