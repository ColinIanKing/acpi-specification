#!/bin/bash

for file in ../frameMakerOutput/*.htm; do
    targetFilename=`basename -s .htm $file`.rst
    echo "Converting $file to $targetFilename"
    pandoc --from html --to rst -o $targetFilename $file
done
