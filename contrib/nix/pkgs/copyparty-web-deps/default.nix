{ stdenv, gzip, asmcrypto, marked, hash-wasm, prism-bundle, easymde }:

let
  asmcryptoOnlySha512 = asmcrypto.overrideAttrs (oldAttrs: {
    postPatch = ''
      echo "export { Sha512 } from './hash/sha512/sha512';" > src/entry-export_all.ts
    '';
  });
in stdenv.mkDerivation {
  name = "copyparty-web-deps";
  buildInputs = [ gzip ];
  phases = [ "installPhase" ];

  installPhase = ''
    mkdir $out
    awk '/HMAC state/{o=1}  /var HEAP/{o=0}  /function hmac_reset/{o=1}  /return \{/{o=0}  /var __extends =/{o=1}  /var Hash =/{o=0}  /hmac_|pbkdf2_/{next}  o{next}  {gsub(/IllegalStateError/,"Exception")}  {sub(/^ +/,"");sub(/^\/\/ .*/,"");sub(/;$/," ;")}  1' < ${asmcryptoOnlySha512}/lib/node_modules/@openpgp/asmcrypto.js/asmcrypto.all.es5.js > $out/sha512.ac.js
    cp ${hash-wasm}/sha512.umd.min.js $out/sha512.hw.js
    cp ${marked}/lib/node_modules/marked/marked.min.js $out/marked.js
    cp ${easymde}/lib/node_modules/easymde/dist/easymde.min.js $out/easymde.js
    cp ${easymde}/lib/node_modules/easymde/dist/easymde.min.css $out/easymde.css
    cp ${prism-bundle}/* $out/
    gzip $out/*.{css,js}
  '';
}
