#!/bin/bash

cd "$(dirname "$0")"

npm install

NAME=FQP
PEG_FILE=${NAME}.pegjs
NODE_JS_FILE=${NAME}.js
SRC_DIR=src
DIST_DIR=dist
WORK_DIR=work

# build parser
mkdir ${WORK_DIR}
./node_modules/pegjs/bin/pegjs --export-var PEG ${PEG_FILE} ${WORK_DIR}/${NODE_JS_FILE}

# concate the filter-query.js with ${NAME}.js and move to dist folder
cat ${WORK_DIR}/${NODE_JS_FILE} ${SRC_DIR}/filter-query.js > ${DIST_DIR}/${NODE_JS_FILE}

# cleanup
rm -rf work
