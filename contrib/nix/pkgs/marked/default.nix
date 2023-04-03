{ lib, fetchFromGitHub, buildNpmPackage }:

buildNpmPackage rec {
  pname = "marked";
  version = "4.3.0";
  src = fetchFromGitHub {
    owner = "markedjs";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-xJotgIUoZSmjgLRIgJP9134PR1GYKjVXM5jp+JpM7bg=";
  };
  npmDepsHash = "sha256-omsoER0I28ZHN78X0aku2jNJApPvpqYKgfPhRbEi+HM=";
  patches = [
    ../../../../scripts/deps-docker/marked.patch
    ../../../../scripts/deps-docker/marked-ln.patch
  ];
}
