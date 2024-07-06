#!/bin/bash
perl Configure_modified
sed -e 's#configdata[.]pm#configdata_modified.pm#' -e "s#/Configure#/Configure_modified#" -e "s#/config#/config_modified#" -e "s#dofile[.]pl#dofile_modified.pl#" Makefile > Makefile_tmp
rm Makefile
mv Makefile_tmp Makefile
make
