#!/bin/bash
if [[ "$1" == "ADDED" ]] && [[ "$3" == *"Apple"* ]]; then
    setxkbmap -model macintosh -layout us -variant mac
fi
