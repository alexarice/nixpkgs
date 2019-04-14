{ stdenv, fetchFromGitLab , which, go-md2man, coreutils, substituteAll }:

stdenv.mkDerivation rec {
  pname = "brillo";
  version = "1.4.6";

  src = fetchFromGitLab {
    owner= "cameronnemo";
    repo= "brillo";
    rev= "v${version}";
    sha256 = "08xn01ij6343bxhh10hjmmgkpkkgqfp7098hcbnhz5ijkaq7k73z";
  };

  patches = [
    (substituteAll {
      src = ./udev-rule.patch;
      inherit coreutils;
    })
  ];

  nativeBuildInputs = [ go-md2man which ];

  makeFlags = [ "PREFIX=$(out)" "AADIR=$(out)/etc/apparmor.d" ];

  buildFlags = [ "dist" ];

  installTargets = "install-dist";

  meta = with stdenv.lib; {
    description = "Backlight and Keyboard LED control tool";
    homepage = https://gitlab.com/cameronnemo/brillo;
    license = [ licenses.gpl3 licenses.bsd0 ];
    platforms = platforms.linux;
    maintainers = [ maintainers.alexarice ];
  };
}
