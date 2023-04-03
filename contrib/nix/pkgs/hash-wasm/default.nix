# FIXME The upstream build script requires docker, so we use the prebuilt release instead
{ lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "hash-wasm";
  version = "4.9.0";
  src = fetchzip {
    url =
      "https://github.com/Daninet/hash-wasm/releases/download/v${version}/hash-wasm@${version}.zip";
    stripRoot = false;
    sha256 = "sha256-PdBFdfNh7LuHVYNJImAY7AV2+GxhNaFXzbfnlJMt5yk=";
  };
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir $out
    cp -r $src/* $out/
    runHook postInstall
  '';
}

# FIXME Breaks due to different hash types in package-lock.json for the same url.
# Needs to be worked around or fixed upstream in buildNpmPackage.
# FIXME The build script requires docker, so it needs to be rewritten to work in nix.
# { lib, fetchFromGitHub, buildNpmPackage }:
# buildNpmPackage rec {
#   pname = "hash-wasm";
#   version = "4.9.0";
#   src = fetchFromGitHub {
#     owner = "Daninet";
#     repo = pname;
#     rev = "v${version}";
#     sha256 = "sha256-4yamxWQCk55HXdrSxlDMquMVoHtcbLPimaikAjwrX9s=";
#   };
#   npmDepsHash = "sha256-r9It2F2Y2sweJK1evAxPcBCX9cSij3BIvyu/ceOW5tY=";
#   postPatch = ''
#     patchShebangs scripts/build.sh
#   '';
# };
