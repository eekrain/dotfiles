#! /usr/bin/env bash

swww clear
sleep 1
swww img ~/Pictures/wallpapers/1.jpg --transition-type grow --transition-pos "$(hyprctl cursorpos)" --transition-duration 3
sleep 5
# then sets my favorite .gif wallpaper
swww img ~/Pictures/wallpapers/misono-mika-angel-blue-archive-moewalls.gif --transition-type grow --transition-pos "$(hyprctl cursorpos)" --transition-duration 3
