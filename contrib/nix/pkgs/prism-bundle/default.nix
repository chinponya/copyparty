{ lib, stdenv, fetchFromGitHub, python3 }:

stdenv.mkDerivation rec {
  pname = "prism-bundle";
  version = "1.29.0";

  src = fetchFromGitHub {
    owner = "PrismJS";
    repo = "prism";
    rev = "v${version}";
    sha256 = "sha256-KEoICg4xviKsmN9M8ceJdAJ1NhTO7urDJnJknuP4GoQ=";
  };

  buildInputs = [ python3 ];

  configurePhase = ''
    cp ${../../../../scripts/deps-docker/genprism.py} genprism.py
    cp ${../../../../scripts/deps-docker/genprism.sh} genprism.sh
    # FIXME we shouldn't need to patch the code we own
    patchShebangs genprism.sh genprism.py
    sed -i '/^mv /d' genprism.sh
  '';

  buildPhase = ''
    ./genprism.sh ./
  '';

  installPhase = ''
    mkdir $out
    mv prism-funky.css prismd.css
    mv prismd.css prism.css prism.js $out
  '';
}

