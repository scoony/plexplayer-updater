#!/bin/bash

appimage_source="https://knapsu.eu/plex/"
target_folder="/opt/Plex_Player"

#### Checking target folder
if [[ -d "$target_folder" ]]; then
  mkdir -e "$target_folder"
fi

#### Fixing access rights
chmod 777 -R "$target_folder"

#### Get last version URL
appimage_url=`wget -q -O- "$appimage_source" | sed '/data\/plex\//!d' | sed -n '1p' | grep -Po '(?<=href=")[^"]*'`

#### Get the version of the last package
appimage_version=`basename $appimage_url | sed 's/Plex_Media_Player_//' | cut -d \- -f 1`

#### Get the name of the file
appimage_filename=`basename $appimage_url`

#### Create download link
appimage_link=`echo $appimage_source$appimage_url | sed 's/\/plex\/\//\//g'`
