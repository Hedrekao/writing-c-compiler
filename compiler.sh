INPUT_FILE=$1
MODE=$2

# get the final name (remove extension), but keep the path
OUTPUT_FILE=$(echo $INPUT_FILE | sed 's/\(.*\)\..*/\1/')

# preprocess input file
gcc -E -P $INPUT_FILE -o $OUTPUT_FILE.i

# here will be mine compiler later it should return error code if any
gcc -S $OUTPUT_FILE.i -o $OUTPUT_FILE.s

rm $OUTPUT_FILE.i

# assemble the file
gcc $OUTPUT_FILE.s -o $OUTPUT_FILE
rm $OUTPUT_FILE.s

exit 0
