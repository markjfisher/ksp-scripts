#!/bin/bash

if [ ! -d scripts/lib ]; then
  mkdir scripts/lib
fi

if [ ! -d scripts/missions ]; then
  mkdir scripts/missions
fi

function minify_dir() {
  local d=$1
  echo "minifying $d"
  find $d -name \*.ks | while read f; do
    TARGET=${d//_src/}
    echo "Minifying $f to $TARGET/$(basename $f)"
    ./minKS.sh $f > $TARGET/$(basename $f)
  done
}

minify_dir scripts/lib_src
minify_dir scripts/missions_src