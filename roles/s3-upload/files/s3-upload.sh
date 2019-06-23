#!/usr/bin/env bash

SOURCE_DIR=$1
DEST=$2
INCLUDE_PATTERN=$3
UNTIL_DATE=$(date +%Y-%m-%d -d '7 day ago')

log() {
  echo $1
}

if [[ "$#" -ne 3 ]]; then
  log "Usage: $0 <source_dir> <destination_bucket> <include_pattern>"
  exit 1
fi

if [[ ! ${DEST} =~ /$ ]]; then
  log "Destination should end with '/'!"
  exit 1
fi

log "Moving files older than ${UNTIL_DATE} from ${SOURCE_DIR} to ${DEST} using pattern ${INCLUDE_PATTERN}.."

SOURCE_FILES=$(find ${SOURCE_DIR} -type f -name "${INCLUDE_PATTERN}" -not -newermt ${UNTIL_DATE} | sort)

for SRC in ${SOURCE_FILES}; do
  COMPRESSED_SRC=/tmp/$(basename ${SRC}).gz
  trap "rm -f ${COMPRESSED_SRC}; exit 1" 1 2 3 9 13 15
  log "Compressing ${SRC} to ${COMPRESSED_SRC}"
  nice gzip -c ${SRC} > ${COMPRESSED_SRC}
  log "Moving ${COMPRESSED_SRC} to ${DEST}"
  aws s3 mv ${COMPRESSED_SRC} ${DEST}
  RET=$?
  if [[ ${RET} -eq 0 ]]; then
    log "Success, removing ${SRC}"
    rm -f ${SRC}
  fi
  rm -f ${COMPRESSED_SRC}
done

exit 0