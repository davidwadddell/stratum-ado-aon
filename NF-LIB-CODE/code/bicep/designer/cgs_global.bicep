// #######################
//   PARAMETERS
// #######################
param publisherName string

param globalcgSchemaName string
param moduleDeploymentName string
param location string = resourceGroup().location


// ########TAGS###############
param correlation_id string
param env string
param automated_by string
param contact_dl string
param app string
param prog string
param nf_info string
param pipeline_info string
param service_info string
// #########TAGS##############


// #######################
//   VARIABLES via MODULES
// #######################
module cgsGlobalVariables '../../../nf/bicep/designer/cgs-variables.bicep' = {
  name: moduleDeploymentName
}

// #######################
//   RESOURCES
// #######################
resource publisher 'Microsoft.HybridNetwork/publishers@2023-09-01' existing = {
  name: publisherName
}

resource globalcgSchema 'Microsoft.Hybridnetwork/publishers/configurationGroupSchemas@2023-09-01' = {
  name: globalcgSchemaName
  parent: publisher
  location: location
  tags: {
    correlation_id: correlation_id
    env: env
    automated_by:  automated_by
    contact_dl: contact_dl
    app: app
    prog: prog
    nf_info: nf_info
    pipeline_info: pipeline_info
    service_info: service_info
  }
  properties: {
    schemaDefinition: cgsGlobalVariables.outputs.outputGlobalSchema
  }
}
