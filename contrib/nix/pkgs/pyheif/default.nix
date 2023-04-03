{ lib, buildPythonPackage, fetchPypi, cffi, twine, libheif }:

buildPythonPackage rec {
  pname = "pyheif";
  version = "0.7.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-hqXFF0N51xRrXtGmiJL69yaKE1+39QOaARv7em6QMgA=";
  };

  buildInputs = [ libheif ];
  propagatedBuildInputs = [ cffi twine ];
}
