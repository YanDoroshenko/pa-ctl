# Pulseaudio-control
Simple bash script to allow for control of Pulseaudio volume. Simply map the following to keyboard shortcuts in your DE or WM. Xfce4 allows for this under Settings > Keyboard > Application Shortcuts.

	/usr/bin/pulseaudio-ctl mute        ==>  Toggle status of mute
	/usr/bin/pulseaudio-ctl up          ==>  Increase vol by 5 %
	/usr/bin/pulseaudio-ctl up 25       ==>  Increase vol by 25 %
	/usr/bin/pulseaudio-ctl down        ==>  Decrease vol by 5 %
	/usr/bin/pulseaudio-ctl down 50     ==>  Decrease vol by 50 %
	/usr/bin/pulseaudio-ctl set 40      ==>  Set vol to 40%
