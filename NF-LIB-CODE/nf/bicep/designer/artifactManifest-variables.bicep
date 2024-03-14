// #######################
//   SW VARIABLES
// #######################
var  helm_charts  = loadJsonContent('./swArtifactManifest-helm-charts.json')
var  image_list  = loadJsonContent('./swArtifactManifest-images.json')

var helmArtifacts = [for chart in helm_charts.charts: {
  artifactName: chart.name
  artifactType: 'OCIArtifact'
  artifactVersion: chart.version
}]
var imageArtifacts = [for image in image_list.images: {
  artifactName: image.name
  artifactType: 'OCIArtifact'
  artifactVersion: image.version
}]
var swArtifactList = union(helmArtifacts,imageArtifacts)

output outputSwArtifactList array = swArtifactList


// #######################
//   ARM VARIABLES
// #######################
var arm_template = loadJsonContent('./armArtifactManifest-arm.json')

var armArtifacts = [for template in arm_template.armTemplates: {
  artifactName: template.name
  artifactType: 'OCIArtifact'
  artifactVersion: template.version
}]

output outputArmArtifactList array = armArtifacts
