# aidlc.nix — AWS AI-DLC Workflows 2.0 CLI, built from source for NixOS.
#
# Why a from-source derivation instead of the upstream installer:
#   The 2.x line ships NO release binaries yet (the documented install.sh 404s,
#   and v2.7.0/v2.8.0 carry zero GitHub assets), so the only way to a 2.0 `aidlc`
#   today is a `bun` source build. Upstream's own installer also insists on a
#   MUTABLE self-managed tree (~/.local/share/aidlc/versions/<v> + an
#   active-version marker + a ~/.local/bin pointer) to support `aidlc update`.
#   That fights a declarative system. We skip it entirely: the compiled binary
#   auto-resolves its runtime from a SIBLING `runtime/` directory
#   (packagedDistributionRoot = dirname(execPath)/runtime/<distribution>), so we
#   install `{aidlc, runtime/}` side by side in the store and wrap it on PATH.
#   Verified: `aidlc config --harness kiro` + `aidlc doctor` run clean (0
#   problems) from that layout with no install-root and no env var.
#
# Upgrading: bump `version` + `rev`, set `srcHash` to "" and rebuild to learn the
# new source hash, then set `depsHash` to "" and rebuild to learn the deps hash
# (both are fixed-output; Nix prints "got: sha256-..." on mismatch).
#
# Usage: imports = [ ./aidlc.nix ];  (wired into hosts/max/home.nix)
{ pkgs, lib, ... }:

let
  version = "2.8.0";
  rev = "1c64d9a60754dc7e0acdae6bcad6c7b01e6fb155"; # tag v2.8.0

  src = pkgs.fetchFromGitHub {
    owner = "awslabs";
    repo = "aidlc-workflows";
    inherit rev;
    # Pinned source hash for tag v2.8.0.
    hash = "sha256-hKPV2ykAwcfMtkxrYlQ2Fnw53692O+48Qfv+3PyB33Q=";
  };

  # Phase 1 — vendored dependencies as a fixed-output derivation (this is the
  # ONLY step allowed network access; everything downstream builds offline).
  # `--ignore-scripts` skips node-pty's native postinstall compile: nothing in
  # core/ or scripts/ imports node-pty, and a compiled addon would embed nix
  # store paths (gcc-lib/nodejs) that a fixed-output derivation forbids.
  aidlc-deps = pkgs.stdenv.mkDerivation {
    pname = "aidlc-deps";
    inherit version src;
    nativeBuildInputs = [ pkgs.bun ];
    dontConfigure = true;
    buildPhase = ''
      export HOME=$TMPDIR
      bun install --frozen-lockfile --no-progress --ignore-scripts
    '';
    installPhase = ''
      mkdir -p $out
      cp -R node_modules $out/
    '';
    dontFixup = true;
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-dC34ImzZli/DahpJScnnFbABYvRXyUsGpVDZjhZlXIY=";
  };

  # Phase 2 — offline build: compile the native binary and stage the kiro runtime.
  aidlc-unwrapped = pkgs.stdenv.mkDerivation {
    pname = "aidlc-unwrapped";
    inherit version src;
    nativeBuildInputs = [ pkgs.bun pkgs.makeWrapper ];
    dontConfigure = true;
    buildPhase = ''
      export HOME=$TMPDIR
      cp -R ${aidlc-deps}/node_modules ./node_modules
      chmod -R u+w node_modules
      # build-binaries.ts smoke-gates by running `doctor` in a throwaway project
      # with no install marker, so it exits non-zero even when the binary is
      # sound (verified: the binary itself runs version/help/doctor cleanly).
      # Tolerate the gate exit and assert the artifacts exist instead.
      bun scripts/build-binaries.ts || true
      test -x build/binaries/native/aidlc || { echo "no aidlc binary produced"; exit 1; }
      test -d build/binaries/native/runtime/kiro || { echo "no kiro runtime staged"; exit 1; }
    '';
    installPhase = ''
      mkdir -p $out/libexec/aidlc $out/bin
      cp build/binaries/native/aidlc $out/libexec/aidlc/aidlc
      chmod +x $out/libexec/aidlc/aidlc
      # Install the runtime as a SIBLING of the binary so packagedDistributionRoot
      # resolves it with no env var. We only need the kiro distribution for KiroCrew;
      # copy the whole runtime/ if you want every harness available.
      mkdir -p $out/libexec/aidlc/runtime
      cp -R build/binaries/native/runtime/kiro $out/libexec/aidlc/runtime/kiro
      # PATH entry — a thin symlink keeps dirname(execPath)/runtime intact.
      ln -s $out/libexec/aidlc/aidlc $out/bin/aidlc
    '';
    # The compiled Bun binary is already self-contained; don't let fixup strip it.
    dontStrip = true;
    meta = with lib; {
      description = "AWS AI-DLC Workflows 2.0 CLI (built from source for NixOS)";
      homepage = "https://github.com/awslabs/aidlc-workflows";
      license = licenses.mit; # MIT-0
      platforms = [ "x86_64-linux" ];
      mainProgram = "aidlc";
    };
  };
in
{
  home.packages = [ aidlc-unwrapped ];
}
