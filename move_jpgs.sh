#!/bin/bash

SOURCE_FOLDER=/path/to/OldFolder
DESTINATION_FOLDER=/path/to/NewFolder/

find $SOURCE_FOLDER -type f -iname '*.jpg' | while read file; do
    echo mv "$file" "$DESTINATION_FOLDER"
    mv $file $DESTINATION_FOLDER
done
