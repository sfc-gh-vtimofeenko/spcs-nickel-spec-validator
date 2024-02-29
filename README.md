This is a WIP project for a toy validator of [Snowpark container services
spec](https://docs.snowflake.com/en/developer-guide/snowpark-container-services/specification-reference)
written in [nickel](https://nickel-lang.org/)

SPCS schema validator using nickel.

# TODO

- [x] base schema
- [x] base validating script
- [x] schemas
  - [x] containers
  - [x] endpoints
  - [x] volumes
  - [x] logExporters
  - [x] Units
- [ ] add nix-based tests
- [ ] add GH action to run the test

# Notes

- Does not validate image path
