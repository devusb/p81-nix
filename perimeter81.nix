{ stdenv, dpkg, writeText }:
stdenv.mkDerivation rec {
  pname = "perimeter81";
  version = "9.0.1.843";
  src = builtins.fetchurl {
    url =
      "https://static.perimeter81.com/agents/linux/Perimeter81_${version}.deb";
    sha256 = "sha256:0ys2w2yqsb45lzjrnbq9x880w1c0vn0s9chrb9w9773h4062p3ji";
  };

  nativeBuildInputs = [ dpkg ];

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src .

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp -R "opt" "$out"
    cp -R "usr/share" "$out/share"
    chmod -R g-w "$out"

    # Desktop file
    mkdir -p "$out/share/applications"

    runHook postInstall
  '';
 
}
