{ lib, fetchFromGitHub, buildNpmPackage }:

buildNpmPackage rec {
  pname = "asmcrypto.js";
  version = "2.3.3-0";
  src = fetchFromGitHub {
    owner = "openpgpjs";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-nuRVRrET+HIjho+d5MHVIk4iKJg967CqMAuvAQoJNmI=";
  };
  npmDepsHash = "sha256-QlGyILr4B3H1bW4vpAeuT7FkkUWGQg2DqpZn8uDh2po=";
  npmBuildScript = "prepare";
}
