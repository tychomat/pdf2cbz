#!/bin/sh
# requires pdftocairo zip trash-cli
# version 1.0
# tychomat@gmail.com

# set TMP dir
TMP=~/Downloads

# set monitored dir
MON=/mnt/data1/Comics

# make txt file
find "$MON" -name "*.pdf" >"$TMP/list.txt"
sort -n -o "$TMP/list.txt" "$TMP/list.txt"
ListFile="$TMP/list.txt"

# check for pdf files
if [ ! -s "$TMP/list.txt" ]; then
	trash "$TMP/list.txt"
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
PdfCount=$(wc -l < "$TMP/list.txt")
CbzCount=$(wc -l < "$TMP/cbz_list.txt")

# cleanup
if [ "$PdfCount" -eq "$CbzCount" ]; then
	while IFS= read -r line; do
		trash "$line"
	done < "$TMP/list.txt"
	trash "$TMP/list.txt" "$TMP/cbz_list.txt"
	#echo "original files deleted"
else
	echo "original files not deleted, not as many cbz files created"
fi
