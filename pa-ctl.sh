#!/bin/bash
# Author: Yan Doroshenko
# github.com/YanDoroshenko

SINK=$(pacmd list-sinks|awk '/\* index:/{ print $3 }')
VOLUME_LEVEL=$(pacmd list-sinks|grep -A 15 '* index'| awk '/volume: front/{ print $5 }' | sed 's/[%|,]//g')

if [ -z $1 ]; then
    echo "Usage: pa-ctl up/down/mute"
fi

DELTA=5
if [ ! -z $2 ]; then
    if [[ $2 =~ ^[1-9][0-9]?$|^100$ ]]; then
	DELTA=$2
    fi
fi

case "$1" in
    U|u|[U,u]p)
	VOLUME_LEVEL=$(($VOLUME_LEVEL + $DELTA))
	if [ $VOLUME_LEVEL -gt 100 ]; then
	    VOLUME_LEVEL=100
	    pactl set-sink-volume $SINK  100%
	else 
	    pactl set-sink-volume $SINK  $VOLUME_LEVEL%
	fi
	;;
    D|d|[D,d]own)
	VOLUME_LEVEL=$(($VOLUME_LEVEL - $DELTA))
	if [ $VOLUME_LEVEL -lt 0 ]; then
	    VOLUME_LEVEL=0
	    pactl set-sink-volume $SINK  0%
	else 
	    pactl set-sink-volume $SINK  $VOLUME_LEVEL%
	fi
	;;
    M|m|[M,m]ute)
	pactl set-sink-mute $SINK toggle
	MUTED=$(pacmd list-sinks|grep -A 15 '* index'|awk '/muted:/{ print $2 }')
	;;
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

if [ $MUTED == "yes" ]; then
    DISPLAYED_VOLUME=0
else 
    DISPLAYED_VOLUME=$VOLUME_LEVEL
fi

notify-send -t 1000 -i $ICON --hint=int:transient:1 --hint=int:value:$DISPLAYED_VOLUME --hint=string:synchronous:volume "Volume down $DELTA%" ""
