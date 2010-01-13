#!/bin/sh

sudo cp ~/dotfiles/scripts/wifi_hook/wifi_hook.plist /System/Library/LaunchDaemons/
sudo launchctl load /System/Library/LaunchDaemons/wifi_hook.plist

