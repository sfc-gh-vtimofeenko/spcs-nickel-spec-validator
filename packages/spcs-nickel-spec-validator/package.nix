{ writeShellApplication, nickel }:
writeShellApplication {
  name = "spcs-spec-validator";

  runtimeInputs = [ nickel ];

  text = builtins.readFile ./src/main;

  meta = {
    description = ''
      Snowpark container services spec validation
    '';
  };
}
