tell application "System Preferences"
	activate
	set current pane to pane "com.apple.preference.keyboard"
	reveal anchor "shortcutsTab" of pane id "com.apple.preference.keyboard"
	-- Incase the window is not opened instantly
	delay 1
end tell
tell application "System Events"
	tell application process "System Preferences"
		tell splitter group 1 of tab group 1 of window "Keyboard"
			set selected of row 9 of table 1 of scroll area 1 to true
		end tell
		-- Click the "Add" button in the window "Keyboard"
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		-- Choose the Target Application
		tell pop up button 1 of sheet 1 of window "Keyboard"
			click
			tell menu 1
				click menu item "Xcode"
			end tell
		end tell
		-- Set the shortcut title
		set value of text field 1 of sheet 1 of window "Keyboard" to "Highlight Occurences of Symbol"
		-- Move the focus into the "Keyboard Shortcut" text field
		keystroke tab
		-- The key code of "F11" is 103
		key code 103 using {shift down, command down}
		-- Confirm and add the shortcut
		click button "Add" of sheet 1 of window "Keyboard"
		
		-- Now the application is default to Xcode,
		-- so go straight for the remaining shortcuts
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		set value of text field 1 of sheet 1 of window "Keyboard" to "Highlight Occurences of String"
		keystroke tab
		key code 111 using {shift down, command down}
		click button "Add" of sheet 1 of window "Keyboard"
		
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		set value of text field 1 of sheet 1 of window "Keyboard" to "Highlight Regex Matches"
		keystroke tab
		key code 103 using {control down, option down, shift down, command down}
		click button "Add" of sheet 1 of window "Keyboard"
		
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		set value of text field 1 of sheet 1 of window "Keyboard" to "Remove Most Recently Added Highlight"
		keystroke tab
		key code 109 using {shift down, command down}
		click button "Add" of sheet 1 of window "Keyboard"
		
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		set value of text field 1 of sheet 1 of window "Keyboard" to "Remove All Highlighting"
		keystroke tab
		key code 101 using {shift down, command down}
		click button "Add" of sheet 1 of window "Keyboard"
		
		-- The Methods group
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		set value of text field 1 of sheet 1 of window "Keyboard" to "Select Methods and Functions"
		keystroke tab
		key code 46 using {option down, shift down, command down}
		click button "Add" of sheet 1 of window "Keyboard"
		
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		set value of text field 1 of sheet 1 of window "Keyboard" to "Select Method and Function Signatures"
		keystroke tab
		key code 46 using {shift down, command down}
		click button "Add" of sheet 1 of window "Keyboard"
		
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		set value of text field 1 of sheet 1 of window "Keyboard" to "Duplicate Methods and Functions"
		keystroke tab
		key code 2 using {option down, shift down, command down}
		click button "Add" of sheet 1 of window "Keyboard"
		
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		set value of text field 1 of sheet 1 of window "Keyboard" to "Copy Method and Function Declarations"
		keystroke tab
		key code 8 using {option down, shift down, command down}
		click button "Add" of sheet 1 of window "Keyboard"
		-- The Lines group
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		set value of text field 1 of sheet 1 of window "Keyboard" to "Cut Lines"
		keystroke tab
		key code 7 using {shift down, command down}
		click button "Add" of sheet 1 of window "Keyboard"
		
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		set value of text field 1 of sheet 1 of window "Keyboard" to "Copy Lines"
		keystroke tab
		key code 8 using {shift down, command down}
		click button "Add" of sheet 1 of window "Keyboard"
		
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		set value of text field 1 of sheet 1 of window "Keyboard" to "Paste Lines"
		keystroke tab
		key code 9 using {shift down, command down}
		click button "Add" of sheet 1 of window "Keyboard"
		
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		set value of text field 1 of sheet 1 of window "Keyboard" to "Paste Lines Without Reindent"
		keystroke tab
		key code 9 using {option down, shift down, command down}
		click button "Add" of sheet 1 of window "Keyboard"
		
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		set value of text field 1 of sheet 1 of window "Keyboard" to "Duplicate Lines"
		keystroke tab
		key code 2 using {shift down, command down}
		click button "Add" of sheet 1 of window "Keyboard"
		
		click button 1 of group 1 of tab group 1 of window "Keyboard"
		set value of text field 1 of sheet 1 of window "Keyboard" to "Delete Lines"
		keystroke tab
		key code 37 using {shift down, command down}
		click button "Add" of sheet 1 of window "Keyboard"
	end tell
end tell
tell application "System Preferences" to quit
