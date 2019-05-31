#!/bin/bash

for file in ../frameMakerOutput/*; do mv "$file" `echo $file | tr ' ' '_'` > /dev/null 2> /dev/null; done
