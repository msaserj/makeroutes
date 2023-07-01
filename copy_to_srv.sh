#!/bin/bash

# Destination server details
destination_server="root@msaserj.ru"
destination_directory="/home/msa/makeroutes/"

# List of files to exclude
files=("clearfolder.sh" "domains" "makeroutes_srv.sh" "expect.sh")

# Loop through each file in the excluded files list
for filename in "${files[@]}"; do

    if [ -f "$filename" ]; then

        scp "$filename" "$destination_server:$destination_directory"
    fi
done
