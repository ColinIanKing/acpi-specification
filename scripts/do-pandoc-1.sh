#!/bin/bash

# remove useless html
remove_useless_html()
{
    sed -i "/.. container::/d" $1
    sed -i "/^.. raw:: html/d" $1
    sed -i "/^   <\/div>/d" $1
    sed -i "/^   <div>/d" $1
}

# fix rubric to RST headings
do_headings()
{
    sed -i '/[[:space:]]*\.\. rubric:: \(.*\)/ {
        N
        N
        s/[[:space:]]*\.\. rubric::[[:space:]]*\(.*\)\n[[:space:]]*:name: \(.*\)\n[[:space:]]*:class: \(.*\)/\.\. _\2:\n\n\1\n\3 \1/
    }' $1

    # replace entire lines with symbols to create heading lines
    sed -i '/^Heading-1/s/./~/g' $1
    sed -i '/^Heading-2/s/./!/g' $1
    sed -i '/^Heading-3/s/./#/g' $1
    sed -i '/^Heading-4/s/./$/g' $1
    sed -i '/^ACPIHeading-4/s/./$/g' $1
    sed -i '/^Heading-5/s/./%/g' $1
    sed -i '/^Heading-6/s/./^/g' $1
    sed -i '/^Heading-7/s/./&/g' $1

    sed -i '/zHeading-1-Appendix/s/./%/g' $1
    sed -i '/zHeading-2-Appendix/s/./^/g' $1
    sed -i '/zHeading-3-Appendix/s/./&/g' $1
    sed -i '/zHeading-4-Appendix/s/./*/g' $1

    sed -i '/^GlossTerm/s/./(/g' $1
    sed -i '/^SubHeading/s/./)/g' $1
    sed -i '/^FigureTitle/s/./-/g' $1
    sed -i '/^TableTitle/s/./+/g' $1
}

# fixup links - they tend to span between 2-4 lines
do_links()
{
    # this sed command joins 2 lines into one line
    sed -i '/^[^|].*`\(.*\)/ {
        N
        s/`\(.*\)\n\(.*\)`__/`\1 \2`__/g
    }' $1

    # this sed command joins 3 lines into one line
    sed -i '/^[^|].*`\(.*\)/ {
        N
        N
        s/`\(.*\)\n\(.*\)\n\(.*\)`__/`\1 \2 \3`__/g
    }' $1

    # this sed command joins 4 lines into one line
    sed -i '/^[^|].*`\(.*\)/ {
        N
        N
        N
        s/`\(.*\)\n\(.*\)\n\(.*\)\n\(.*\)`/`\1 \2 \3 \4`/g
    }' $1

    # this sed command joins "" on the same line
    sed -i '/`__, “\(.*\)/ {
        N
        s/`__, “\(.*\)\n\(.*\)”/`__, “\1\2”/g
    }' $1

    # this sed command joins `__ and "" on the same line
    sed -i '/`__,/ {
        N
        s/`__,\n[[:space:]]*“\(.*\)”/`__, “\1”/g
    }' $1

    # this sed command eliminates contents inside of "" after a link.
    # They are useless.
    sed -i 's/`__,[[:space:]]*“.*”/`__/g' $1

    # this sed command replaces `See with `. The word "See" inside of a link is useless.
    sed -i 's/`See /`/g' $1

    # this sed command replaces the contents inside  <> with the title preceding the <. The material preceding <
    # contains the label for this link.
    sed -i 's/`\(.*\)\. <.*>`__/`\1\n<\1>`__\n/g' $1

    # This sed command replaces multiple spaces inside of links with a single space.
    # This is a clean up from joining the lines above.
    sed -i '/`.*`__/s/[[:space:]]\+/ /g' $1

    # Lower case all characters in <>
    sed -i 's/<\(.*\)>/<\L\1>/g' $1

    # Inside of <>, replace all spaces with - do this a bunch of times.

    sed -i '/<.*>`__/s/ /-/g' $1
    sed -i '/<.*>`__/s/[\*\\,(){}]//g' $1

    # this sed command joins 4 lines into one line
    sed -i '/`\(.*\)/ {
        N
        N
        s/`\(.*\)\n\(.*\)`__\n\(.*\)/:ref:`\1\2` \3/g
    }' $1
}

# convert grid tables to list tables for readablility
# take care of links inside of table entries
do_tables()
{
    ltname=LT"$2"
    # Convert Grid tables to list tables
    echo "Converting grid tables to list tables [$targetFilename]"
    ~/.local/bin/pandoc --list-tables --from html --to rst -o $ltname $1
    mv $ltname ../listTables/$ltname
}

rm -f *.rst
rm -f ../listTables/*.rst
for file in ../frameMakerOutput/*.htm; do
    targetFilename=`basename -s .htm $file`.rst
    echo "Converting $file to $targetFilename"

    # Translate html to rst
    pandoc --from html --to rst -o $targetFilename $file
    # Translate html to rst with list tables
    do_tables $file $targetFilename

    # There are useless HTML information contained in the rst files.
    # remove container, raw html, and div tags. these are useless html tags
    remove_useless_html $targetFilename

    # headings
    do_headings $targetFilename

    # links
    do_links $targetFilename

    # this sed command adds ref tags before links
    sed -i 's/ `\(.*\)`__/ :ref:`\1`/g' $targetFilename
    sed -i 's/ `\(.*\)`__/ :ref:`\1`/g' $targetFilename
    sed -i 's/ `\(.*\)`__/ :ref:`\1`/g' $targetFilename
    sed -i 's/ `\(.*\)`__/ :ref:`\1`/g' $targetFilename

done
