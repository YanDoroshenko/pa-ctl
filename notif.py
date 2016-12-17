#!/usr/bin/python
import time
import re
import sys
import gi
gi.require_version('Notify', '0.7')
gi.require_version('Gtk', '3.0')
from gi.repository import Notify
from gi.repository import Gtk
from subprocess import check_output
from subprocess import call

#Get all sinks from pacmd output
sinks = check_output(["pacmd", "list-sinks"]).decode('utf-8')

#Find the first string with marked index
marked = re.search('.*\*.*index.*', sinks).group(0)

#Get the index from the string
sink_index = marked.split(':')[1].strip()

#Get the current sink volume
current_volume_level = re.search("[0-9]+\%", re.findall('.*volume: front.*', sinks)[int(sink_index)]).group(0).split('%')[0]

#Define values for flow control
icon = "audio-volume-high"
is_muted = None
new_volume_level = int(current_volume_level)

if len(sys.argv) == 1:
    print(current_volume_level)
elif len(sys.argv) not in [1,2,3]:
    print("Usage:\npulseaudiocontrol mute\npulseaurio up/down [VALUE]\npulseaudiocontrol set {VALUE}")
else:
    if len(sys.argv) == 2:
        value = 5
    elif len(sys.argv) == 3 and not sys.argv[2].isDigit():
        print("VALUE must be a number")
    else:
        value = int(sys.argv[2])
    if sys.argv[1] in ["u", "U", "up", "Up", "UP"]:
        call(["pactl", "set-sink-mute", sink_index, "0"])
        new_volume_level = int(current_volume_level) + int(value)
        if new_volume_level > 100:
            new_volume_level = 100
    elif sys.argv[1] in ["d", "D", "down", "Down", "DOWN"]:
        call(["pactl", "set-sink-mute", sink_index, "0"])
        new_volume_level = int(current_volume_level) - int(value)
        if new_volume_level < 0:
            new_volume_level = 0
    elif sys.argv[1] in ["m", "M", "mute", "Mute", "MUTE"]:
        call(["pactl", "set-sink-mute", sink_index, "toggle"])
        is_muted = re.findall('.*muted:.*', sinks)[int(sink_index)].strip().split(": ")[1]
    elif sys.argv[1] in ["s", "S", "set", "Set", "SET"]:
        call(["pactl", "set-sink-mute", sink_index, 0])
        new_volume_level = value

if is_muted is None or is_muted == "no":
    displayed_value = "<b>Volume: </b>" + str(new_volume_level) + "%"
    displayed_value = '<progress value="22" max="100"></progress>'
    if new_volume_level < 2:
        icon = "audio-volume-off"
    elif new_volume_level < 33:
        icon = "audio-volume-low"
    elif new_volume_level < 67:
        icon = "audio-volume-medium"
    else:
        icon = "audio-volume-high"
else:
    displayed_value = "<b>Muted</b>"
    icon = "audio-volume-muted"


call(["pactl", "set-sink-volume", sink_index, str(new_volume_level) + "%"])
#Notify.init("pulseaudiocontrol")
#Hello=Notify.Notification.new("PulseAudio control",displayed_value,icon)
#Hello.show ()
#Hello.close()
call(["notify-send", "-t", "100", "-i", icon, "--hint=int:transient:1", "--hint=int:value:" + str(new_volume_level), "Volume"])
