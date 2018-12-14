set userLoginName to "UserName"
set keychainRecordName to "Yourkeycain"
set serverUri to "VPNAddress"

set ciscoClientMainWindowName to "Cisco AnyConnect Secure Mobility Client"
set ciscoWindowTitle to "Cisco AnyConnect | " & serverUri


-- Provide mechanism to get password from keychain
on getPassword(keychainItemName)
	local password
	set password to do shell script ("/usr/bin/security 2>&1 >/dev/null find-generic-password -gl " & quoted form of keychainItemName & " | cut -c 11-99 | sed 's/\"//g'")
	if password contains "could not be found in the keychain" or password as string is equal to "" then
		display alert "Password not found in the keychain" message "Certain tasks in this script need the administrator password to work.
You must create a new password in the OS X Keychain with a custom name, and set it with your administrator password, then edit this script." as critical
		error "Password could not be found in the keychain."
	else
		return password
	end if
end getPassword


on userDATA(ciscoClientMainWindowName, ciscoWindowTitle, userLoginName, keychainRecordName)
	tell application "System Events"
		tell process ciscoClientMainWindowName
			tell window ciscoWindowTitle
				click of pop up button 1
				delay 0.2
				click menu item 2 of menu 1 of pop up button 1
				delay 1.5
				set value to userLoginName of text field 1
				-- Because this is secured field 
				tell text field 2
					set value to my getPassword(keychainRecordName)
				end tell
				tell text field 3
					set value to "PUSH"
				end tell
				click button "OK"
				delay 5
			end tell
		end tell
		
	end tell
end userDATA

try
	tell application "System Events" to tell process ciscoClientMainWindowName
		tell menu bar item 1 of menu bar 2
			click
			click menu item "Show AnyConnect Window" of menu 1
		end tell
	end tell
end try

activate application ciscoClientMainWindowName
tell application "System Events"
	repeat until window 2 of process ciscoClientMainWindowName exists
	end repeat
	
	tell process ciscoClientMainWindowName
		set disconnectButtonTitle to "Disconnect"
		if exists (button disconnectButtonTitle of window 2) then
			set result to button returned of (display dialog "VPN is already connected." buttons {"Reconnect", "Cancel"} default button 2)
			--if result is "Reconnect" then
			--	tell window 2
			--		click button disconnectButtonTitle
			--	end tell
			--end if
		end if
		
		--repeat until static text "Ready to connect." of window 1 exists
		--end repeat
		
		
		if window ciscoWindowTitle exists then
			my userDATA(ciscoClientMainWindowName, ciscoWindowTitle, userLoginName, keychainRecordName)
		else
			tell window 2
				tell combo box 1
					set focused to 1
					set value to serverUri
				end tell
				click button "Connect"
				delay 3.1
			end tell
			
			repeat until window ciscoWindowTitle exists
				click button "Connect" of window 2
				delay 1
			end repeat
			
			
			my userDATA(ciscoClientMainWindowName, ciscoWindowTitle, userLoginName, keychainRecordName)
		end if
		
	end tell
end tell


