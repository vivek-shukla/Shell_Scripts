#! /bin/sh

PRESENT_DIR=`pwd`
echo "Present Directory:: "$PRESENT_DIR

ROOT_DIR="<<add-your-local-project-dir>>"

BASE_BRANCH='remotes/origin/<<add-your-remote-branch>>'
COMPARE_BRANCH='remotes/origin/master'
DIFF_CMD=$COMPARE_BRANCH".."$BASE_BRANCH

echo Changing root directory
cd $ROOT_DIR

echo Initializing Commits, Log, and Output file
commitfile=$PRESENT_DIR"/commits.txt"
logfile=$PRESENT_DIR"/GitDiffLog.log"
output=$PRESENT_DIR"/UniqueFileChanges.txt"
corechanges=$PRESENT_DIR"/UniqueCoreFileChanges.txt"
gitchanges=$PRESENT_DIR"/GitChanges"

echo Removing existing Commits and Log file
rm -f $commitfile
rm -f $logfile
rm -f $output
rm -f $corechanges
rmdir $gitchanges

echo Fetching Git history and storing commit hash
git log | grep commit > $commitfile

echo Iterating over git hash to get file changes for each commit
cat $commitfile | sed '$ d' | while IFS=" " read -r commit hash
do 
   echo "Hash:: "$hash
   echo "Files updated for "$hash >> $logfile
   echo "-----------------------------------------------------" >> $logfile
   FileDiff=$(git diff-tree --no-commit-id --name-only -r $hash)
   echo $FileDiff | sed 's/ /\n/g' >> $logfile
   echo $FileDiff | sed 's/ /\n/g' >> temp.txt 
done

echo Saving unique file changes
sort -u temp.txt > $output

echo Removing mvn_repository changes
cat $output | sed -e '/mvn_repository/d' | sort -u > $corechanges

mkdir $gitchanges

echo Getting changes between $BASE_BRANCH and $COMPARE_BRANCH

cat $corechanges | sed '1d' | while read -r file
do  
    echo "File:: "$file
    UPDATED_FILE=$(echo $file | sed 's/\//_/g') 
	UPDATED_FILE="${gitchanges}/${UPDATED_FILE}"
	git diff $DIFF_CMD $file > $UPDATED_FILE
done

rm -f temp.txt
