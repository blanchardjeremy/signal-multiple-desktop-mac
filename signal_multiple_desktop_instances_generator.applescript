(*
  Signal Instance Launcher Generator
  Creates macOS launcher apps for running multiple Signal Desktop instances at once.
  Each launcher gets its own name, icon, and data directory so you can be logged
  into multiple Signal accounts simultaneously.
  More info: https://github.com/blanchardjeremy/signal-multiple-desktop-mac/
*)


-- ============================================================
-- CONFIGURATION
-- ============================================================
property kDefaultInstanceName : "Work"
property kDefaultColor : "sky"
property kPrimaryColor : "original"
property kAvailableColors : {"amber", "coral", "cyan", "forest", "indigo", "lime", "magenta", "original", "rose", "sky", "teal", "violet"}

property kBundleIDPrefix : "com.local.signal-"
property kDataDirBase : "$HOME/.config/"
property kSignalAppPath : "/Applications/Signal.app"
property kIconRepoBaseURL : "https://raw.githubusercontent.com/blanchardjeremy/signal-multiple-desktop-mac/main/launcher_icons/"

property kAppNamePrefix : "Signal-"
property kPrimaryInstanceName : "Primary"
-- ============================================================


-- Signal Instance Launcher Generator
try
	-- Verify Signal Desktop is installed before doing anything else
	if not my pathExists(kSignalAppPath) then
		display dialog "Signal Desktop was not found at:" & return & kSignalAppPath & return & return & Â
			"Please install Signal Desktop from https://signal.org/download and try again." Â
			buttons {"OK"} default button "OK" with icon stop
		error number -128
	end if
	
	-- Loop until user provides a name that doesn't conflict with existing files
	set instanceName to ""
	set saveFolder to ""
	set folderChosen to false
	
	repeat
		set rawInput to text returned of (display dialog Â
			"Name for this Signal instance (letters, numbers, hyphens):" Â
			default answer kDefaultInstanceName Â
			with title "Signal Instance Generator")
		
		-- Strip "Signal-" prefix if user typed it (case-insensitive), so we never
		-- end up with names like "Signal-Signal-Work"
		set instanceName to my stripSignalPrefix(rawInput)
		
		if instanceName is "" then
			display dialog "Instance name cannot be empty." buttons {"OK"} default button "OK" with icon stop
			-- Loop back to re-prompt
		else
			-- Ask for save folder once (reuse it on retries)
			if not folderChosen then
				set saveFolder to POSIX path of (choose folder Â
					with prompt "Where should the launcher app be saved?" Â
					default location (path to applications folder))
				set folderChosen to true
			end if
			
			set displayName to kAppNamePrefix & instanceName
			set appPath to saveFolder & displayName & ".app"
			set dataDirPath to (POSIX path of (path to home folder)) & ".config/" & displayName
			
			-- Check for conflicts
			set appExists to my pathExists(appPath)
			set dataExists to my pathExists(dataDirPath)
			
			if appExists or dataExists then
				set conflictMsg to "Cannot use the name \"" & displayName & "\" because:" & return & return
				if appExists then
					set conflictMsg to conflictMsg & "¥ An app already exists at: " & appPath & return
				end if
				if dataExists then
					set conflictMsg to conflictMsg & "¥ A data directory already exists at: " & dataDirPath & return
				end if
				set conflictMsg to conflictMsg & return & "Please choose a different name."
				
				display dialog conflictMsg buttons {"OK"} default button "OK" with icon stop
				-- Loop back to re-prompt for a new name
			else
				-- Name is good, exit the loop
				exit repeat
			end if
		end if
	end repeat
	
	set colorChoice to choose from list kAvailableColors Â
		with prompt "Choose an icon color:" Â
		default items {kDefaultColor} Â
		with title "Signal Instance Generator"
	
	if colorChoice is false then error number -128
	set iconColor to item 1 of colorChoice
	
	-- Create the user's instance
	my createLauncher(instanceName, iconColor, saveFolder)
	
	set userDisplayName to kAppNamePrefix & instanceName
	set primaryDisplayName to kAppNamePrefix & kPrimaryInstanceName
	
	-- Offer to also create Signal-Primary (skip prompt if it already exists)
	set primaryAppPath to saveFolder & primaryDisplayName & ".app"
	set primaryAlreadyExists to my pathExists(primaryAppPath)
	
	if primaryAlreadyExists then
		display dialog "Created: " & userDisplayName & ".app" & return & return & Â
			"Data will live at ~/.config/" & userDisplayName & return & return & Â
			"Note: " & primaryDisplayName & ".app already exists in this folder, so it was not recreated." Â
			buttons {"OK"} default button "OK" with title "Done"
	else
		set primaryChoice to button returned of (display dialog Â
			"Also create " & primaryDisplayName & ".app?" & return & return & Â
			"To run two Signal desktops at the same time, you'll need a launcher for your original Signal account too. " & primaryDisplayName & " points at Signal's default data directory (~/Library/Application Support/Signal), where your existing Signal account already lives." & return & return & Â
			"After this, drag both launchers to your Dock and avoid clicking the original Signal app icon directly." Â
			buttons {"Skip this", "Create " & primaryDisplayName} Â
			default button ("Create " & primaryDisplayName) Â
			with title "Create primary launcher?")
		
		if primaryChoice is ("Create " & primaryDisplayName) then
			my createLauncher(kPrimaryInstanceName, kPrimaryColor, saveFolder)
			display dialog "Both launchers created in:" & return & saveFolder & return & return & Â
				"Drag both to your Dock. Use " & primaryDisplayName & " for your main account and " & userDisplayName & " for your second account." Â
				buttons {"OK"} default button "OK" with title "Done"
		else
			display dialog "Created: " & userDisplayName & ".app" & return & return & Â
				"Data will live at ~/.config/" & userDisplayName Â
				buttons {"OK"} default button "OK" with title "Done"
		end if
	end if
	
on error errMsg number errNum
	if errNum is not -128 then
		display dialog "Error: " & errMsg buttons {"OK"} default button "OK" with icon stop
	end if
end try


-- Handler: strip "Signal-" prefix from a string if present (case-insensitive)
on stripSignalPrefix(inputStr)
	if inputStr is "" then return ""
	return do shell script "echo " & quoted form of inputStr & " | sed -E 's/^[Ss][Ii][Gg][Nn][Aa][Ll]-//'"
end stripSignalPrefix


-- Handler: check whether a file or directory exists at a POSIX path
on pathExists(posixPath)
	try
		do shell script "test -e " & quoted form of posixPath
		return true
	on error
		return false
	end try
end pathExists


-- Handler: create a launcher app bundle
on createLauncher(instanceName, iconColor, saveFolder)
	set displayName to kAppNamePrefix & instanceName
	set appPath to saveFolder & displayName & ".app"
	set contentsPath to appPath & "/Contents"
	set macosPath to contentsPath & "/MacOS"
	set resourcesPath to contentsPath & "/Resources"
	set launcherPath to macosPath & "/launcher"
	set plistPath to contentsPath & "/Info.plist"
	set iconPath to resourcesPath & "/icon.icns"
	
	-- Primary launcher uses Signal's default data directory; others use kDataDirBase + display name
	if instanceName is kPrimaryInstanceName then
		set dataDirArg to ""
	else
		set dataDirArg to " --user-data-dir=\"" & kDataDirBase & displayName & "\""
	end if
	
	-- Lowercase the display name for the bundle ID
	set bundleIDSuffix to do shell script "echo " & quoted form of instanceName & " | tr '[:upper:]' '[:lower:]'"
	set bundleID to kBundleIDPrefix & bundleIDSuffix
	
	-- Create bundle directory structure
	do shell script "mkdir -p " & quoted form of macosPath
	do shell script "mkdir -p " & quoted form of resourcesPath
	
	-- Write Info.plist
	set plistContent to "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>CFBundleExecutable</key>
	<string>launcher</string>
	<key>CFBundleIdentifier</key>
	<string>" & bundleID & "</string>
	<key>CFBundleName</key>
	<string>" & displayName & "</string>
	<key>CFBundleDisplayName</key>
	<string>" & displayName & "</string>
	<key>CFBundleIconFile</key>
	<string>icon</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleVersion</key>
	<string>1.0</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>LSMinimumSystemVersion</key>
	<string>10.13</string>
	<key>LSUIElement</key>
	<false/>
	<key>NSHighResolutionCapable</key>
	<true/>
</dict>
</plist>"
	
	set plistFile to open for access POSIX file plistPath with write permission
	set eof plistFile to 0
	write plistContent to plistFile as Çclass utf8È
	close access plistFile
	
	-- Write launcher shell script
	set launcherContent to "#!/bin/bash
exec " & kSignalAppPath & "/Contents/MacOS/Signal" & dataDirArg
	
	set launcherFile to open for access POSIX file launcherPath with write permission
	set eof launcherFile to 0
	write launcherContent to launcherFile as Çclass utf8È
	close access launcherFile
	
	do shell script "chmod +x " & quoted form of launcherPath
	
	-- Download colored icon from GitHub
	set iconURL to kIconRepoBaseURL & iconColor & ".icns"
	try
		do shell script "curl -fsSL " & quoted form of iconURL & " -o " & quoted form of iconPath
	on error
		-- If download fails, fall back to Signal's default icon
		try
			do shell script "cp " & kSignalAppPath & "/Contents/Resources/*.icns " & quoted form of iconPath
		end try
	end try
end createLauncher