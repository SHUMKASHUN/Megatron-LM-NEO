#!/bin/bash

name=$1
merge_dir=$2${name}
TRAIN_DATA_PATH=$3
# Set the number of parallel processes you want to run
num_processes=4
if [ ! -d "./data/${name}" ]
then
    echo "not exist"
    mkdir -p ./data/${name}
else
    echo "exist"
fi;


# Find all files in the directory and process them in parallel
find "$merge_dir" -maxdepth 1 -type f -name "*.json*" | xargs -P "$num_processes" -I {} bash -c '
    preprocess_file() {
        file="$1"

        prefixfile=${file%%.json*}
        prefixfile=${prefixfile##*/}
        recovered_dir=${file%/*}
        echo "Processing $prefixfile"
        python tools/preprocess_data.py \
                   --input $recovered_dir/$prefixfile.jsonl \
                   --output-prefix $prefixfile \
                   --tokenizer-model neo/tokenizer.model \
                   --tokenizer-type SentencePieceTokenizer \
                   --keep-sequential-samples \
                   --append-eod \
                   --workers 32 \
                   --json-keys "text"
        newname=${recovered_dir##*/}
        echo $newname
        mv ./${prefixfile}_text_document.bin ./data/${newname}/
        mv ./${prefixfile}_text_document.idx ./data/${newname}/

        echo "Finished processing $prefixfile"

    }   

    preprocess_file "$0"
' "{}"


echo "All files processed"

INPUTPATH=${name}
OUTPUTPATH="${name}-merge"
if [ ! -d "./data/${OUTPUTPATH}" ]
then
    echo "not exist"
    mkdir -p ./data/${OUTPUTPATH}
else
    echo "exist"
fi;
python tools/merge_datasets.py --input ${TRAIN_DATA_PATH}$INPUTPATH --output-prefix ${TRAIN_DATA_PATH}$OUTPUTPATH/$OUTPUTPATH
python tools/count_mmap_token.py --mmap_path ${TRAIN_DATA_PATH}$OUTPUTPATH/$OUTPUTPATH
