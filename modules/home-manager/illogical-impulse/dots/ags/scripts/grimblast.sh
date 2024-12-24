#!/usr/bin/env bash

if [ "$1" == "copy" ]; then
  grimblast copy area
elif [ "$1" == "save" ]; then
  mkdir -p ~/Pictures/Screenshots
  grimblast save area - | satty -f - --fullscreen --output-filename ~/Pictures/Screenshots/Satty-$(date '+%Y%m%d-%H:%M:%S').png
fi