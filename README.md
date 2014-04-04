XcodeBoost
==========

An Xcode plugin that makes altering and inspecting Objective-C code quick and easy.

XcodeBoost automates some tedious operations such as **extracting method declarations from definitions** for insertion into a header file, adds **line-based code manipulation** (cut/copy/paste/duplicate/delete lines), **persistent highlighting** and more!

*Contributions are welcome! :)*

#### Symbol Highlighting
![image](Images/highlighting.gif)

#### Method Definition and Signature Selection
![image](Images/method-selection.gif)

#### Copy Method Declarations
![image](Images/copy-method-declarations.gif)

#### Regex Match Highlighting
![image](Images/highlight-regex.gif)

#### Paste Lines (with or without reindent)
![image](Images/paste-without-reindent.gif)

*Pastes the copied string after the selected lines, unlike Xcode's "Paste" and "Paste and Preserve Formatting" which paste everything at the exact caret position. No need to precisely position the caret; code will be pasted on the next line.*

## Installation

1. Install through [Alcatraz](https://github.com/supermarin/Alcatraz) or download the source and build the XcodeBoost target, then restart Xcode.
2. Assign a keyboard shortcut to each XcodeBoost menu item through System Preferences' *Keyboard Shortcuts* panel.

![image](Images/shortcuts.png)

<div style="text-align: center; margin-top: 60px;">
	<img src="Images/menu.png"/>
</div>