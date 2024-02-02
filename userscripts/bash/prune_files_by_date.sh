#!/bin/bash
# @author   spicyFajitas
# @date     2024-02-02
# @usage:   ./prune_files_by_date.sh /path/to/directory/ | tee log.txt
#
# @note:    need to set date to match and enable `rm` command below

# Check if the directory path is provided as a command-line argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Get the directory path from the command-line argument
directory_path="$1"

# Check if the provided path is a directory
if [ ! -d "$directory_path" ]; then
    echo "Error: '$directory_path' is not a valid directory."
    exit 1
fi

# Remove trailing forward slash if present
directory_path="${directory_path%/}"

# Set the target date in the format used by the 'ls' command (without time)
target_date="<set date here>"

# List files and directories in the directory with detailed information, sorted by modification time
ls_output=$(ls -laht --time-style=+"%b %d %Y" "$directory_path")

# Use grep to filter items based on the target date
filtered_items=$(echo "$ls_output" | grep "$target_date")

# Loop through each line of the filtered output
while IFS= read -r item_info; do
    # Extract the type, modification date, and time using 'awk'
    item_type=$(echo "$item_info" | awk '{print $1}')
    item_date=$(echo "$item_info" | awk '{print $6, $7}')
    item_time=$(echo "$item_info" | awk '{print $8}')

    # Check if the item's modification date matches the target date
    if [ "$item_date" == "$target_date" ]; then
        # Extract the item name and construct the full path to the item
        item_name=$(echo "$item_info" | awk '{$1=$2=$3=$4=$5=$6=$7=$8=""; print $0}' | sed -e 's/^[ \t]*//')
        item_path="$directory_path/$item_name"

        # Delete the item using 'rm' based on its type
        # NOTE: uncomment the lines with the `rm` command to enable deletion
        if [ "$item_type" == "drwx------" ]; then
            # Delete directory
            #sudo rm -r "$item_path"
            echo "Deleted directory: $item_info"
        elif [ "$item_type" == "-rw-------" ]; then
            # Delete file
            #sudo rm "$item_path"
            echo "Deleted file: $item_info"
        fi
    fi
done <<< "$filtered_items"