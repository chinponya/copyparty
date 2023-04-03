{ pkgs }:

rec {
  copyparty = pkgs.python3.pkgs.callPackage ./copyparty {
    inherit copyparty-web-deps pyheif-pillow-opener pillow-avif-plugin;
    ffmpeg = pkgs.ffmpeg-full;
  };
  copyparty-web-deps = pkgs.callPackage ./copyparty-web-deps {
    inherit asmcrypto marked hash-wasm prism-bundle easymde;
  };
  pyheif = pkgs.python3.pkgs.callPackage ./pyheif { };
  pyheif-pillow-opener =
    pkgs.python3.pkgs.callPackage ./pyheif-pillow-opener { inherit pyheif; };
  pillow-avif-plugin = pkgs.python3.pkgs.callPackage ./pillow-avif-plugin { };
  strip-hints = pkgs.python3.pkgs.callPackage ./strip-hints { };
  asmcrypto = pkgs.callPackage ./asmcrypto { };
  marked = pkgs.callPackage ./marked { };
  hash-wasm = pkgs.callPackage ./hash-wasm { };
  codemirror = pkgs.callPackage ./codemirror { };
  prism-bundle = pkgs.callPackage ./prism-bundle { };
  easymde = pkgs.callPackage ./easymde { inherit marked codemirror; };
}
