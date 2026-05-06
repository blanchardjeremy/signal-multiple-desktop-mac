-- Signal Instance Launcher Generator
try
	set instanceName to text returned of (display dialog Â
		"Name for this Signal instance (letters, numbers, hyphens):" Â
		default answer "Signal-2" Â
		with title "Signal Instance Generator")
	
	if instanceName is "" then error "Instance name cannot be empty."
	
	set colorChoice to choose from list Â
		{"amber", "coral", "cyan", "forest", "indigo", "lime", "magenta", "original", "rose", "sky", "teal", "violet"} Â
		with prompt "Choose an icon color:" Â
		default items {"sky"} Â
		with title "Signal Instance Generator"
	
	if colorChoice is false then error number -128
	set iconColor to item 1 of colorChoice
	
	set saveFolder to POSIX path of (choose folder Â
		with prompt "Where should the launcher app be saved?" Â
		default location (path to applications folder))
	
	set appName to "Signal-" & instanceName
	set appPath to saveFolder & appName & ".app"
	set contentsPath to appPath & "/Contents"
	set macosPath to contentsPath & "/MacOS"
	set resourcesPath to contentsPath & "/Resources"
	set launcherPath to macosPath & "/launcher"
	set plistPath to contentsPath & "/Info.plist"
	set iconPath to resourcesPath & "/icon.icns"
	set dataDir to "$HOME/.config/" & instanceName
	
	-- Lowercase the instance name for the bundle ID
	set bundleIDSuffix to do shell script "echo " & quoted form of instanceName & " | tr '[:upper:]' '[:lower:]'"
	set bundleID to "com.local.signal-" & bundleIDSuffix
	
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
	<string>" & appName & "</string>
	<key>CFBundleDisplayName</key>
	<string>" & appName & "</string>
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
exec /Applications/Signal.app/Contents/MacOS/Signal --user-data-dir=\"" & dataDir & "\""
	
	set launcherFile to open for access POSIX file launcherPath with write permission
	set eof launcherFile to 0
	write launcherContent to launcherFile as Çclass utf8È
	close access launcherFile
	
	do shell script "chmod +x " & quoted form of launcherPath
	
	-- Download colored icon from GitHub
	set iconURL to "https://raw.githubusercontent.com/blanchardjeremy/signal-voip-registration-helper/main/launcher_icons/" & iconColor & ".icns"
	try
		do shell script "curl -fsSL " & quoted form of iconURL & " -o " & quoted form of iconPath
	on error
		-- If download fails, fall back to Signal's default icon
		try
			do shell script "cp /Applications/Signal.app/Contents/Resources/*.icns " & quoted form of iconPath
		end try
	end try
	
	display dialog "Created: " & appPath & return & return & Â
		"Double-click to launch. Data will live at ~/.config/" & instanceName Â
		buttons {"OK"} default button "OK" with title "Done"
	
on error errMsg number errNum
	if errNum is not -128 then
		display dialog "Error: " & errMsg buttons {"OK"} default button "OK" with icon stop
	end if
end try