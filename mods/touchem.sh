#!/bin/bash


for mod in *; do
    touch $mod/init.lua
done

echo "Init.lua files created for all mods."

