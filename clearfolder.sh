#!/bin/bash

# Path to the folder where old folders need to be deleted
folder="/home/msa/config"

# Name of the folder to be excluded from deletion
excluded_folder="!script"

# Current date and time in seconds since the epoch (UNIX timestamp)
current_time=$(date +%s)

# Iterate through all folders in the specified directory
for dir in "$folder"/*; do
    # Check if the item is a directory
    if [ -d "$dir" ]; then
        # Exclude the specific folder from deletion
        if [ "$(basename "$dir")" = "$excluded_folder" ]; then
            echo "Skipping folder: $dir"
            continue
        fi

        # Get the last modification time of the folder in seconds since the epoch
        last_modified=$(stat -c %Y "$dir")

        # Calculate the time difference between the current time and the last modification time
        time_diff=$((current_time - last_modified))

        # Check if the folder is older than 7 days (604,800 seconds)
        if [ "$time_diff" -gt 600 ]; then
            echo "Deleting folder: $dir"
            rm -rf "$dir"
        fi
    fi
done
