{ pkgs, lib, callPackage, newScope, Agda }:

let
  mkAgdaPackages = Agda: lib.makeScope newScope (mkAgdaPackages' Agda);
  mkAgdaPackages' = Agda: self: let
    callPackage = self.callPackage;
  in {
    inherit (callPackage ../build-support/agda {
      inherit Agda self;
      inherit (pkgs.haskellPackages) ghcWithPackages;
    }) withPackages mkDerivation;

    Agda = self.withPackages [];

    standard-library = callPackage ../development/libraries/agda/standard-library {
      inherit (pkgs.haskellPackages) ghcWithPackages;
    };

    iowa-stdlib = callPackage ../development/libraries/agda/iowa-stdlib { };

    agda-prelude = callPackage ../development/libraries/agda/agda-prelude { };
  };
in mkAgdaPackages Agda
