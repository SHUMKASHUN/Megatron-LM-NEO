#!/bin/bash

name=$1
merge_dir=$2
TRAIN_DATA_PATH=$3
# Set the number of parallel processes you want to run
num_processes=4
if [ ! -d "./data/${name}" ]
then
    echo "not exist"
    mkdir -p ./data/${name}
    mkdir -p /mnt/hdfs/byte_data_seed_azureb_tteng/user/huangyuzhen/data_selection/data/${name}
else
    echo "exist"
fi;


# Find all files in the directory and process them in parallel
# find "$merge_dir" -maxdepth 1 -type f -name "*.json*" | xargs -P "$num_processes" -I {} bash -c '
#     preprocess_file() {
#         file="$1"

#         prefixfile=${file%%.json*}
#         prefixfile=${prefixfile##*/}
#         recovered_dir=${file%/*}
#         echo "Processing $prefixfile"
#         newname=${recovered_dir##*/}
#         python tools/preprocess_data.py \
#                    --input $recovered_dir/$prefixfile.jsonl \
#                    --output-prefix ${prefixfile}_${newname} \
#                    --tokenizer-model neo/tokenizer.model \
#                    --tokenizer-type SentencePieceTokenizer \
#                    --keep-sequential-samples \
#                    --append-eod \
#                    --workers 32 \
#                    --json-keys "text"
#         echo $newname
#         mv ./${prefixfile}_${newname}_text_document.bin /mnt/hdfs/byte_data_seed_azureb_tteng/user/huangyuzhen/data_selection/data/${newname}/
#         mv ./${prefixfile}_${newname}_text_document.idx /mnt/hdfs/byte_data_seed_azureb_tteng/user/huangyuzhen/data_selection/data/${newname}/

#         echo "Finished processing $prefixfile"

#     }   

#     preprocess_file "$0"
# ' "{}"


echo "All files processed"

INPUTPATH=${name}
OUTPUT_PREFIX=$4
OUTPUTPATH="${name}-merge"
if [ ! -d "/mnt/hdfs/byte_data_seed_azureb_tteng/user/huangyuzhen/data_selection/data/${OUTPUTPATH}" ]
then
    echo "not exist"
    mkdir -p /mnt/hdfs/byte_data_seed_azureb_tteng/user/huangyuzhen/data_selection/data/${OUTPUTPATH}
else
    echo "exist"
fi;

if [ ! -d "./data/${OUTPUTPATH}" ]
then
    echo "not exist"
    mkdir -p ./data/${OUTPUTPATH}
else
    echo "exist"
fi;
python tools/merge_datasets.py --input ${OUTPUT_PREFIX}$INPUTPATH --output-prefix ${OUTPUT_PREFIX}$OUTPUTPATH/$OUTPUTPATH
python tools/count_mmap_token.py --mmap_path ${TRAIN_DATA_PATH}$OUTPUTPATH/$OUTPUTPATH
