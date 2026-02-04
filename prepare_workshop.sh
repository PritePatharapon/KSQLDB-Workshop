#!/bin/bash

# Check if a parameter is passed
if [ -z "$1" ]; then
    echo "Usage: $0 <suffix>"
    echo "Example: $0 test01"
    exit 1
fi

SUFFIX=$1
WORKSHOP_DIR="workshop_script"
ORIGINAL_DIR="orignal_script"

# 1. Force Clean Directory
if [ -d "$WORKSHOP_DIR" ]; then
    echo "Cleaning existing $WORKSHOP_DIR..."
    
    # Try rename first to break locks/handles if possible
    TEMP_DIR="${WORKSHOP_DIR}_TO_DELETE_$(date +%s)"
    mv "$WORKSHOP_DIR" "$TEMP_DIR" 2>/dev/null

    if [ -d "$TEMP_DIR" ]; then
         # If rename success, delete the temp dir
         rm -rf "$TEMP_DIR"
    else
         # If rename fail, try direct delete
         rm -rf "$WORKSHOP_DIR"
    fi

    # Check again
    if [ -d "$WORKSHOP_DIR" ]; then
        echo "Error: Could not remove '$WORKSHOP_DIR'. It might be locked by another process."
        echo "Please CLOSE ALL files/terminals using this folder and run again."
        exit 1
    fi
fi

# 2. Copy original folder
echo "Copying $ORIGINAL_DIR to $WORKSHOP_DIR..."
if [ ! -d "$ORIGINAL_DIR" ]; then
    echo "Error: Directory $ORIGINAL_DIR does not exist."
    exit 1
fi

# Use cp -r to create the directory as a copy
cp -r "$ORIGINAL_DIR" "$WORKSHOP_DIR"

# 3. Find and replace Table/Stream/Topic names
echo "Scanning for Stream, Table, and Topic names..."

# Extract CREATE STREAM/TABLE Names (field 3)
echo "Extracing Stream and Tables..."
STREAM_TABLE_NAMES=$(grep -r -i -E "^\s*CREATE\s+(STREAM|TABLE)\s+[a-zA-Z0-9_]+" "$WORKSHOP_DIR" | awk '{print $3}' | tr -d '`')

# Extract KAFKA_TOPIC values (between single quotes, assuming Format: KAFKA_TOPIC = 'XXXX')
echo "Extracing Topics..."
TOPIC_NAMES=$(grep -r -i "KAFKA_TOPIC" "$WORKSHOP_DIR" | awk -F"'" '{print $2}')

# Combine, clean, unique and sort by length descending
# sorting by length is critical to avoid partial replacements (e.g. replacing 'abc' inside 'abc_def')
NAMES=$(echo -e "$STREAM_TABLE_NAMES\n$TOPIC_NAMES" | sed '/^$/d' | sed 's/^[ \t]*//;s/[ \t]*$//' | sort | uniq | awk '{ print length, $0 }' | sort -rn | cut -d" " -f2-)

if [ -z "$NAMES" ]; then
    echo "No names found to rename."
else
    echo "Renaming items with suffix: _$SUFFIX"
    
    # Process each SQL file
    find "$WORKSHOP_DIR" -type f -name "*.sql" | while read -r file; do
        echo "Processing $file..."
        
        # Read file content
        for name in $NAMES; do
            # Replace whole word, case insensitive
            # sed -i is used here. 
            # Note: For strict word boundary matching regardless of case in sed, we use \b with I flag (GNU sed).
            
            sed -i "s/\b${name}\b/${name}_${SUFFIX}/gI" "$file"
        done
    done
fi

echo "Done. Workshop scripts are ready in $WORKSHOP_DIR"
