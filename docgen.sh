#!/bin/bash

# Build solidity-docgen if dist is missing
cd lib/solidity-docgen/
if [ ! -d "./dist" ]; then yarn; fi
cd -

# Build solc if dist is missing
cd lib/solc-js
if [ ! -d "./dist" ]; then 
  yarn 
  yarn updateBinary
  yarn build
fi
cd -

# Save remappings in list
remappings=()
while read -r line; do
  dir=$(sed 's/\//\\\//g' <<< $(pwd)); # Escape slashes for current absolute dir
  remappings+=($(sed "s/=/=$dir\//g" <<< $line)); # Replace remappings with absolute dir
done < remappings.txt
remappingsJSON=$(printf '%s\n' "${remappings[@]}" | jq -R . | jq --compact-output -s .)

# Build docs
node ./lib/solidity-docgen/dist/cli \
   -i src \
   -t templates \
   --solc-module ./lib/solc-js/dist \
   --solc-settings "{\"optimizer\": {\"enabled\": true, \"runs\": 200}, \"remappings\": $remappingsJSON}"
