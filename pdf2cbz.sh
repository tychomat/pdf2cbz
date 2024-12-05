#!/bin/sh
# requires pdftocairo zip trash-cli
# version 1.1
# tychomat@gmail.com

# set TMP dir
TMP=~/Downloads

# set monitored dirs
MON1=/mnt/data1/Comics
MON2=/mnt/data1/Kids/Books/BD

# make txt file
find "$MON1" -name "*.pdf" >"$TMP/list1.txt"
find "$MON2" -name "*.pdf" >"$TMP/list2.txt"
cat "$TMP/list1.txt" "$TMP/list2.txt" >"$TMP/list.txt"
sort -n -o "$TMP/list.txt" "$TMP/list.txt"
ListFile="$TMP/list.txt"

# clean up temporary list1 and list2 files
trash "$TMP/list1.txt" "$TMP/list2.txt"

# check for pdf files
if [ ! -s "$ListFile" ]; then
        trash "$ListFile"
        exit
fi

# convert files
while IFS= read -r PdfFile; do
        [ -e "$PdfFile" ] || continue
        PdfBase=$(basename "$PdfFile")
        PdfDir=$(basename "$PdfBase" .pdf)
        SrcDir=$(dirname "$PdfFile")

        if [ ! -d "$TMP/$PdfDir" ]; then
                mkdir "$TMP/$PdfDir"
                #echo "$PdfDir temp directory created"
        else
                echo "$PdfDir temp directory exists. Something wrong with last conversion?"
        fi

        cp "$PdfFile" "$TMP/$PdfDir"
        #echo "Extracting PDF to images, sometimes takes a few minutes according to file size"
        pdftocairo -jpeg "$TMP/$PdfDir/$PdfBase" "$TMP/$PdfDir/$PdfDir"

        #echo "Creating CBZ archive"
        zip "$TMP/$PdfDir/$PdfDir.cbz" "$TMP/$PdfDir/"*.jpg > /dev/null
        if [ $? -ne 0 ]; then
                echo "Error: zip creation failed"
                continue
        fi
        mv "$TMP/$PdfDir/$PdfDir.cbz" "$SrcDir"
        echo "$SrcDir/$PdfDir.cbz done!" >> "$TMP/cbz_list.txt"
        trash "$TMP/$PdfDir/"
done < "$ListFile"

# compare lists
PdfCount=$(wc -l < "$ListFile")
CbzCount=$(wc -l < "$TMP/cbz_list.txt")

# cleanup
if [ "$PdfCount" -eq "$CbzCount" ]; then
        while IFS= read -r line; do
                trash "$line"
        done < "$ListFile"
        trash "$ListFile" "$TMP/cbz_list.txt"
        #echo "original files deleted"
else
        echo "original files not deleted, not as many cbz files created"
fi
