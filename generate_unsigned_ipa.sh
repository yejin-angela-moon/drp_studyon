#!/bin/bash

set -e

# Paths
ARCHIVE_PATH="./output/archive/StudyOn.xcarchive"
IPA_OUTPUT_PATH="./output/ipa"

# Create the Payload directory
mkdir -p "${IPA_OUTPUT_PATH}/Payload"

# Print the contents of the archive directory for debugging
echo "Contents of ${ARCHIVE_PATH}:"
ls -R "${ARCHIVE_PATH}"

# Ensure the .app directory exists
APP_PATH="${ARCHIVE_PATH}/Products/Applications/StudyOn.app"
if [ ! -d "${APP_PATH}" ]; then
  echo "App bundle not found at ${APP_PATH}"
  exit 1
fi

# Copy the .app bundle to the Payload directory
cp -R "${APP_PATH}" "${IPA_OUTPUT_PATH}/Payload/"

# Create the unsigned IPA
cd "${IPA_OUTPUT_PATH}" && zip -r "StudyOn.ipa" "Payload"

echo "Unsigned IPA created at ${IPA_OUTPUT_PATH}/StudyOn.ipa"
