#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Generating appledocs..."
appledoc --project-name "GeoFire for iOS" \
--project-company "Firebase" \
--company-id com.firebase \
--no-create-docset \
--create-html \
--output "$DIR/site/" \
--search-undocumented-doc \
--exit-threshold 2 \
"$DIR"/GeoFire/API/*.h

echo "Renaming output folder"
rm -r "$DIR/site/docs"
mv "$DIR/site/html" "$DIR/site/docs"
