# Created: 2014-03-19
# Author: Michaël Fortin

function find_exes
{
	find $1 -type f -perm +111 -print
}

script_path=$(cd $(dirname $0) ; pwd -P)
executables_file="$script_path/../Class-Dumps/executables.txt"
classdumps_folder="$script_path/../Class-Dumps/"

# Write all executable paths (from the Xcode executable and its frameworks) to a file for reference
echo '/Applications/Xcode.app/Contents/MacOS/Xcode' > $executables_file
find_exes '/Applications/Xcode.app/Contents/Frameworks/' >> $executables_file
find_exes '/Applications/Xcode.app/Contents/OtherFrameworks/' >> $executables_file
echo $'\n' >> $executables_file

echo "Found executables:"
cat $executables_file

while read line; do
	executable_name=$(basename "$line")
	echo "Generating class dump for $executable_name..."
	class-dump -H "$line" -o "$classdumps_folder/$executable_name"
done < $executables_file

echo "Done!"