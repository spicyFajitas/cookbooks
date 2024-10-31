#!/bin/bash

# this script can take some time (~5-10 minutes)

# Function to display usage
usage() {
    echo "Usage: $0 source_directory destination_directory"
    exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    usage
fi

# Assigning the arguments to variables
SOURCE_DIR=$1
DEST_DIR=$2

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory '$SOURCE_DIR' does not exist."
    exit 1
fi

# Check if destination directory exists, create if it doesn't
if [ ! -d "$DEST_DIR" ]; then
    echo "Destination directory '$DEST_DIR' does not exist. Creating it now."
    mkdir -p "$DEST_DIR"
fi

# Get the base name of the source directory
BASE_NAME=$(basename "$SOURCE_DIR")

# Create a zip file with a timestamp from the source directory
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
ZIP_FILE="${BASE_NAME}_${TIMESTAMP}.zip"
zip -r "$ZIP_FILE" "$SOURCE_DIR"

# Move the zip file to the destination directory
mv "$ZIP_FILE" "$DEST_DIR"

echo "The contents of '$SOURCE_DIR' have been zipped and moved to '$DEST_DIR/$ZIP_FILE'."

# Prune old backups, keeping only the 12 most recent
cd "$DEST_DIR"
BACKUP_COUNT=$(ls -1 ${BASE_NAME}_*.zip 2>/dev/null | wc -l)

if [ "$BACKUP_COUNT" -gt 12 ]; then
    # Find and remove the oldest backups beyond the 12 most recent
    ls -1t ${BASE_NAME}_*.zip | tail -n +13 | xargs rm -f
    echo "Old backups pruned. Kept the most recent 12 backups."
else
    echo "No backups were pruned. Current backup count is $BACKUP_COUNT."
fi
