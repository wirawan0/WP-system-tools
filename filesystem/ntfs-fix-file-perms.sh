#!/bin/bash
#
#
# Windows is "great" in making all files executable.
# This is in diametric opposition to how file permissions
# should be minimize in the UNIX world.
# This script attempts to fix that.

fix_win_file_perms () {
    # Usage: fix_win_file_perms <DIR>
    local DIR="$1"
    find "$DIR" \( \
         -iname '*.pdf' \
         -o -iname '*.ps' \
	 \
         -o -iname '*.doc' \
         -o -iname '*.docx' \
         -o -iname '*.ppt' \
         -o -iname '*.pptx' \
         -o -iname '*.xls' \
         -o -iname '*.xlsx' \
         \
         -o -iname '*.odp' \
         -o -iname '*.ods' \
         -o -iname '*.odt' \
         \
         -o -iname '*.css' \
         -o -iname '*.html' \
         -o -iname '*.md' \
         -o -iname '*.txt' \
         -o -iname '*.yaml' \
         -o -iname '*.yml' \
         \
         -o -iname '*.c' \
         -o -iname '*.cc' \
         -o -iname '*.cpp' \
         -o -iname '*.cxx' \
         -o -iname '*.f' \
         -o -iname '*.F' \
         -o -iname '*.f90' \
         -o -iname '*.F90' \
         -o -iname '*.js' \
         -o -iname '*.ipynb' \
         \
         -o -iname '*~' \
	 \
         -o -iname '*.7z' \
         -o -iname '*.bz2' \
         -o -iname '*.gz' \
         -o -iname '*.lzma' \
         -o -iname '*.rar' \
         -o -iname '*.tar' \
         -o -iname '*.tgz' \
         -o -iname '*.tbz' \
         -o -iname '*.tbz2' \
         -o -iname '*.xz' \
         -o -iname '*.zip' \
         \
         -o -iname '*.gif' \
         -o -iname '*.jpeg' \
         -o -iname '*.jpg' \
         -o -iname '*.png' \
         -o -iname '*.svg' \
         \
         -o -iname '*.3gp' \
         -o -iname '*.3gpp' \
         -o -iname '*.mov' \
         -o -iname '*.mp2' \
         -o -iname '*.mp3' \
         -o -iname '*.mp4' \
         -o -iname '*.mpg' \
         -o -iname '*.webm' \
         -o -iname '*.webp' \
         \) \
	 \
         -print0 \
         | xargs -0 chmod 644
}


fix_win_file_perms  "${1:?Target subdir tree is required as arg 1}"

