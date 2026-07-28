# Datadog Pup CLI — a Rust-based command-line wrapper for the Datadog APIs.
#
# Not in nixpkgs, so we package the upstream prebuilt release binary:
# fetch the release tarball, verify its hash, and drop the single static
# binary into $out/bin.
#
# The Linux x86_64 release is a static-pie ELF (statically linked, no
# interpreter), so no autoPatchelf / runtime deps are required.
#
# Upstream: https://github.com/DataDog/pup
{ pkgs, ... }:

let
  pup = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "datadog-pup";
    version = "1.6.2";

    src = pkgs.fetchurl {
      url = "https://github.com/DataDog/pup/releases/download/v${version}/pup_${version}_Linux_x86_64.tar.gz";
      hash = "sha256-7lAsWzx7PVZywOraiP25Y4+LgISfuP+6ai3p250pVy8=";
    };

    dontUnpack = true;

    nativeBuildInputs = [
      pkgs.gnutar
      pkgs.gzip
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin"
      tar -xzf "$src" -C "$out/bin" pup
      chmod +x "$out/bin/pup"

      runHook postInstall
    '';

    meta = {
      description = "Datadog Pup CLI: AI-agent-ready command-line wrapper for the Datadog APIs";
      homepage = "https://github.com/DataDog/pup";
      license = pkgs.lib.licenses.asl20;
      mainProgram = "pup";
      platforms = [ "x86_64-linux" ];
    };
  };
in

{
  home.packages = [ pup ];
}
