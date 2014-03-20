# Created: 2014-03-19
# Author: Michaël Fortin

script_path=$(cd $(dirname $0) ; pwd -P)
class-dump -H -r /Applications/Xcode.app/ -o "$script_path/../Class-Dumps"