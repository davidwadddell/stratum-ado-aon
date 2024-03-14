
param armArtifactStoreid string

// #######################
//   NSDV VARIABLES
// #######################
var resourceElementArray = {
      templateType: 'ArmTemplate'
      parameterValues: '{"global_values": "{configurationparameters(\'GlobalConfiguration\').global_values}","app_values": "{configurationparameters(\'AppConfiguration\').app_values}","instance_values": "{configurationparameters(\'SiteConfiguration\').instance_values}", "nfvId": "{nfvis(\'instance01\').customLocationReference.id}"}'
      artifactProfile: {
        artifactStoreReference: {
          id: armArtifactStoreid
        }
        artifactName: 'arm-manifest'
        artifactVersion: '1.0.0'
      }
  }

output outputResrouceElementConfig object =  resourceElementArray
