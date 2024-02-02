let Port = import "./port.ncl" in
let Unit = import "./units.ncl" in

let mkExclusiveFieldsContract = fun fields_to_check keyID =>
  # Returns a contract that checks one and exactly one of the fields is present, optionally retrieving some identifier
  let id = fun A => A in
  fun label value =>
    if (std.array.any (fun field => std.record.has_field field value) fields_to_check)
    && std.array.length (std.array.filter (fun field => std.array.elem field fields_to_check) (std.record.fields value)) == 1 then
      value
    else
      label
      |> std.contract.label.append_note "Field must contain exactly one of (%{std.string.join ", " fields_to_check})"
      |> (if keyID != null then std.contract.label.append_note "Offending key: %{value."%{keyID}"}" else id)
      |> std.contract.blame
in

let ResourceSchema =
  let Resources =
    let CPUContract = fun label value =>
      if (std.is_number value) && (value > 0) then
        value
      else
        std.contract.blame_with_message "Specified CPU limit value is not correct" label
    in
    {
      memory | (Unit std.number.PosNat) | optional,
      cpu | (Unit CPUContract) | optional,
      "nvidia.com/gpu" | std.number.PosNat | optional
    }
  in
  {
    requests | Resources | optional,
    limits | Resources | optional
  }
in

let Secret =
  std.contract.Sequence
    [
      {
        snowflakeSecret | String,
        secretKeyRef | String | optional,
        envVarName | String | optional,
        directoryPath | String | optional
      },
      (mkExclusiveFieldsContract ["envVarName", "directoryPath"] "snowflakeSecret"),
      (mkExclusiveFieldsContract ["directoryPath", "secretKeyRef"] "snowflakeSecret"),
    ]
in

Array {
  name | String,
  image | String,
  command | Array String | optional,
  args | Array String | optional,
  env | { _ : String } | optional,
  readinessProbe
    | {
      port | Port,
      path | String,
    }
    | optional,
  volumeMounts
    | Array {
      name | String,
      mountPath | String | optional
    }
    | optional,
  resources
    | ResourceSchema
    | optional,
  secrets
    | Array Secret
    | optional,
}
