# OmO Native: the standalone `omo` agent CLI from oh-my-openagent.
#
# Upstream ships it as the npm package `omo-ai` (a Node shim around a pinned
# engine) and as single-file release binaries. We take the binary: no Node
# runtime, no postinstall, and it only links libc, so autoPatchelf is all it
# needs. Hashes come from the SHA256SUMS file attached to the release.
{ pkgs }:

let
  version = "5.1.64";
in
pkgs.stdenv.mkDerivation {
  pname = "omo";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://github.com/code-yeongyu/oh-my-openagent/releases/download/v${version}/omo-linux-x64";
    hash = "sha256-CflgMNBL40zW/JfFvmalnva7LGWJB1rMiW93wVUvELg=";
  };

  dontUnpack = true;
  dontStrip = true;

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];

  installPhase = ''
    install -Dm755 $src $out/bin/omo
  '';

  meta = {
    description = "OmO Native agent CLI (oh-my-openagent standalone edition)";
    homepage = "https://omo.dev";
    license = pkgs.lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "omo";
  };
}
