#!/bin/bash

### This bash script creates a report listing variables
### contained in each file in your nginx configuration directory.
### It outputs the filename followed by a list of the
### variables and the line the variable appears in with their line numbers.

### TO USE:  1. Change the CONFDIR path below to the path where your nginx
###             configuration files are located. Default is 'etc/nginx'.
###	         2. Remember to chmod +x this file

## Report Header
fmt <<'EOF'
### Variables List ###

This is a list of the variables found in the configuration files.
A # at the beginnning of the line indicates it is disabled.
A ## at the beginning of the line indicates it is part of a comment.
Note that the same variable can appear more than once in a file 
and may appear in more than one file.

EOF

## Configuration section

# nginx configuration directory location
CONFDIR='/etc/nginx' # No trailing slash

## End configuration section

## Process files
# Print sorted unique variable list
printf "Variables list (alphabetical)\n"
VARLIST=$(egrep -r -o '\$[a-z,_-]+' --exclude=*.sh --exclude=*.txt $CONFDIR/* | \
         awk -F '[:]+' '{print $2 }' | sort | uniq | grep -v '^$')

for VAR in "${VARLIST[@]}"
do 
  printf "$VAR\n"
done

# Finds all instances of variables in each configuration file
egrep -r -o '\$[a-z,_-]+' --exclude=*.sh --exclude=*.txt $CONFDIR/* | \
         awk -F '[:]+' '{print $2 }' | sort | uniq | grep -v '^$' |
while read line
do
  # print variable name for report
  printf "\n"
  printf "Variable: $line\n"
  # prints out the line(s) from each file containing the variable
  eval "egrep -r -n '\\$line' --exclude=*.sh --exclude=*.txt $CONFDIR/*" | \
        sed 's/:[ 	]*/:/g' | sed 's/:/	Line /' | sed 's/:/  /'
done
