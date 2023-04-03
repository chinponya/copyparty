{ lib, fetchFromGitHub, buildNpmPackage, fetchNpmDeps, marked ? null
, codemirror ? null }:

buildNpmPackage rec {
  pname = "easymde";
  version = "2.18.0";
  src = fetchFromGitHub {
    owner = "Ionaru";
    repo = "easy-markdown-editor";
    rev = version;
    sha256 = "sha256-g3ZjvT/gqKztyrItn+xOysOWcyQ70xCkFY+dWlK7hL8=";
  };
  npmDepsHash = "sha256-Vkyw8PisYD7XznOQjzb2S9No7Ec5tGYUImRQOJLin3M=";
  npmBuildScript = "prepare";
  patches = [
    ../../../../scripts/deps-docker/easymde.patch
    ../../../../scripts/deps-docker/easymde-ln.patch
  ];
  postPatch = ''
    sed -ri 's`^var marked = require\(.marked.\).marked;$`var marked = window.marked;`' src/js/easymde.js
  '';
  # Awful hack for replacing the dependencies without making npm unhappy.
  # Changing package.json/package-lock.json in postPatch didn't work
  # due to fetch-npm-deps being unable to deal with local file paths
  # as a dependency source location.
  preBuild = ''
    ${lib.optionalString (marked != null) ''
      cp node_modules/marked/package.json marked-package.json
      rm -rf node_modules/marked
      cp -r ${marked}/lib/node_modules/marked node_modules/
      chmod -R +w node_modules/marked
      cp marked-package.json node_modules/marked/package.json
    ''}

    ${lib.optionalString (codemirror != null) ''
      cp node_modules/codemirror/package.json codemirror-package.json
      rm -rf node_modules/codemirror
      cp -r ${codemirror}/lib/node_modules/codemirror node_modules/
      chmod -R +w node_modules/codemirror
      cp codemirror-package.json node_modules/codemirror/package.json
    ''}
  '';
  CYPRESS_INSTALL_BINARY = "0";
}
