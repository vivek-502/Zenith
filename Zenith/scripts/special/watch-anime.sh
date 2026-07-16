#!/bin/bash

# Open kitty
kitty --class floating-terminal -- bash -c '
  WATCH_ANIME () {
    echo ""
    read -p "Search anime: " anime
    read -p "dub/sub: " lang

    if [ "$lang" == "dub" ]; then
      ani-cli --dub $anime
    else
      ani-cli $anime
    fi
  }  

  WATCH_ANIME

  while true; do
    read -p "Watch more (yes/no): " MORE

    if [ "$MORE" == "yes" ]; then
      WATCH_ANIME
    else
      echo "Bye!"
      sleep 1
      exit 0
    fi
  done   
'
