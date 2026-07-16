#!/bin/bash


# 1. RAM Injection
# Start the selector instantly. No disk-write here, because we're about 
# to do heavy IO operations below.
hyprctl eval "dofile('$HOME/.config/rofi/animations/App_launcher_anim.lua')"
rofi -show drun
