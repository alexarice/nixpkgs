import ./make-test-python.nix ({ pkgs, ... }:

let
  testfile = pkgs.writeText "TestModule.agda" ''
    module TestModule where
  '';
  # Make sure this does not get put in the nix store as an agda-lib file
  mylibFile = pkgs.writeText "agda-lib-file" ''
    name: mylib
    include: src
  '';
  hello-world = pkgs.writeText "hello-world" ''
    open import IO

    main = run(putStrLn "Hello World!")
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
    virtualisation.memorySize = 2000; # Agda uses a lot of memory
  };

  testScript = ''
    # Minimal user library
    machine.succeed("mkdir -p mylib/src")
    machine.succeed(
        "cp ${testfile} mylib/src/TestModule.agda"
    )
    machine.succeed(
        "cp ${mylibFile} mylib/mylib.agda-lib"
    )

    # Minimal script that typechecks
    machine.succeed("touch TestEmpty.agda")
    machine.succeed("agda TestEmpty.agda")

    # Minimal script using user library
    machine.succeed('echo "import TestModule" > TestUserLibrary.agda')
    machine.succeed("agda -l mylib -i . TestUserLibrary.agda")

    # Minimal script that actually uses the standard library
    machine.succeed('echo "import IO" > TestIO.agda')
    machine.succeed("agda -l standard-library -i . TestIO.agda")

    # # Hello world
    machine.succeed(
        "cp ${hello-world} HelloWorld.agda"
    )
    machine.succeed("agda -l standard-library -i . -c HelloWorld.agda")
  '';
}
)
