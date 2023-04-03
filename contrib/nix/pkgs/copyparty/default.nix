{ lib, fetchFromGitHub, buildPythonApplication, pytestCheckHook, requests
, jinja2, mutagen, pillow, pyvips, pyheif-pillow-opener, pillow-avif-plugin
, pyftpdlib, pyopenssl, impacket, ffmpeg, copyparty-web-deps }:

buildPythonApplication rec {
  pname = "copyparty";
  version = "1.6.11";
  src = lib.cleanSource ../../../../.;

  configurePhase = ''
    cp -r ${copyparty-web-deps} copyparty/web/deps
    chmod +w copyparty/web/deps
    # file exists in the repo but gets removed by gitignoreSource
    touch copyparty/web/deps/__init__.py
  '';

  checkInputs = [ pytestCheckHook ];

  propagatedBuildInputs = [
    # mandatory
    jinja2
    # thumbnails
    pillow
    pyheif-pillow-opener
    pillow-avif-plugin
    pyvips
    ffmpeg
    # audio metadata
    mutagen
    # ftp server
    pyftpdlib
    pyopenssl
    # smb server
    impacket
    # up2k
    requests
  ];
}
