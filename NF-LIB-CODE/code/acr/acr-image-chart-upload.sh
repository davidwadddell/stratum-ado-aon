#!/bin/bash

# Defining variables passed as parameters
source_acr_name=$1
source_acr_username=$2
source_acr_password=$3
destination_acr_name=$4
destination_acr_username=$5
destination_acr_password=$6
echo "source ACR Name within script: $source_acr_name"
echo "source ACR username within script: $source_acr_username"
# echo "source ACR password within script: $source_acr_password"
echo "destination ACR Name within script: $destination_acr_name"
echo "destination ACR username within script: $destination_acr_username"
# echo "destination ACR password within script: $destination_acr_password"
echo -e "\n\n"

echo "##[debug] Obtaining Source ACR List of Repositories"
az acr repository list --name $source_acr_name --username $source_acr_username --password $source_acr_password -o table
if [ $? -ne 0 ]; then
    echo "##[error] Not able to obtain Source ACR List of Repositories"
    exit 1
fi
az acr repository list --name $source_acr_name --username $source_acr_username --password $source_acr_password -o table |grep -v Result |grep -v -- "---" > source_repository
if [ $? -ne 0 ]; then
    echo "##[error] Not able to obtain Source ACR List of Repositories"
    exit 1
fi
echo -e "\n\n"

# LOOP THROUGH LIST OF SOURCE_TAGS AND DETERMINE TYPE
for repo in `cat source_repository`
do

    echo "##[group] Artifact being prepared is:  $repo"
    az acr repository show-tags --name $source_acr_name --username $source_acr_username --password $source_acr_password --repository $repo -o table |grep -v Result |grep -v -- "---" > source_tags

    # Depending on which type of artifact (helm chart, arm-template, or docker image) found in the list proceed accordingly
    for tag in `cat source_tags`
    do
        artifact_temp="temp_artifact"

        # HELM CHARTS
        if echo "$repo" | grep 'helm/'; then
            echo "##[command] Artifact found $repo is a helm chart, preparing to download/pull from source acr."

            # helm chart Pull from Source ACR
            echo "helm pull oci://$source_acr_name.azurecr.io/$repo --version $tag --username $source_acr_username --password $source_acr_password"
            helm registry login $source_acr_name.azurecr.io --username $source_acr_username --password $source_acr_password
            helm pull oci://$source_acr_name.azurecr.io/$repo --version $tag --username $source_acr_username --password $source_acr_password
            if [ $? -eq 0 ]; then
                echo "##[section] Succesfully pulled the helm chart"
            else
                echo "##[error] Not able to pull the helm chart"
                exit 1
            fi
            sleep 2

            # helm chart Push to Destination ACR
            echo -e "\n"
            echo "##[command] helm artifact preparing to push artifact to destination acr."
            helm registry login $destination_acr_name --username $destination_acr_username --password $destination_acr_password
            echo "${repo:5}"
            helm push "${repo:5}"-$tag.tgz oci://$destination_acr_name/helm/
            if [ $? -eq 0 ]; then
                echo "##[section] Succesfully pushed the helm chart"
            else
                echo "##[error] Not able to push the helm chart"
                exit 1
            fi
            rm -rf *.tgz


        # ARM-TEMPLATES
        elif echo "$repo" | grep 'arm-templates/'; then
            echo "##[command] Artifact found $repo is an arm-template, preparing to download/pull from source acr."

            # arm-template Pull from Source ACR
            oras pull $source_acr_name.azurecr.io/$repo:$tag --username $source_acr_username --password $source_acr_password > $artifact_temp
            if [ $? -eq 0 ]; then
                echo "##[section] Succesfully pulled the arm-template"
            else
                echo "##[error] Not able to pull the arm template"
                exit 1
            fi
            sleep 2

            # arm-template Push to Destination ACR
            echo -e "\n"
            echo "##[command] arm-template artifact preparing to push  to destination acr."
            oras push $destination_acr_name/$repo:$tag --username $destination_acr_username --password $destination_acr_password $artifact_temp
            if [ $? -eq 0 ];then
                echo "##[section] Succesfully pushed the arm-template"
            else
                echo "##[error] Not able to push the arm template"
                exit 1
            fi
            rm -rf *.json


        # DOCKER IMAGES
        else
            echo "##[command] Artifact found $repo is a docker image, preparing to download/pull from source acr."

            # Docker/Oras Image Pull from Source ACR
            oras login -u $source_acr_username -p $source_acr_password $source_acr_name.azurecr.io
            if [ $? -eq 0 ]; then
                oras cp --verbose --from-username $source_acr_username --from-password $source_acr_password  --to-username $destination_acr_username  --to-password $destination_acr_password $source_acr_name.azurecr.io/$repo:$tag $destination_acr_name/$repo:$tag
                if [ $? -eq 0 ]; then
                    echo "##[section] Succesfully oras copied the docker image from source acr to destination acr"
                else
                    echo "##[error] Not able to oras copy the docker image from source acr to destination acr"
                    exit 1
                fi
            else
                echo "##[error] Source oras login failed"
                exit 1
            fi

        fi
    done
    echo "##[endgroup]"
    echo  -e "\n"
done


# Code to import the arm-template that is currently located in the  repo
echo "##[debug] Preparing the arm-templates/ericsson-pc-controller found in LIB-CODE to push to Destination ACR"
cd $BUILD_SOURCESDIRECTORY/$libcodeRepo/code/arm-templates/
oras login -u $destination_acr_username -p $destination_acr_password $destination_acr_name
if [ $? -eq 0 ]; then
    oras push $destination_acr_name/arm-templates/ericsson-pc-controller:1.0.1 ericsson-pc-controller.json
    if [ $? -eq 0 ]; then
        echo "##[section] Succesfully pushed the arm template"
    else
        echo "##[error] Not able to push the arm template"
        exit 1
    fi
else
    echo "##[error] Destination oras login failed"
    exit 1
fi
echo  -e "\n\n"
