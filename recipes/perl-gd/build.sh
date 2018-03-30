#!/bin/bash

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' Makefile.PL

# ensure script fail on command fail
set -e -o pipefail

# If it has Build.PL use that, otherwise use Makefile.PL
if [ -f Build.PL ]; then
    perl Build.PL LIB=site \
        -options "JPEG,PNG,FT" \
        -lib_jpeg_path $PREFIX \
        -lib_ft_path $PREFIX \
        -lib_png_path $PREFIX \
        -lib_zlib_path $PREFIX

    sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' Build
    ./Build
    # disable non-portable test7
    sed -i.bak1 "s|IMAGE_TESTS => 7|IMAGE_TESTS => 6|1" ./t/GD.t
    sed -i.bak2 "s|tests => 11|tests => 10|1" ./t/GD.t
    ./Build test
    # Make sure this goes in site
    ./Build install --installdirs site
elif [ -f Makefile.PL ]; then
    # Make sure this goes in site
    perl Makefile.PL INSTALLDIRS=site \
        --options "JPEG,PNG,FT" \
        --lib_jpeg_path $PREFIX \
        --lib_ft_path $PREFIX \
        --lib_png_path $PREFIX \
        --lib_zlib_path $PREFIX

    make
    # disable non-portable test7
    sed -i.bak1 "s|IMAGE_TESTS => 7|IMAGE_TESTS => 6|1" ./t/GD.t
    sed -i.bak2 "s|tests => 11|tests => 10|1" ./t/GD.t
    make test
    make install
else
    echo 'Unable to find Build.PL or Makefile.PL. You need to modify build.sh.'
    exit 1
fi
