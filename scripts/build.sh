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

mkdir -p $ROOT_DIR/terraform/input
mkdir -p $ROOT_DIR/terraform/output

########################################################################################
# Build and copy to target
########################################################################################

TARGET_DIR=$ROOT_DIR/terraform/input
LAMBDAS=("command-lambda" "interaction-lambda")

for LAMBDA in ${LAMBDAS[@]}
do
    log "Building $LAMBDA"
    cd $ROOT_DIR/$LAMBDA;
    npm install;
    npm run compile;
    npm run postcompile;
    cd $ROOT_DIR;
    # log "Creating symbolic link for $LAMBDA"
    # ln -sF "${ROOT_DIR}/${LAMBDA}/build/" "${TARGET_DIR}/${LAMBDA}"
    log "Copying files to target for $LAMBDA"
    mkdir -p ${TARGET_DIR}/${LAMBDA}
    cp -r ${ROOT_DIR}/${LAMBDA}/build/* ${TARGET_DIR}/${LAMBDA}
done
