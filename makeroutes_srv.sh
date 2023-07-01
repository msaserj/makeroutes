#!/bin/bash

cd /home/msa/makeroutes/

# Get current date and time
timestamp=$(date +%Y%m%d_%H%M)

# Name of the file with domain names
# Create it if it doesn't exist, and specify one domain name per line
domains_file="domains"
# Temporary files
tmp_bat="temp.bat"
tmp_cli="temp.cli"

mkdir "/home/msa/config/$timestamp/"

# File names for writing routes using web-interface and cli commands with expect.sh script
routes_bat="/home/msa/config/$timestamp/routes.bat"
routes_cli="/home/msa/config/$timestamp/routes.cli"

# Check if the domains file exists
if [ ! -f "$domains_file" ]; then
    echo "File with domains '$domains_file' not found."
    exit 1
fi

# Clear route files (if they exist)
> "$routes_bat"
> "$routes_cli"

# Loop through each line in the domains file
while IFS= read -r domain || [[ -n "$domain" ]]; do

    # Skip empty lines
    if [[ -z "$domain" ]]; then
        continue
    fi

    # Get only IP addresses without any CDNs
    ip_addresses=$(dig +short "$domain" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}')
    echo "$domain" $ip_addresses

    # Sometimes there can be a communications error, so we redo it
    if [[ $ip_addresses == *"communications error"* ]]; then
        echo "############"
        echo "communications error! for domain $domain"
        echo "############"
        sleep 1
        echo "REPEAT :-)"
        sleep 1
        ip_addresses=$(dig +short "$domain" | grep -E '([0-9]{1,3}\.){3}[0-9]{1,3}')
        echo "$domain" $ip_addresses
    fi

    # Loop through each IP address
    while IFS= read -r ip_address || [[ -n "$ip_address" ]]; do

        # Write static route to the file
        echo "route ADD $ip_address MASK 255.255.255.255 0.0.0.0" >> "$tmp_bat"
        echo "ip route $ip_address 255.255.255.255 0.0.0.0 Wireguard0 auto !script_address" >> "$tmp_cli"
    done <<< "$ip_addresses"
done < "$domains_file"

echo "############"
echo "DEL DUPLICATES"
echo "############"
sleep 1

sort "$tmp_bat" | uniq > "$routes_bat"
sort "$tmp_cli" | uniq > "$routes_cli"

rm temp.cli
rm temp.bat

echo "#### OK! ####"
sleep 2
