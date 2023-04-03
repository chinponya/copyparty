{ lib, buildPythonPackage, fetchPypi, libavif }:

buildPythonPackage rec {
  pname = "pillow-avif-plugin";
  version = "1.3.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-faIf/OI/m0l6hory0+A7A/+sspwccnkD6Epz30K0ifE=";
  };

  buildInputs = [ libavif ];
}
