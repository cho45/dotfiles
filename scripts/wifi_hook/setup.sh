#!/bin/sh

sudo cp ~/dotfiles/scripts/wifi_hook/local.cho45.wifi_hook.plist /System/Library/LaunchDaemons/
sudo launchctl unload /System/Library/LaunchDaemons/local.cho45.wifi_hook.plist
sudo launchctl load /System/Library/LaunchDaemons/local.cho45.wifi_hook.plist

