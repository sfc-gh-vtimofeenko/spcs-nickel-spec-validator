{
  writeShellApplication,
  nickel,
  symlinkJoin,
  stdenv,
}:
symlinkJoin {
  name = "spcs-spec-validator";
  paths = [
    (writeShellApplication {
      name = "spcs-spec-validator";

      runtimeInputs = [ nickel ];

      text = builtins.readFile ./src/bin/main;

      meta = {
        description = ''
          Snowpark container services spec validation
        '';
      };
    })
    (stdenv.mkDerivation {
      name = "spcs-spec-validator-schemas";
      src = ./src;
      buildPhase = ''
        mkdir -p $out
        cp -R ./schemas $out
      '';
    })
  ];
}
// {
  meta.mainProgram = "spcs-spec-validator";
}
