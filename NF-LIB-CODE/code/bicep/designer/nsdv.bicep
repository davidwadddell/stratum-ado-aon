// #######################
//   PARAMETERS
// #######################
param publisherName string
param armArtifactStoreName string
param nsdGroupName string
param globalcgSchemaName string
param instancecgSchemaName string
param appcgSchemaName string

param nsdvVersion string
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
module nsdvVariables '../../../nf/bicep/designer/nsdv-variables.bicep' = {
  name: moduleDeploymentName
  params: {
    armArtifactStoreid: armArtifactStore.id
  }
}

// #######################
//   RESOURCES
// #######################
resource publisher 'Microsoft.HybridNetwork/publishers@2023-09-01' existing = {
  name: publisherName
}

resource armArtifactStore 'Microsoft.HybridNetwork/publishers/artifactStores@2023-09-01' existing = {
  parent: publisher
  name: armArtifactStoreName
}

resource nsdg 'Microsoft.Hybridnetwork/publishers/networkservicedesigngroups@2023-09-01' existing = {
  parent: publisher
  name: nsdGroupName
}

resource globalcgSchema 'Microsoft.Hybridnetwork/publishers/configurationGroupSchemas@2023-09-01' existing = {
  parent: publisher
  name: globalcgSchemaName
}

resource instancecgSchema 'Microsoft.Hybridnetwork/publishers/configurationGroupSchemas@2023-09-01' existing = {
  parent: publisher
  name: instancecgSchemaName
}

resource appcgSchema 'Microsoft.Hybridnetwork/publishers/configurationGroupSchemas@2023-09-01' existing = {
  parent: publisher
  name: appcgSchemaName
}

resource nsdv 'Microsoft.Hybridnetwork/publishers/networkservicedesigngroups/networkservicedesignversions@2023-09-01' =  {
  name: nsdvVersion
  parent: nsdg
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
    description:  'NSD'
    configurationGroupSchemaReferences: {
      GlobalConfiguration: {
        id: globalcgSchema.id
      }
      SiteConfiguration: {
        id: instancecgSchema.id
      }
      AppConfiguration: {
        id: appcgSchema.id
      }
    }
    nfvisFromSite: {
      instance01: {
        name: '{configurationparameters(\'SiteConfiguration\').instance_values.nfviNameFromSite}'
        type: 'AzureArcKubernetes'
      }
    }
    resourceElementTemplates: [
      {
        name: 'armTemplate'
        type: 'NetworkFunctionDefinition'
        configuration: nsdvVariables.outputs.outputResrouceElementConfig
      }
    ]
  }
}
