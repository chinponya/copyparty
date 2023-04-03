{ lib, buildPythonPackage, fetchPypi }:

buildPythonPackage rec {
  pname = "strip-hints";
  version = "0.1.10";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-MHwr0UfNNZl8jtLpo73KSK2clhfgTqRlmQlSAbTOmY8=";
  };
}
