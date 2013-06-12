#!/bin/sh
###############################################################################################
# @Author: Hars Vardhan
# @Email: harsv@utdallas.edu
# @Company: The University of Texas at Dallas
# @Date: 03/01/2013
# How to Run: Run from current working directory where all folders should be created
# Usage: setupAssign.sh <gradebook.zip>
# EX: > ../setupAssign.sh "gradebook.zip"
# It performs following:
# 1. Unzips the archived submission
# 2. Creates a directory with project name and puts individual submissions in it
# 3. Students' submission directories' format: FirstnameLastName(net-id)
# 4. Un-archive the zipped files inside their directories. Supported formats: .zip, .tar, .gz
# Assumptions:
# 1. The submission file contains only one attempt (last attempt)
# 2.
###############################################################################################
echo "Running on $1"
#Set the temp directory
TMP=/tmp/project
#Set the length of the prefix added by elearning before original files.
PREFIXLEN=28
#Remove the content of the temp directory  if exists
rm -rf $TMP
mkdir -p $TMP
#Unzip the given archived gradebook
unzip -uo $1 -d $TMP/ || exit;

# Determine the Project name from one of the file
PROJ=""

for filename in $TMP/*
do 
#First part of the string contains the project name
echo "File: $filename"
ind=`expr index "$filename" _`
# Get the project name
if test {$PROJ=""}; then
PROJ=${filename::ind-1}
PROJ=${PROJ// /_}
echo "Project folder: $PROJ"
fi
# Proceed with rest of the file name 
newfile=${filename:ind}
#Getting the net-id of the student
ind=`expr index "$newfile" _`
fname=${newfile::ind-1}
echo $fname
# Initially create the folder named net-id
mkdir -p "$PROJ/$fname"
# Prune the added prefix to get original file name
# The length of the refix length is 28 (as of now)
fname2=${newfile:ind+$PREFIXLEN}
# This is important: Remove all spaces in file names.
fname2=${fname2// /_}
echo "Filename: $fname2"
# Change the submission file to "submission.txt"
test "$fname2" = "txt" && fname2="submission.txt"
echo "mv $filename $fname2" 
mv "$filename" "$fname2"
#Eventually put them in their corresponding folder
echo "mv $fname2 $PROJ/$fname/"
mv "$fname2" "$PROJ/$fname/"
#fname="${fname// /}"
#fname="$filename"
#echo "$fname"

# This additional processing deflate files inside the submission folder in case the submission contains
# another archived file(s).
echo "cd $PROJ/$fname/"
cd "$PROJ/$fname/"
flist=`ls`
echo "$flist"
case "$flist" in
# It may not handle all archived files, but here it can be added to support other archives.
	*'.zip') echo "Unzipping $flist" ; unzip -uo "$flist" ;;
    *'.gz') echo "Untaring $flist" ;  tar xvzf "$flist" ;;
    *'.tar') echo "Untaring $flist" ; tar xvf "$flist" ;;
#	*'.rar') echo "Unraring $flist"; unrar x "$flist" ;;
    *'.jar') echo "Unjaring $flist"; jar xf "$flist" ;;
	*) ;;
esac
cd -
#cp ../commands* "$fname/"
done
# This part actually changes the student directories names from net-id to FirstLastname(net-id)
# Also, removes all blank spaces
for filename in $PROJ/*
do
cat $filename/submission.txt | while read line1
do 
echo $line1
newName=${line1:6}
newName=${newName// /}
echo "mv $filename $newName"
mv "$filename" "$PROJ/$newName"
break
done
done
# Finally  moves the resultant folder in your current directory and deletes tmp files.
mv -u $PROJ ./ && 
rm -rf /tmp/project 
# Uncomment the following line of you want to delete original archived (gradebook) file.
#rm -f $1
