#!/bin/bash

if [[ ! -d "terraform" ]]
then
    echo "not in root directory"
    return 1
fi

ROOT_DIR=$(pwd)

function log(){
    echo "##################################    \
    $1\
        ##################################"
}

########################################################################################
# Build and copy to target
########################################################################################

TARGET_DIR=$ROOT_DIR/terraform/input
NODE_DIRS=("command-lambda" "interaction-lambda")

for DIR in ${NODE_DIRS[@]}
do
    log "Creating archive for $DIR"
    cd $ROOT_DIR/$DIR;
    npm install;
    npm run compile;
    cd $ROOT_DIR;
    zip -j $TARGET_DIR/$DIR.zip $DIR/build/*
    find $DIR/build -type f \( -exec sha256sum "$PWD"/{} \; \) | awk '{print $1}' | sort | sha256sum > terraform/input/$DIR.sha256sum
done
