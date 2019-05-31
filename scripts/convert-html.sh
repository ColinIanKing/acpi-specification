#!/bin/bash

# clean sphinx files
rm -f ../Makefile ../make.bat
rm -rf ../source ../build ../listTables

mkdir ../listTables

# run conversion
. rename-files-with-spaces.sh
. do-pandoc-1.sh
. gather-files.sh

# run linkcheck
pushd ..
make linkcheck
popd
