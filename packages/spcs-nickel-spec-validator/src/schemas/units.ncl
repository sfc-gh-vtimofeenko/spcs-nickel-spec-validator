fun label value =>
  let units = ["Ki", "Mi", "Gi", "k", "M", "G", "m"]
  in
  if std.is_number value then
    value | std.number.PosNat
  else if (std.array.elem (std.string.replace_regex "^\\d+" "" value) units) then
    value
  else
    std.contract.blame_with_message "Unrecognized units specified" label
