{
  writeShellApplication,
  nickel,
  yamllint,
}:
writeShellApplication {
  name = "spcs-spec-validator";

  runtimeInputs = [
    nickel
    yamllint
  ];

  text = builtins.readFile ./src/main;

  meta = {
    description = ''
      Snowpark container services spec validation
    '';
  };
}
