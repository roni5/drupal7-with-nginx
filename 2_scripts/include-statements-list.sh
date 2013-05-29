#!/bin/bash

###############################################################################
### This bash script creates a report listing the include statements
### contained in each file in your nginx configuration directory.
### It outputs the "calling" configuration file (that is, a file
### which contains an include statement) followed by a list of the
### include statements with their line numbers.  report to
### a file called include-statements.txt in your nginx configuration
### directory.
###############################################################################

### TO USE:  1. Change the DIR path below to the path where your nginx
###             configuration files are located. Default is 'etc/nginx'.
###	     2. Remember to chmod +x this file

## Configuration section

# nginx configuration directory location
DIR='/etc/nginx/'

## End configuration section

## Report Header
printf "### Include Statments List ###\n\n"
fmt <<'EOF'

This is a list of the include statements found in each calling
configuration file (that is, a file which contains an include statement)
followed by a list of the include statements with their line numbers.
A # in front of an include indicates it is disabled.
EOF

## Process files
# Finds all .conf files in DIR and subdirectories that contain an
# include statement.
# Then splits on ':' using awk and uniqs first field to give
# the list of calling files.
find $DIR -type f -name '*.conf' -print0 | \
	xargs -0 egrep -n 'include.*;' | \
	awk -F '[:]+' '{print $1}' | uniq | \
	while read line
		do
		# print calling file for report
   			printf "\n"
			echo "$line"
		# prints out include statements for each of the calling files
		# two sed statements deal with white space and '#'
		# so that result is in form of
		# callingfile.conf:Line#:(#)include:includefile.
		# An awk statement splits the line and puts it in the correct
		# order for the report.
		# Lines are then sorted by two keys, the first key is
		# the calling file and the second key is the line number.
		# Then it's formatted to columns.
			egrep -n 'include.*;' $line | \
			sed 's/\#\s\+include/\#include/g' | \
			sed 's/( {1,50}|\t{1,10})/\:/g' | \
			awk -F '[:]+' '{print $2 " " $3 " " "Line " $1}' | \
			sort -k 1,3 -k 4n | \
			column -t
done
