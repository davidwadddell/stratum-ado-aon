// #######################
//   PARAMETERS
// #######################
param publisherName string
param swArtifactStoreName string
param nfdGroupName string

param nfdvVersion string
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
module nfdvVariables '../../../nf/bicep/designer/nfdv-variables.bicep' = {
  name: moduleDeploymentName
  params: {
    swArtifactStoreid: swArtifactStore.id
  }
}


// #######################
//   RESOURCES
// #######################
resource publisher 'Microsoft.HybridNetwork/publishers@2023-09-01' existing = {
  name: publisherName
  scope: resourceGroup()
}

resource swArtifactStore 'Microsoft.HybridNetwork/publishers/artifactStores@2023-09-01' existing = {
  parent: publisher
  name: swArtifactStoreName
}

resource nfdg 'Microsoft.Hybridnetwork/publishers/networkfunctiondefinitiongroups@2023-09-01' existing = {
  parent: publisher
  name: nfdGroupName
}

resource nfdv 'Microsoft.HybridNetwork/publishers/networkFunctionDefinitionGroups/networkFunctionDefinitionVersions@2023-09-01' = {
  name: nfdvVersion
  parent: nfdg
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
    deployParameters: string(nfdvVariables.outputs.outputNFDeployParameters)
    networkFunctionType: 'ContainerizedNetworkFunction'
    networkFunctionTemplate: {
      nfviType: 'AzureArcKubernetes'
      networkFunctionApplications: nfdvVariables.outputs.outputNfAppArray
    }
  }
}
