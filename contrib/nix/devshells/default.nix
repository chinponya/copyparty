{ pkgs }:
let
  copypartyPkgs = import ../pkgs { inherit pkgs; };
  python = pkgs.python3.withPackages (ps:
    with ps; [
      # mandatory
      jinja2
      copypartyPkgs.strip-hints
      # thumbnails
      pillow
      copypartyPkgs.pyheif-pillow-opener
      copypartyPkgs.pillow-avif-plugin
      pyvips
      # audio metadata
      mutagen
      # ftp server
      pyftpdlib
      pyopenssl
      # smb server
      impacket
      # up2k
      requests
      # dev tools
      setuptools
      pytest
      black
      click
      bandit
      pylint
      flake8
      isort
      mypy
    ]);
in pkgs.mkShell {
  buildInputs = [
    python
    # video thumbnails
    pkgs.ffmpeg-full
  ];
}
