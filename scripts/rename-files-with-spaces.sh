#!/bin/bash

for file in ../frameMakerOutput/*; do mv "$file" `echo $file | tr ' ' '_'` ; done
