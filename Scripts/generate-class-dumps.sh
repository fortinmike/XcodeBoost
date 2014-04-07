# Created: 2014-03-19

script_path=$(cd $(dirname $0) ; pwd -P)
output_path="$script_path/../Headers"
sdk="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk"

class-dump -r /Applications/Xcode.app/Contents/Frameworks/IDEFoundation.framework > "$output_path/IDEFoundation.h"
class-dump -r /Applications/Xcode.app/Contents/Frameworks/IDEKit.framework > "$output_path/IDEKit.h"
class-dump -r /Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework > "$output_path/DVTFoundation.h"
class-dump -r /Applications/Xcode.app/Contents/SharedFrameworks/DVTKit.framework > "$output_path/DVTKit.h"