#!/bin/bash

# Ensure that the script exits if any command fails
set -e

# Perform sed replacements
sed -e 's#external/perl/MODULES.txt#external/external~/perl/MODULES.txt#' \
    -e 's#die \"[*]\\{5\\} Unsupported options:#warn \"***** Unsupported options:#' Configure > Configure_tmp

sed -e "s#'external', 'perl', 'MODULES.txt#'external', 'external~', 'perl', 'MODULES.txt#" configdata.pm.in > configdata.pm.in_tmp

sed -e "s#external/perl/MODULES.txt#external/external~/perl/MODULES.txt#" util/dofile.pl > util/dofile.pl_tmp

# Move modified files to their original names
mv util/dofile.pl_tmp util/dofile.pl
mv configdata.pm.in_tmp configdata.pm.in
mv Configure_tmp Configure

# Run the perl Configure script and make
perl Configure no-comp no-idea no-weak-ssl-ciphers
make

# Run tests if the first argument is "true"
if [[ $1 == "true" ]]; then
    make test
fi
