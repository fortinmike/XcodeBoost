# Created: 2014-03-19
# Author: Michaël Fortin

script_path=$(cd $(dirname $0) ; pwd -P)
sdk="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk"

class-dump /Applications/Xcode.app/Contents/Frameworks/IDEFoundation.framework --sdk-root $sdk > "$script_path/../Class-Dumps/IDEFoundation.h"
class-dump /Applications/Xcode.app/Contents/Frameworks/IDEKit.framework --sdk-root $sdk > "$script_path/../Class-Dumps/IDEKit.h"
class-dump /Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework --sdk-root $sdk > "$script_path/../Class-Dumps/DVTFoundation.h"
class-dump /Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework --sdk-root $sdk > "$script_path/../Class-Dumps/DVTKit.h"