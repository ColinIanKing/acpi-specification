#!/bin/bash

# remove useless html
remove_useless_html()
{
    sed -i "/.. container::/d" $1
    sed -i "/^.. raw:: html/d" $1
    sed -i "/^   <\/div>/d" $1
    sed -i "/^   <div>/d" $1

    # make a copy of this. Useful for debugging
    cp $1 orig-"$1"
}

# fix rubric to RST headings
do_headings()
{
    sed -i '/[[:space:]]*\.\. rubric:: \(.*\)/ {
        N
        N
        s/[[:space:]]*\.\. rubric:: \(.*\)\n[[:space:]]*:name: \(.*\)\n[[:space:]]*:class: \(.*\)/RSTH \2: \1\n\3    \2:\1/
    }' $1

    # Awful sed script to replace heading text. I'm pretty sure python or perl would have been cleaner but this "does the trick"...
    # TODO: figure out how to do this more cleanly. This is very error prone and bad programming
    sed -i '/^Heading-1 .*/ y/\/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ()-01234:"“”,./====================================================================/' $1
    sed -i '/^Heading-2 .*/ y/\/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ()-01234:"“”,./--------------------------------------------------------------------/' $1
    sed -i '/^Heading-3 .*/ y/\/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ()-01234:"“”,./~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~/' $1
    sed -i '/^Heading-4 .*/ y/\/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ()-01234:"“”,./--------------------------------------------------------------------/' $1
    sed -i '/^ACPIHeading-4 .*/ y/\/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ()-01234:"“”,./--------------------------------------------------------------------/' $1
    sed -i '/^GlossTerm .*/ y/\/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ()-01234:"“”,./^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^/' $1
    sed -i '/^SubHeading .*/ y/\/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ()-01234:"“”,./++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++/' $1
    sed -i '/^FigureTitle .*/ y/\/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ()-01234:"“”,./++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++/' $1
    sed -i '/^TableTitle .*/ y/\/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ()-01234:"“”,./++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++/' $1
}

# fixup links - they tend to span between 2-4 lines
do_links()
{
    # this sed command joins 2 lines into one line
    sed -i '/`\(.*\)/ {
        N
        s/`\(.*\)\n\(.*\)`__/`\1 \2`__/g
    }' $1

    # this sed command joins 2 lines into one line
    sed -i '/`\(.*\)/ {
        N
        s/`\(.*\)\n\(.*\)”/`\1 \2”/g
    }' $1


    # this sed command joins 3 lines into one line
    sed -i '/`\(.*\)/ {
        N
        N
        s/`\(.*\)\n\(.*\)\n\(.*\)`__/`\1 \2 \3`__/g
    }' $1

    # this sed command joins 3 lines into one line
    sed -i '/`\(.*\)/ {
        N
        N
        s/`\(.*\)\n\(.*\)\n\(.*\)”/`\1 \2 \3”/g
    }' $1

    # this sed command joins 4 lines into one line
    sed -i '/`\(.*\)/ {
        N
        N
        N
        s/`\(.*\)\n\(.*\)\n\(.*\)\n\(.*\)”/`\1 \2 \3 \4”/g
    }' $1

    # WIP: replace the link with an approperiate name
    #sed -i 's/`.*`/REPLACE/g' $targetFilename
    #sed -i 's/\(`.\)\.htm/\1/g' $targetFilename
    #sed -i 's/see `See \(.*\)<.*>`__/see `\1<\1>`/g' $targetFilename
}

# convert grid tables to list tables for readablility
# take care of links inside of table entries
do_tables()
{
    # Convert Grid tables to list tables
    echo "Converting grid tables to list tables [$targetFilename]"
    ~/.local/bin/pandoc --list-tables --from rst --to rst -o LT"$1" $1

    # pandoc conversion doesn't retain labels so labels are nested inside of heading titles.
    # separate the label and heading title after conversion
    sed -i "s/^RSTH \(.*\):[[:space:]]*\(.*\)$/\.\. _\1:\n\2/g" LT"$1"

    # TODO: take care of links inside tables
}

git clean -f
for file in ../frameMakerOutput/*.htm; do
    targetFilename=`basename -s .htm $file`.rst
    echo "Converting $file to $targetFilename"
    pandoc --from html --to rst -o $targetFilename $file

    #remove container, raw html, and div tags. these are useless html tags
    remove_useless_html $targetFilename

    # headings
    do_headings $targetFilename

    # links
    do_links $targetFilename
    do_links $targetFilename
    do_links $targetFilename
    rm orig-*.rst

    #sed -i 's/^[^|].*`.*<.*>`__/\nREPLACE/g' $targetFilename
    # tables
    do_tables $targetFilename

done
