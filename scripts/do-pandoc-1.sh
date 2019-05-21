#!/bin/bash

for file in ../frameMakerOutput/*.htm; do
    targetFilename=`basename -s .htm $file`.rst
    echo "Converting $file to $targetFilename"
    pandoc --from html --to rst -o $targetFilename $file
    sed -i "/^.. raw:: html/d" $targetFilename
    sed -i "/^   <\/div>/d" $targetFilename
    sed -i "/^   <div>/d" $targetFilename
done
