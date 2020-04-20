#!/bin/bash
#
# This script packages a release for the JobRouter Client
#

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ARCHIVE_DIR=archive

echo "Removing old folders and files ..."
rm -r "$PROJECT_DIR/vendor"
rm "$PROJECT_DIR/composer.lock"
rm "$PROJECT_DIR/$INFO_FILENAME"

echo "Install composer packages ..."
composer install --prefer-dist --no-dev --no-progress --no-suggest --working-dir="$PROJECT_DIR"

VERSION=$(grep -Po "(?<=private const VERSION = ')([0-9]+\\.[0-9]+\\.[0-9]+)" \
  $PROJECT_DIR/vendor/brotkrueml/jobrouter-client/src/Information/Version.php)

TAR_FILENAME=jobrouter-client-$VERSION.tar.gz
ZIP_FILENAME=jobrouter-client-$VERSION.zip
INFO_TEMPLATE_FILENAME=jobrouter-client-template.txt
INFO_FILENAME=jobrouter-client.txt

echo "Version of JobRouter Client: $VERSION"

echo "Writing info file ..."
cp "$PROJECT_DIR/$INFO_TEMPLATE_FILENAME" "$PROJECT_DIR/$INFO_FILENAME"
sed -i -- "s/##VERSION##/$VERSION/g" "$PROJECT_DIR/$INFO_FILENAME"

echo "Creating archives ..."
(cd "$PROJECT_DIR" && mkdir -p "$ARCHIVE_DIR")
(cd "$PROJECT_DIR" && tar acf "$ARCHIVE_DIR/$TAR_FILENAME" vendor "$INFO_FILENAME")
(cd "$PROJECT_DIR" && zip -r "$ARCHIVE_DIR/$ZIP_FILENAME" vendor "$INFO_FILENAME")

echo "Generating hash files ..."
(cd "$PROJECT_DIR/$ARCHIVE_DIR" && sha256sum "$TAR_FILENAME" > "$TAR_FILENAME.sha256.txt")
(cd "$PROJECT_DIR/$ARCHIVE_DIR" && sha256sum "$ZIP_FILENAME" > "$ZIP_FILENAME.sha256.txt")
