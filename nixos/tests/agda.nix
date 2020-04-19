import ./make-test-python.nix ({ pkgs, ... }:

let
  testfile = pkgs.writeText "TestModule.agda"
    ''
    module TestModule where
    import IO
  '';
  # Make sure this does not get put in the nix store as an agda-lib file
  mylibFile = pkgs.writeText "agda-lib-file"
    ''
    name: mylib
    include: src
  '';
in
{
  name = "agda";
  meta = with pkgs.stdenv.lib.maintainers; {
    maintainers = [ alexarice turion ];
  };

  machine = { pkgs, ... }: {
    environment.systemPackages = [
      (pkgs.agda.withPackages {
        pkgs = [pkgs.agda.standard-library];
        homeLibraries = "mylib/mylib.agda-lib";
      })
    ];
    virtualisation.memorySize = 1000; # Agda uses a lot of memory
  };

  testScript = ''
    # Minimal script that typechecks
    machine.succeed("touch TestEmpty.agda")
    machine.succeed("agda TestEmpty.agda")

    # Minimal user library
    machine.succeed("mkdir -p mylib/src")
    machine.succeed(
        "cp ${testfile} mylib/src/TestModule.agda"
    )
    machine.succeed(
        "cp ${mylibFile} mylib/mylib.agda-lib"
    )
    print(machine.succeed("ls -la mylib/"))
    machine.succeed('echo "import TestModule" > TestUserLibrary.agda')
    machine.succeed("agda -l mylib TestUserLibrary.agda")

    # Minimal script that actually uses the standard library
    machine.succeed('echo "import IO" > TestIO.agda')
    machine.succeed("agda -l standard-library TestIO.agda")
  '';
}
)
