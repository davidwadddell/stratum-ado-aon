
param swArtifactStoreid string

// #######################
//   NFDV VARIABLES
// #######################
var networkFunctionDeployParametersSchema = loadJsonContent('../../config/configuration_schemas/nf_parameters_schema.json')
output outputNFDeployParameters  object = networkFunctionDeployParametersSchema

var cert_manager_values = loadYamlContent('../../config/values-cert-manager.yml')

var nf2_nf_values = union(networkFunctionDeployParametersSchema,networkFunctionDeployParametersSchema)
output outputUdsfnfValues object = nf2_nf_values


var nfAppArray = [

        //CERT-MANAGER
        {
          artifactType: 'HelmPackage'
          name: 'cert-manager'
          dependsOnProfile: {
            installDependsOn: [
              'vendor-infra'
            ]
            uninstallDependsOn: [
              'certmanager-ca'
            ]
            updateDependsOn: [
              'vendor-infra'
            ]
          }
          artifactProfile: {
            artifactStore: {
              id: swArtifactStoreid
            }
            helmArtifactProfile: {
              helmPackageName: 'cert-manager'
              helmPackageVersionRange: '~1.5.5'
              registryValuesPaths: [ 'webhook.image.registry', 'image.registry', 'cainjector.image.registry', 'startupapicheck.image.registry' ]
              imagePullSecretsValuesPaths: [ 'global.imagePullSecrets' ]
            }
          }
          deployParametersMappingRuleProfile: {
            applicationEnablement: 'Enabled'
            helmMappingRuleProfile: {
              releaseNamespace: 'cert-manager'
              releaseName: 'cert-manager'
              helmPackageVersion: '1.5.5'
              values: string (cert_manager_values)
            }
          }
        }

        //CERTMANAGER-CA
        {
          artifactType: 'HelmPackage'
          name: 'certmanager-ca'
          dependsOnProfile: {
            installDependsOn: [
              'cert-manager'
            ]
            uninstallDependsOn: [
              'keycloak'
            ]
            updateDependsOn: [
              'cert-manager'
            ]
          }
          artifactProfile: {
            artifactStore: {
              id: swArtifactStoreid
            }
            helmArtifactProfile: {
              helmPackageName: 'certmanager-ca'
              helmPackageVersionRange: '~1.3.0'
              registryValuesPaths: [ 'global.registryPath' ]
              imagePullSecretsValuesPaths: [ 'global.imagePullSecrets' ]
            }
          }
          deployParametersMappingRuleProfile: {
            applicationEnablement: 'Enabled'
            helmMappingRuleProfile: {
              releaseNamespace: 'cert-manager'
              releaseName: 'certmanager-ca'
              helmPackageVersion: '1.3.0'
              values: string(cert_manager_values)
            }
          }
        }

        //KEYCLOAK
        {
          artifactType: 'HelmPackage'
          name: 'keycloak'
          dependsOnProfile: {
            installDependsOn: [
              'cert-manager'
            ]
            uninstallDependsOn: [
              'consul'
            ]
            updateDependsOn: [
              'cert-manager'
            ]
          }
          artifactProfile: {
            artifactStore: {
              id: swArtifactStoreid
            }
            helmArtifactProfile: {
              helmPackageName: 'keycloak-assembly'
              helmPackageVersionRange: '~1.22.4'
              registryValuesPaths: [ 'global.vendor.product.image.registry', 'global.vendor.thirdparty.image.registry', 'global.image.registry', 'gloo-kubernetes.gloo.gloo.deployment.image.registry' ]
              imagePullSecretsValuesPaths: [ 'global.imagePullSecrets' ]
            }
          }
          deployParametersMappingRuleProfile: {
            applicationEnablement: 'Enabled'
            helmMappingRuleProfile: {
              releaseNamespace: 'infrastructure'
              releaseName: 'keycloak'
              helmPackageVersion: '1.22.4'
            }
          }
        }

        //CONSUL
        {
          artifactType: 'HelmPackage'
          name: 'consul'
          dependsOnProfile: {
            installDependsOn: [
              'keycloak'
            ]
            uninstallDependsOn: [
              'consul-acl-setup'
            ]
            updateDependsOn: [
              'keycloak'
            ]
          }
          artifactProfile: {
            artifactStore: {
              id: swArtifactStoreid
            }
            helmArtifactProfile: {
              helmPackageName: 'consul'
              helmPackageVersionRange: '~0.49.0'
              registryValuesPaths: [ 'global.registryPath' ]
              imagePullSecretsValuesPaths: [ 'imagePullSecrets' ]
            }
          }
          deployParametersMappingRuleProfile: {
            applicationEnablement: 'Enabled'
            helmMappingRuleProfile: {
              releaseNamespace: 'consul'
              releaseName: 'consul'
              helmPackageVersion: '0.49.0'
            }
          }
        }

        //CONSUL-ACL
        {
          artifactType: 'HelmPackage'
          name: 'consul-acl-setup'
          dependsOnProfile: {
            installDependsOn: [
              'consul'
            ]
            uninstallDependsOn: [
              'rsyncd'
            ]
            updateDependsOn: [
              'consul'
            ]
          }
          artifactProfile: {
            artifactStore: {
              id: swArtifactStoreid
            }
            helmArtifactProfile: {
              helmPackageName: 'consul-acl-setup'
              helmPackageVersionRange: '1.5.4'
              registryValuesPaths: [ 'image.registry' ]
              imagePullSecretsValuesPaths: [ 'imagePullSecrets', 'global.imagePullSecrets' ]
            }
          }
          deployParametersMappingRuleProfile: {
            applicationEnablement: 'Enabled'
            helmMappingRuleProfile: {
              releaseNamespace: 'consul'
              releaseName: 'consul-acl-setup'
              helmPackageVersion: '1.5.4'
              //values: string(consul_acl_values)
            }
          }
        }

        //RSYNCD//
        {
          artifactType: 'HelmPackage'
          name: 'rsyncd'
          dependsOnProfile: {
            installDependsOn: [
              'consul-acl-setup'
            ]
            uninstallDependsOn: [
              'elastic-cloud-kubernetes-crds'
            ]
            updateDependsOn: [
              'consul-acl-setup'
            ]
          }
          artifactProfile: {
            artifactStore: {
              id: swArtifactStoreid
            }
            helmArtifactProfile: {
              helmPackageName: 'rsyncd'
              helmPackageVersionRange: '~2.8.0'
              registryValuesPaths: [ 'global.vendor.product.image.registry', 'global.vendor.thirdparty.image.registry' ]
              imagePullSecretsValuesPaths: [ 'imagePullSecrets' ]
            }
          }
          deployParametersMappingRuleProfile: {
            applicationEnablement: 'Enabled'
            helmMappingRuleProfile: {
              releaseNamespace: 'vendor-configuration'
              releaseName: 'rsyncd'
              helmPackageVersion: '2.8.0'
            }
          }
        }
]

output outputNfAppArray array =  nfAppArray
