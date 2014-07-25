#!/bin/bash

echo "Generating appledocs..."
appledoc --project-name "GeoFire for iOS" \
--project-company "Firebase" \
--company-id com.firebase \
--create-html \
--keep-intermediate \
--output . \
--search-undocumented-doc \
./GeoFire/API/*.h
