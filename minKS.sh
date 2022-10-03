#!/bin/bash

# I tried to reduce this to a single perl script but it kept failing.

if [ $# -ne 1 ] ; then
  echo "Usage: $(basename $0) file.ks > outfile.ks"
  exit 1
fi

IN_FILE=$1
if [ ! -f $IN_FILE ] ; then
  echo "Error: Could not find $1"
  exit 1
fi

sed < $IN_FILE -r '
  s#//.*##;               # comments
  s#\t# #g;               # first convert tabs to spaces
  s#[ ]+# #g;             # multiple spaces to single
  s#^\s*(.*)#\1#;         # spaces at start of line
  s#\{ #{#g;              # { brackets with space after
  s# \}#}#g;              # } brackets with space before
  s# ?\+ ?#+#g;           # whitespace around +
  s# ?- ?#-#g;            # whitespace around -
  s# ?= ?#=#g;            # whitespace around =
  s# ?< ?#<#g;            # whitespace around <
  s# ?> ?#>#g;            # whitespace around >
  s# ?\/ ?#\/#g;          # whitespace around /
  s# ?\* ?#*#g;           # whitespace around *
  s#, #,#g;               # whitespace after ,
  s# \{#{#g;              # remove space before {
  /^$/d                   # empty lines
  ' | \
# this stops us from pulling everything into perl, equivalent in perl merges files differently and I can't be arsed to work out why
sed ':a;N;$!ba;s#\n##g;   # remove all remaining \n' | \
# and finally deal with lookahead, which sed can't do
perl -pe '
  # (char or num).char e.g. "local x is x1 and x2.if x"
  # split at the fullstop, but not inside quotes like import("foo.bar")
  # from https://stackoverflow.com/questions/6462578/regex-to-match-all-instances-not-inside-quotes
  s#([a-z][a-z0-9]*)\.([a-z])(?=([^"]*"[^"]*")*[^"]*$)#\1. \2#gi;

  # split cases like "tr:freeze.local" after the fullstop, but not "ship:availablethrust<0.1", alternate would be to ensure between : and . there is only text
  s# ([^:]+:[^.]+\.(?![0-9]))([^ }])# \1 \2#gi;

  s#[ ]+# #g;          # re-remove double spaces that crept in.
  s#([\)}]\.) #\1#g;   # "). " or "}. " remove space
'