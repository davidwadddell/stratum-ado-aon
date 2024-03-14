// #######################
//  GGS VARIABLES
// #######################
var globalSchema = string(loadYamlContent('../../config/configuration_schemas/global_schemas.json'))
var instanceSchema = string(loadYamlContent('../../config/configuration_schemas/instance_schemas.json'))
var secretSchema = string(loadYamlContent('../../config/configuration_schemas/secret_schema.json'))

output outputGlobalSchema string = globalSchema
output outputInstanceSchema string = instanceSchema
output outputSecretSchema string = secretSchema
