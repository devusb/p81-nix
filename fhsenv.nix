{
  stdenvNoCC,
  buildFHSEnv,
  perimeter81-unwrapped,
  extraPkgs ? pkgs: [ ],
  extraLibs ? pkgs: [ ],
}:
let
  fhs =
    runScript:
    buildFHSEnv {
      name = "p81fhs";
      inherit runScript;

      targetPkgs =
        pkgs:
        with pkgs;
        [
          gtk3
          bashInteractive
          zenity
          xorg.libXrandr
          which
          perl
          xdg-utils
          iana-etc
          krb5
        ]
        ++ extraPkgs pkgs;

      multiPkgs =
        pkgs:
        with pkgs;
        [
          cups
          expat
          libxkbcommon
          alsa-lib
          nss
          libdrm
          mesa
          nspr
          atk
          dbus
          pango
          xorg.libXcomposite
          xorg.libXext
          xorg.libXdamage
          xorg.libXfixes
          xorg.libxcb
          xorg.libxshmfence

          openssl
          iproute2
          procps
          cairo
          libnotify
          udev
          libappindicator
          xorg.libX11
          glib
          gdk-pixbuf

          perimeter81-unwrapped
        ]
        ++ extraLibs pkgs;

      extraBuildCommands = ''
        mkdir -p $out/usr/local
      '';

      extraBwrapArgs = [
        "--bind /var/lib/p81/local /usr/local"
        "--bind /var/lib/p81/etc /etc/Perimeter81"
      ];

    };
in
stdenvNoCC.mkDerivation {
  name = "perimeter81";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = false;

  postInstall = ''
    mkdir -p $out/bin
    ln -s ${fhs "/opt/Perimeter81/perimeter81"}/bin/p81fhs $out/bin/perimeter81
    ln -s ${fhs "/opt/Perimeter81/artifacts/daemon"}/bin/p81fhs $out/bin/p81-helper-daemon
    ln -s ${fhs "/bin/bash"}/bin/p81fhs $out/bin/p81shell
    ln -s ${perimeter81-unwrapped}/share $out/share
  '';

}
