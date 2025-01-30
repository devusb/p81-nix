{
  stdenv,
  fetchurl,
  dpkg,
}:
stdenv.mkDerivation rec {
  pname = "perimeter81";
  version = "10.0.1.885";
  src = fetchurl {
    url = "https://static.perimeter81.com/agents/linux/Perimeter81_${version}.deb";
    sha256 = "sha256-+8EJ0D0eZeHiD7Tx9rWQ6g+llrT4anAd34iwbpfpHIk=";
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
