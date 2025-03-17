{ lib
, stdenvNoCC
, buildFHSEnv
, makeDesktopItem
, copyDesktopItems
, perimeter81-unwrapped
, extraPkgs ? pkgs: [ ]
, extraLibs ? pkgs: [ ]
}:
let
    fhs = runScript: buildFHSEnv {
        name = "p81fhs";
        inherit runScript;

        targetPkgs = pkgs: with pkgs; [
          xorg.libXrandr
        ] ++ extraPkgs pkgs;

        multiPkgs = pkgs: with pkgs; [
          cups
          gtk3
          expat
          libxkbcommon
          alsa-lib
          nss
          libgbm
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
        ] ++ extraLibs pkgs;

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

        nativeBuildInputs = [ copyDesktopItems ];

        postInstall = ''
            mkdir -p $out/bin
            mkdir -p $out/share
            ln -s ${fhs "/opt/Perimeter81/perimeter81"}/bin/p81fhs $out/bin/perimeter81
            ln -s ${fhs "/opt/Perimeter81/artifacts/daemon"}/bin/p81fhs $out/bin/p81-helper-daemon
            cp -r ${perimeter81-unwrapped}/share/doc ${perimeter81-unwrapped}/share/icons $out/share
        '';

        desktopItems = [(makeDesktopItem {
            name = "Perimeter81";
            desktopName = "Perimeter 81";
            exec = "perimeter81 %U";
            terminal = false;
            type = "Application";
            icon = "perimeter81";
            startupWMClass = "Perimeter81";
            comment = "Perimeter81 Linux Agent";
            mimeTypes = [
                "x-scheme-handler/perimeter81"
            ];
            categories = [
                "Network"
            ];
        })];

    }
