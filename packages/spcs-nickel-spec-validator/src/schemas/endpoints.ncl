let Port =
  std.contract.from_predicate
    (
      fun value =>
        std.is_number value
        && value
        % 1 == 0
        && value >= 0
        && value <= 65535
    )
in
Array { name | String, port | Port, public | Bool }
