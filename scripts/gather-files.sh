#!/bin/bash

echo "Invoking sphinx-quickstart, press the default options at the menu for now"
sphinx-quickstart --sep -p "ACPI-Specification" -a ASWG -v 6.3 -r 6.3 -l en --suffix .rst --master index.rst ..
rm Index.rst
mv *.rst ../source
mv ../index.rst ../source
