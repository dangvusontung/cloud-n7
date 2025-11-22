#!/bin/bash

set -euo pipefail

# Parse command line arguments
TARGET_SIZE_MB="${1:-100}"

# Validate that target size is a positive number
if ! [[ "$TARGET_SIZE_MB" =~ ^[0-9]+$ ]] || [[ $TARGET_SIZE_MB -le 0 ]]; then
    echo "Usage: $0 [TARGET_SIZE_MB]"
    echo "  TARGET_SIZE_MB: Target file size in megabytes (default: 100)"
    echo "  Example: $0 200  # Creates a 200MB file"
    exit 1
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SOURCE_FILE="${SCRIPT_DIR}/../ansible/examples/filesample_light.txt"
OUTPUT_FILE="${SCRIPT_DIR}/../ansible/examples/filesample.txt"
TARGET_SIZE_BYTES=$((TARGET_SIZE_MB * 1024 * 1024))

# Check if source file exists
if [[ ! -f "$SOURCE_FILE" ]]; then
    echo "Error: Source file '$SOURCE_FILE' not found"
    exit 1
fi

# Get source file size
SOURCE_SIZE=$(stat -f%z "$SOURCE_FILE" 2>/dev/null || stat -c%s "$SOURCE_FILE" 2>/dev/null)
if [[ -z "$SOURCE_SIZE" ]]; then
    echo "Error: Could not determine source file size"
    exit 1
fi

echo "Source file: $SOURCE_FILE"
echo "Source file size: $((SOURCE_SIZE / 1024 / 1024))MB"
echo "Target size: ${TARGET_SIZE_MB}MB"
echo "Output file: $OUTPUT_FILE"
echo ""

# Remove output file if it exists
if [[ -f "$OUTPUT_FILE" ]]; then
    echo "Removing existing output file..."
    rm "$OUTPUT_FILE"
fi

# Create new output file by copying content from light file
echo "Creating new file by copying content from light file..."
cat "$SOURCE_FILE" > "$OUTPUT_FILE"

# Get current output file size
CURRENT_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null)
ITERATION=1

# Keep copying content until we reach target size
while [[ $CURRENT_SIZE -lt $TARGET_SIZE_BYTES ]]; do
    # Calculate how much more we need
    REMAINING=$((TARGET_SIZE_BYTES - CURRENT_SIZE))
    
    # If remaining is less than source size, we're almost done
    if [[ $REMAINING -lt $SOURCE_SIZE ]]; then
        # Copy one more time and stop
        cat "$SOURCE_FILE" >> "$OUTPUT_FILE"
        break
    fi
    
    # Copy content from source file to output
    cat "$SOURCE_FILE" >> "$OUTPUT_FILE"
    
    # Update current size
    CURRENT_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null)
    
    ITERATION=$((ITERATION + 1))
    
    # Show progress every 10 iterations
    if [[ $((ITERATION % 10)) -eq 0 ]]; then
        CURRENT_SIZE_MB=$((CURRENT_SIZE / 1024 / 1024))
        echo "Iteration $ITERATION: Current size ${CURRENT_SIZE_MB}MB / ${TARGET_SIZE_MB}MB"
    fi
done

# Final size check
FINAL_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null)
FINAL_SIZE_MB=$((FINAL_SIZE / 1024 / 1024))

echo ""
echo "Done! Final file size: ${FINAL_SIZE_MB}MB"
echo "Total iterations: $ITERATION"
echo "Output file: $OUTPUT_FILE"

