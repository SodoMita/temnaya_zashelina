#!/bin/bash

mods_folder="."

# Check if the mods folder exists
if [ ! -d "$mods_folder" ]; then
  echo "Mods folder not found: $mods_folder"
  exit 1
fi

# Iterate through each mod folder
for mod_folder in "$mods_folder"/*; do
  # Check if it's a directory
  if [ -d "$mod_folder" ]; then
    # Check if mod.conf already exists
    if [ ! -f "$mod_folder/mod.conf" ]; then
      # Create mod.conf with default content
      echo "name = $(basename "$mod_folder")" > "$mod_folder/mod.conf"
      echo "Mod.conf created for $(basename "$mod_folder")"
    fi
  fi
done

echo "Script executed successfully"

