{
  pkgs,
  lib,
  runfile,
  ...
}:
let
  pythonForIDA = pkgs.python3.withPackages (ps: with ps; [ rpyc ]);
in
pkgs.stdenv.mkDerivation rec {
  pname = "ida-pro";
  version = "9.0.0.240925";

  src = runfile;

  desktopItem = pkgs.makeDesktopItem {
    name = "ida-pro";
    exec = "ida";
    icon = ../share/appico.png;
    comment = meta.description;
    desktopName = "IDA Pro";
    genericName = "Interactive Disassembler";
    categories = [ "Development" ];
    startupWMClass = "IDA";
  };
  desktopItems = [ desktopItem ];

  nativeBuildInputs = with pkgs; [
    makeWrapper
    copyDesktopItems
    autoPatchelfHook
    libsForQt5.wrapQtAppsHook
  ];

  # We just get a runfile in $src, so no need to unpack it.
  dontUnpack = true;

  # Add everything to the RPATH, in case IDA decides to dlopen things.
  runtimeDependencies = with pkgs; [
    cairo
    dbus
    fontconfig
    freetype
    glib
    gtk3
    libdrm
    libGL
    libkrb5
    libsecret
    libsForQt5.qtbase
    libunwind
    libxkbcommon
    libsecret
    openssl.out
    stdenv.cc.cc
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXau
    xorg.libxcb
    xorg.libXext
    xorg.libXi
    xorg.libXrender
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    zlib
    curl
    pythonForIDA
  ];
  buildInputs = runtimeDependencies;

  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib $out/opt

    # IDA depends on quite some things extracted by the runfile, so first extract everything
    # into $out/opt, then remove the unnecessary files and directories.
    IDADIR=$out/opt

    # Invoke the installer with the dynamic loader directly, avoiding the need
    # to copy it to fix permissions and patch the executable.
    $(cat $NIX_CC/nix-support/dynamic-linker) $src \
      --mode unattended --prefix $IDADIR

    # Link the exported libraries to the output.
    for lib in $IDADIR/libida*; do
      ln -s $lib $out/lib/$(basename $lib)
    done

    # Manually patch libraries that dlopen stuff.
    patchelf --add-needed libpython3.12.so $out/lib/libida.so
    patchelf --add-needed libcrypto.so $out/lib/libida.so

    # Some libraries come with the installer.
    addAutoPatchelfSearchPath $IDADIR

    # Link the binaries to the output.
    # Also, hack the PATH so that pythonForIDA is used over the system python.
    for bb in ida assistant; do
      wrapProgram $IDADIR/$bb \
        --prefix QT_PLUGIN_PATH : $IDADIR/plugins/platforms \
        --prefix PYTHONPATH : $out/opt/idalib/python \
        --prefix PATH : ${pythonForIDA}/bin
      ln -s $IDADIR/$bb $out/bin/$bb
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "The world's smartest and most feature-full disassembler";
    homepage = "https://hex-rays.com/ida-pro/";
    license = licenses.unfree;
    mainProgram = "ida";
    maintainers = with maintainers; [ msanft ];
    platforms = [ "x86_64-linux" ]; # Right now, the installation script only supports Linux.
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
