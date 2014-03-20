# Created: 2014-03-19

script_path=$(cd $(dirname $0) ; pwd -P)
sdk="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk"

class-dump -r /Applications/Xcode.app/Contents/Frameworks/IDEFoundation.framework > "$script_path/../Class-Dumps/IDEFoundation.h"
class-dump -r /Applications/Xcode.app/Contents/Frameworks/IDEKit.framework > "$script_path/../Class-Dumps/IDEKit.h"
class-dump -r /Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework > "$script_path/../Class-Dumps/DVTFoundation.h"
class-dump -r /Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework > "$script_path/../Class-Dumps/DVTKit.h"