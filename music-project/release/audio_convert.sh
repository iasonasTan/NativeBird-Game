#!/bin/bash

TITLE="Ne vizhu"
ARTIST="Je Tan"
ALBUM="Ne vizhu"
COMPOSER="Je Tan"
PERFORMER="Je Tan"
GENRE="Post-Punk/Darkwave/Coldwave"
DATE="2026"
TDRC="2026-07-20"

OUTPUT_FILE="ne_vizhu"

ffmpeg -i music.wav \
	-i ~/myIcon.png -map 0:a -map 1:v \
	-c:a libmp3lame -q:a 2 \
	-id3v2_version 3 \
	-metadata title="$TITLE" \
	-metadata album="$ALBUM" \
	-metadata artist="$ARTIST" \
	-metadata genre="$GENRE" \
	-metadata performer="$PERFORMER" \
	-metadata composer="$COMPOSER" \
	-metadata date="$DATE" \
	-metadata TDRC="$TDRC" \
	$OUTPUT_FILE.mp3