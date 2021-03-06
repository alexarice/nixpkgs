{ stdenv, fetchurl, intltool, pkgconfig, networkmanager, strongswanNM
, gtk3, gnome3, libsecret, libnma }:

stdenv.mkDerivation rec {
  pname = "NetworkManager-strongswan";
  version = "1.5.0";

  src = fetchurl {
    url = "https://download.strongswan.org/NetworkManager/${pname}-${version}.tar.bz2";
    sha256 = "1x6hivr1v76fxy1dn82xrj9rj8k3r097kf4yiblqq16y631hxzy4";
  };

  buildInputs = [ networkmanager strongswanNM libsecret gtk3 libnma ];

  nativeBuildInputs = [ intltool pkgconfig ];

  # glib-2.62 deprecations
  NIX_CFLAGS_COMPILE = "-DGLIB_DISABLE_DEPRECATION_WARNINGS";

  configureFlags = [
    "--without-libnm-glib"
    "--with-charon=${strongswanNM}/libexec/ipsec/charon-nm"
    "--with-nm-libexecdir=$(out)/libexec"
    "--with-nm-plugindir=$(out)/lib/NetworkManager"
  ];

  PKG_CONFIG_LIBNM_VPNSERVICEDIR = "$(out)/lib/NetworkManager/VPN";

  meta = with stdenv.lib; {
    description = "NetworkManager's strongswan plugin";
    inherit (networkmanager.meta) platforms;
    license = licenses.gpl2Plus;
  };
}
