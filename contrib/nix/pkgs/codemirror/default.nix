{ lib, fetchFromGitHub, buildNpmPackage }:

buildNpmPackage rec {
  pname = "codemirror";
  version = "5.65.12";
  src = fetchFromGitHub {
    owner = "codemirror";
    repo = "codemirror5";
    rev = version;
    sha256 = "sha256-Yj/66em/9F3/xpMplH38Vfnuvg8Wd5NJz4yj2FP7qZE=";
  };
  npmDepsHash = "sha256-SCm0JCJ0QC3kjR0E6hwDMEyTLyBtEseoOJ83lY+cJBo=";
  patches = [ ../../../../scripts/deps-docker/codemirror.patch ];
  postPatch = ''
    # use generated package-lock.json - upstream does not provide one
    cp ${./package-lock.json} ./package-lock.json
    sed -ri '/^var urlRE = /d' mode/gfm/gfm.js
  '';
  PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = "1";
}
