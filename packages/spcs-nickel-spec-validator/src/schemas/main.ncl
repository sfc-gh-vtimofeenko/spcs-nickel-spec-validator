# SPCS spec schema
let SpecSchema = {
  containers
    | (import "./containers.ncl")
    | doc "https://docs.snowflake.com/en/developer-guide/snowpark-container-services/specification-reference#spec-containers-field-required",
  endpoints
    | (import "./endpoints.ncl")
    | doc "https://docs.snowflake.com/en/developer-guide/snowpark-container-services/specification-reference#spec-endpoints-field-optional"
    | optional,
  volumes
    | (import "./volumes.ncl")
    | doc "https://docs.snowflake.com/en/developer-guide/snowpark-container-services/specification-reference#spec-volumes-field-optional"
    | optional,
  logExporters
    | (import "./logExporters.ncl")
    | doc "https://docs.snowflake.com/en/developer-guide/snowpark-container-services/specification-reference#spec-logexporters-field-optional"
    | optional
}
in
{
  spec | SpecSchema
}
