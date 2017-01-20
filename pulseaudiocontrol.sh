#!/bin/bash
#
# Simple command line Pulseaudio volume control
#
# by Yan Doroshenko
# https://github.com/YanDoroshenko/pulseudio-control

SINK=$(pacmd list-sinks|awk '/\* index:/{ print $3 }')
VOLUME_LEVEL=$(pacmd list-sinks|grep -A 15 '* index'| awk '/volume: front/{ print $5 }' | sed 's/[%|,]//g')

if [ -z $1 ]; then
    echo "Usage: pulseaudiocontrol up/down/mute"
fi

DELTA=5

if [ ! -z $2 ]; then
    if [[ $2 =~ ^[0-9][0-9]?$|^100$ ]]; then
	DELTA=$2
    fi
fi

case "$1" in
    U|u|[U,u]p)
	pactl set-sink-mute $SINK 0
	VOLUME_LEVEL=$(($VOLUME_LEVEL + $DELTA))
	if [ $VOLUME_LEVEL -gt 100 ]; then
	    VOLUME_LEVEL=100
	fi
	;;
    D|d|[D,d]own)
	pactl set-sink-mute $SINK 0
	VOLUME_LEVEL=$(($VOLUME_LEVEL - $DELTA))
	if [ $VOLUME_LEVEL -lt 0 ]; then
	    VOLUME_LEVEL=0
	fi
	;;
    M|m|[M,m]ute)
	pactl set-sink-mute $SINK toggle
	MUTED=$(pacmd list-sinks|grep -A 15 '* index'|awk '/muted:/{ print $2 }')
	;;
    S|s|[S,s]et)
	VOLUME_LEVEL=$DELTA
esac

if [[ $MUTED == "yes" ]]; then
    ICON=audio-volume-muted
elif [ $VOLUME_LEVEL -lt 2 ]; then
    ICON=audio-volume-off
elif [ $VOLUME_LEVEL -lt 33 ]; then
    ICON=audio-volume-low
elif [ $VOLUME_LEVEL -lt 67 ]; then
    ICON=audio-volume-medium
else 
    ICON=audio-volume-high
fi

if [[ $MUTED == "yes" ]]; then
    DISPLAYED_VOLUME=0
else 
    DISPLAYED_VOLUME=$VOLUME_LEVEL
fi

pactl set-sink-volume $SINK $VOLUME_LEVEL%
if [ ! -z $2 ] && [ $2  == "-d" ]; then
    notify-send -i $ICON --hint=int:transient:1 --hint=int:value:$DISPLAYED_VOLUME "Volume: $VOLUME_LEVEL%" ""
elif [ ! -z $3 ] && [ $3  == "-d" ]; then
    notify-send -i $ICON --hint=int:transient:1 --hint=int:value:$DISPLAYED_VOLUME "Volume: $VOLUME_LEVEL%" ""
fi
