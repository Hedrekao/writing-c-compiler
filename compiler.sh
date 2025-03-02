#!/bin/bash

MODE=$1

if [ "$MODE" != "--lex" ] && [ "$MODE" != "--parse" ] && [ "$MODE" != "--tacky" ] && [ "$MODE" != "--codegen" ] && [ "$MODE" != "--compile" ]; then
    INPUT_FILE=$MODE
    MODE="--compile"
else
    shift
    INPUT_FILE=$1
fi

INPUT_FILE=$(realpath $INPUT_FILE)

echo "Input file: $INPUT_FILE"
echo "Mode: $MODE"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found."
    exit 1
fi

# get the final name (remove extension), but keep the path
OUTPUT_FILE=$(echo $INPUT_FILE | sed 's/\(.*\)\..*/\1/')

# preprocess input file
gcc -E -P $INPUT_FILE -o $OUTPUT_FILE.i
if [ $? -ne 0 ]; then
    exit 1
fi

cd ./c_compiler
shift
mix run -- "$OUTPUT_FILE.i" "$MODE"
COMPILER_EXIT_CODE=$?
cd ..

rm $OUTPUT_FILE.i
if [ $COMPILER_EXIT_CODE -ne 0 ]; then
    exit $COMPILER_EXIT_CODE
fi

if [ "$MODE" != "--compile" ]; then
    exit 0
fi

gcc $OUTPUT_FILE.s -o $OUTPUT_FILE
rm $OUTPUT_FILE.s
if [ $? -ne 0 ]; then
    exit 1
fi

exit 0
