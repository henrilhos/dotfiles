# Teleport Connect pinned to 18.5.1. The Homebrew cask only tracks the latest
# release, so this unpacks the versioned .dmg from Teleport's CDN instead.
# To bump: change `version` and refresh `hash` with
#   nix store prefetch-file --name teleport-connect.dmg <url>
{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:
stdenvNoCC.mkDerivation rec {
  pname = "teleport-connect";
  version = "18.5.1";

  src = fetchurl {
    url = "https://cdn.teleport.dev/Teleport%20Connect-${version}.dmg";
    name = "teleport-connect-${version}.dmg";
    hash = "sha256-/QPYD4/2+1tjtJPamiPNfqeOVU8sO0w2dwk2Td43LRc=";
  };

  nativeBuildInputs = [ _7zz ];
  sourceRoot = ".";

  # undmg only reads HFS; this .dmg is APFS, which 7-Zip can unpack. 7-Zip
  # also extracts xattrs as stray `file:com.apple.*` files, which would break
  # the code signature seal, so drop them.
  unpackPhase = ''
    runHook preUnpack
    7zz x -snld "$src"
    find . -name '*:com.apple.*' -delete
    runHook postUnpack
  '';

  # The app is signed and notarized; don't let fixup rewrite its binaries.
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -R "Teleport Connect.app" "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Teleport Connect desktop client";
    homepage = "https://goteleport.com/";
    platforms = [ "aarch64-darwin" ];
    license = lib.licenses.unfree;
  };
}
