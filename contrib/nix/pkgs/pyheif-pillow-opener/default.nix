{ lib, buildPythonPackage, fetchPypi, pytestCheckHook, pyheif }:

buildPythonPackage rec {
  pname = "pyheif-pillow-opener";
  version = "0.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-p/bKW773qQCd3xqeWzQc1bkx2NVlH2YIL+82cS2mZQY=";
  };

  propagatedBuildInputs = [ pyheif ];

  # tests are missing in the pypi release
  doCheck = false;
}