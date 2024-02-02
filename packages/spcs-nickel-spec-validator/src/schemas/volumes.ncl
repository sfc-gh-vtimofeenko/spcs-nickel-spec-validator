let impl : Bool -> Bool -> Bool = fun A B => !A || B in

let Unit = import "./units.ncl" in

let VolumeSchema =
  let Source = fun label value =>
    # Validates that "value" is either 'local', 'memory' or '@<stagename>'
    if (std.is_string value) && ((std.array.elem value ["local", "memory"]) || (std.string.substring 0 1 value == "@")) then
      value
    else
      std.contract.blame_with_message "is not one of 'local | @<stagename> | memory'" label
  in
  let MemoryIFFSize = fun label value =>
    let P = std.array.elem "size" (std.record.fields value)
    in
    let Q = value.source == "memory"
    in
    if (impl P Q) && (impl Q P) then
      value
    else
      std.contract.blame_with_message "source = 'memory' <=> size is specified" label
  in
  std.contract.Sequence
    [
      {
        name | String,
        source | Source,
        uid | std.number.Nat | optional,
        gid | std.number.Nat | optional,
        size | (Unit std.number.PosNat) | optional
      },
      MemoryIFFSize
    ]
in
Array VolumeSchema
