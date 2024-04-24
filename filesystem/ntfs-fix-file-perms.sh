#!/bin/bash
#
#
# Windows is "great" in making all files executable.
# This is in diametric opposition to how file permissions
# should be minimize in the UNIX world.
# This script attempts to fix that.

FIND_EXE=find

find_compat_find () {
    # On MobaXTerm system, the `find` command is problematic
    # because it was mapped to busybox find.
    # But for some reason, GNU find is available as `find.exe`,
    # so we will use that.
    if [ "$(uname)" = "CYGWIN_NT-10.0-WOW" ]; then
        # FIXME -- Temporary patch to allow this script to work
        # under MobaXTerm environment
        FIND_EXE=/bin/find.exe
    fi

    if echo "$FIND_EXE" | grep -q "/" ; then
        if [ ! -x "$FIND_EXE" ]; then
            echo "Error: cannot find the expected find executable: $FIND_EXE" >&2
            exit 2
        fi
    elif ! which "$FIND_EXE" > /dev/null  2> /dev/null; then
        echo "Error: cannot find the expected find executable: $FIND_EXE" >&2
        exit 2
    fi
}


fix_win_file_perms () {
    # Usage: fix_win_file_perms <DIR>
    local DIR="$1"
    "$FIND_EXE"  "$DIR"  -type f \( \
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
         -o -iname '*.odg' \
         -o -iname '*.odp' \
         -o -iname '*.ods' \
         -o -iname '*.odt' \
         \
         -o -iname '*.css' \
         -o -iname '*.html' \
         -o -iname '*.md' \
         -o -iname '*.txt' \
         -o -iname '*.xml' \
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
         -o -iname '*.js.download' \
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
         -o -iname '*.heif' \
         -o -iname '*.gif' \
         -o -iname '*.jpeg' \
         -o -iname '*.jpg' \
         -o -iname '*.png' \
         -o -iname '*.svg' \
         -o -iname '*.tif' \
         -o -iname '*.tiff' \
         \
         -o -iname '*.3gp' \
         -o -iname '*.3gpp' \
         -o -iname '*.avi' \
         -o -iname '*.mov' \
         -o -iname '*.mp2' \
         -o -iname '*.mp3' \
         -o -iname '*.mp4' \
         -o -iname '*.mpg' \
         -o -iname '*.webm' \
         -o -iname '*.webp' \
         \) \
	 \
         -perm /u+x,g+x,o+x \
	 \
         -print0 \
         | xargs -0 chmod ${VERBOSE:+-v} 644
}


find_compat_find
fix_win_file_perms  "${1:?Target subdir tree is required as arg 1}"

