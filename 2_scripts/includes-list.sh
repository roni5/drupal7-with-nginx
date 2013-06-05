#!/bin/bash

###############################################################################
###
### This bash script creates a report listing the include directives
### contained in each file in your nginx configuration directory.
### It outputs the "calling" configuration file (that is, a file
### which contains an include directive) followed by a list of the
### include directives with their line numbers.
### 
###############################################################################

### TO USE:  1. Change the CONFDIR variable below to the path where your nginx
###             configuration files are located. Default is 'etc/nginx/'.
###             Be sure to include the trailing '/'.
###	     2. Remember to chmod +x this file

## Configuration section

# nginx configuration directory location
CONFDIR='/etc/nginx/'

## End configuration section

## Report Header
fmt <<'EOF'
###   Include Directives List   ###

This is a list of the include directives found in each calling
configuration file (that is, a file which contains an include directive)
followed by a list of the include directives with their line numbers.  
It is sorted by include filename (with relative path) then by line number.
A # in front of an include indicates it is disabled.

EOF

## Process files
# Finds all .conf files in CONFDIR and subdirectories that contain an
# include directive.
# Then splits on ':' using awk and uniqs first field to give
# the list of calling files.
find $CONFDIR -type f -name '*.conf' -print0 | \
	xargs -0 egrep -n 'include.*;' | \
	awk -F '[:]+' '{print $1}' | uniq | \
	while read line
		do
		# print calling file for report
   			printf "\n"
			echo "$line"
		# prints out include directives for each of the calling files
		# two sed statements deal with white space and '#'
		# so that result is in form of
		# callingfile.conf:Line#:(#)include:includefile.
		# An awk statement splits the line and puts it in the correct
		# order for the report.
		# Lines are then sorted by two keys, the first key is
		# the include file and the second key is the line number.
		# Then it's formatted to columns.
			egrep -n 'include.*;' $line | \
			sed 's/\#\s\+include/\#include/g' | \
			sed 's/( {1,50}|\t{1,10})/\:/g' | \
			awk -F '[:]+' '{print $2 " " $3 " " "Line " $1}' | \
			sort -k 2,3 -k 4n | \
			column -t
done
