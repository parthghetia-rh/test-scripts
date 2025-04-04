#!/bin/bash

# Prompt user for the variable name
echo "Enter the variable name (e.g., terminalOperator):"
read variable_name

# Directory containing YAML manifests
MANIFESTS_DIR="./"

# Loop through all YAML files in the directory
for file in "$MANIFESTS_DIR"/*.yaml; do
    if [ -f "$file" ]; then
        echo "Processing: $file"
        
        # Add the opening conditional at the beginning
        sed -i "1s/^/{{- if .Values.$variable_name.enabled -}}\n/" "$file"
        
        # Add the closing conditional at the end
        echo "{{- end }}" >> "$file"
    fi
done

echo "Processing complete!"
