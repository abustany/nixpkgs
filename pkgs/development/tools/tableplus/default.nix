{ lib
, stdenv
, fetchurl
, cairo
, cpio
, glib
, gtk3
, gtksourceview
, json-glib
, libgee
, libsecret
, pango
, rpm
, sqlite
, autoPatchelfHook
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "tableplus";
  version = "0.1.216";

  src = fetchurl {
    # yes, it's weird that the RPM version doesn't match the actual version...
    # But 0.1.216 is what shows in the "About" dialog, and is the version of
    # the deb package as well.
    url = "https://yum.tableplus.com/rpm/x86_64/tableplus-0.0.2-216.x86_64.rpm";
    sha256 = "sha256-P9u8ALZ3rhYNKJTpUc420y9HdxQ4tvJ0Hg17ytqpZpg=";
  };

  nativeBuildInputs = [ autoPatchelfHook wrapGAppsHook rpm cpio ];

  unpackPhase = ''
    rpm2cpio $src | cpio -idmv
  '';

  dontConfigure = true;
  dontBuild = true;

  buildInputs = [
    cairo
    glib
    gtk3
    gtksourceview
    json-glib
    libgee
    libsecret
    pango
    sqlite
  ];

  installPhase = ''
    mkdir -p $out/bin $out/share/icons/hicolor/256x256/apps $out/share/applications
    mv opt/tableplus/tableplus $out/bin/tableplus
    mv opt/tableplus/resource/image/logo.png $out/share/icons/hicolor/256x256/apps/tableplus.png
    mv opt/tableplus/tableplus.desktop $out/share/applications/tableplus.desktop
    patchelf \
      --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      $out/bin/tableplus
    sed -i \
      -e "s,^Exec=.*,Exec=$out/bin/tableplus," \
      -e 's,^Icon=.*,Icon=tableplus,' \
      $out/share/applications/tableplus.desktop
  '';

  meta = with lib; {
    description = "Modern, native, and friendly GUI tool for relational databases.";
    longDescription = ''
      Modern, native, and friendly GUI tool for relational databases: MySQL,
      PostgreSQL, SQLite & more.
    '';
    homepage = "https://tableplus.com/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    maintainers = with maintainers; [ abustany ];
    platforms = [ "x86_64-linux" ];
  };
}
