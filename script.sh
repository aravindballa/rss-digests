#!/bin/bash

# Create feeds directory if it doesn't exist
mkdir -p feeds

# Read sources from JSON file
sources=$(cat sources.json | jq -r '.[]')

# Loop through each source URL
for source in $sources; do
  # Check if the source has a custom name (format: name=url)
  if [[ $source == *=* ]]; then
    # Extract custom name and URL
    filename=$(echo "$source" | cut -d= -f1)
    url=$(echo "$source" | cut -d= -f2-)
  else
    # No custom name, use domain as filename
    url=$source
    filename=$(echo "$url" | sed -E 's/https?:\/\/([^\/]+).*/\1/' | sed 's/www\.//')
  fi
  
  echo "Fetching RSS feed from $url"
  # Fetch the RSS feed and save it to the feeds directory
  curl -s "$url" > "feeds/$filename.xml"
  
  # Check if the fetch was successful
  if [ $? -eq 0 ]; then
    echo "Successfully saved feed to feeds/$filename.xml"
  else
    echo "Failed to fetch feed from $url"
  fi
  
  # Add a small delay between requests to be nice to servers
  sleep 1
done

echo "All feeds have been fetched and saved to the feeds directory."