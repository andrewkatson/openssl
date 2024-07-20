#!/bin/bash

# Ensure that the script exits if any command fails
set -e

# Use single quotes for the sed commands and escape necessary characters
sed -e 's#external/perl/MODULES.txt#external/external~/perl/MODULES.txt#' \
    -e 's#die \\"[*]\\{5\\} Unsupported options:#warn \\"***** Unsupported options:#' Configure > Configure_modified
sed -e 's#'"'"'external'"'"', '"'"'perl'"'"', '"'"'MODULES.txt'"'"'#'"'"'external'"'"', '"'"'external~'"'"', '"'"'perl'"'"', '"'"'MODULES.txt'"'"'#' configdata.pm.in > configdata_modified.pm.in
sed -e 's#external/perl/MODULES.txt#external/external~/perl/MODULES.txt#' util/dofile.pl > util/dofile_modified.pl

# Move modified files to their original names
rm util/dofile.pl
mv util/dofile_modified.pl util/dofile.pl
rm configdata.pm.in
mv configdata_modified.pm.in configdata.pm.in
rm Configure 
mv Configure_modified Configure

# Run the perl Configure script and make
perl Configure
make

# Run tests if the first argument is "true"
if [[ $1 == "true" ]]; then
    make test
fi