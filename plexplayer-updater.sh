#!/bin/bash

appimage_source="https://knapsu.eu/plex/"
target_folder="/opt/Plex_Player"
debug="no"

#### Checking target folder
if [[ ! -d "$target_folder" ]]; then
  mkdir -p "$target_folder"
fi

#### Fixing access rights
chmod 777 -R "$target_folder"

#### Get last version URL
appimage_url=`wget -q -O- "$appimage_source" | sed '/data\/plex\//!d' | sed -n '1p' | grep -Po '(?<=href=")[^"]*'`
if [[ "$debug" == "yes" ]]; then echo "Parsing successful: $appimage_url"; fi

#### Get the version of the last package
appimage_version=`basename $appimage_url | sed 's/Plex_Media_Player_//' | cut -d \- -f 1`
if [[ "$debug" == "yes" ]]; then echo "File version: $appimage_version"; fi

#### Get the name of the file
appimage_filename=`basename $appimage_url`
if [[ "$debug" == "yes" ]]; then echo "File name: $appimage_filename"; fi

#### Create download link
appimage_link=`echo $appimage_source$appimage_url | sed 's/\/plex\/\//\//g'`
if [[ "$debug" == "yes" ]]; then echo "File Download Link: $appimage_link"; fi

#### Download if missing
if [[ ! -f "$target_folder/$appimage_filename" ]]; then
  echo "Downloading the new version ($appimage_version)"
  wget -q "$appimage_link" -O "$target_folder/$appimage_filename"
  chmod +x "$target_folder/$appimage_filename"
  update_menu="yes"
else
  echo "No update available"
fi

#### Update menu(s)
## locate must be installed
if [[ "$update_menu" == "yes" ]]; then
  updatedb
  locate "appimagekit-plexmediaplayer.desktop" > plexplayer.txt
  plexplayer_menu=()
  while IFS= read -r -d $'\n'; do
    plexplayer_menu+=("$REPLY")
  done <plexplayer.txt
  rm -f plexplayer.txt
  if [[ "${plexplayer_menu[@]}" != "" ]]; then
    appimage_newbin_path=`echo "$target_folder/$appimage_filename"`
    for menu in "${plexplayer_menu[@]}"; do
      echo "... trying to update the menu of each user"
      appimage_oldbin_path=`cat $menu | grep -Po '(?<=Exec=")[^" %U]*' | sed -n '1p'`
      sed -i 's/'$appimage_oldbin_path'/'$appimage_newbin_path'/g' $menu
    done
  fi
fi
