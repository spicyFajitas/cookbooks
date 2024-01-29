#!/bin/bash
###############################################################################
## Author:  @spicyFajitas
## Date:    2023-09-14
## Desc:    Takes raw files clumped in a folder and puts 
## Desc:    each individual file into it's own folder.
## Desc:    This will not change the directory of the files, only put them
## Desc:    in a sub-directory of the same title.
## Usage:   `./movie_move.sh /mnt/path/to/directory`
###############################################################################

if [ $# -ne 1 ]; then
    echo "Usage: $0 <folder_path>"
    exit 1
fi

folder_path="$1"

if [ ! -d "$folder_path" ]; then
    echo "Error: Folder '$folder_path' does not exist."
    exit 1
fi

for filename in "$folder_path"/*; do
    if [ -f "$filename" ]; then
        base_filename=$(basename "$filename")
        folder_name="${base_filename%.*}"
        new_folder_path="$folder_path/$folder_name"

        sudo mkdir -p "$new_folder_path"
        sudo mv "$filename" "$new_folder_path"
        echo "Moved '$base_filename' to '$new_folder_path'"
    fi
done
