#!/bin/bash

# read -p "enter the path to json file to parse" json_input

json_input=$1
managedimagename=$2
subId=$3
rgName=$4
textToRemove="/subscriptions/${subId}/resourceGroups/${rgName}/providers/Microsoft.Compute/images/"
replacetext=""
#echo "managedimagename: ${managedimagename},${subId} , ${rgName}"
#echo "text to replace is $textToRemove, replacer is $replacetext"


filecontent=$(cat < $json_input)
imageId=$(cat < $json_input | jq '.builds[0].artifact_id')
tt="\/"
tr=""
#imagenamelength=${#managedimagename}

realImageId="${imageId/${textToRemove}/${replacetext}}"


jq -n \
    --arg imagename "$realImageId" \
    --arg artifactId "${imageId}/${tt}/${tr}" \
    '{imagename:$imagename,artifactid:$artifactId}'

#echo $imageId
#jq -n "{"imagename": $realImageId, "artifactid":$imageId}"
#echo $output

# echo "imageId is: ${imageId}"