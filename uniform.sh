#! /usr/bin/env sh

use_force=""
if test "$1" = "--force"; then
    use_force=1
    shift
fi

if test "$1" = "--"; then
    shift
fi

args="$@"

# --name-only = Only show filepath
# -r = Recurse into subtrees
# HEAD = look at current git commit
# $args is passed to allow specifying specific files
files=`git ls-tree -r --name-only HEAD "$args"`

if test -z "$files"; then
    git status -su --ignored -- "$args"
    echo "Did not find any files under git control."
    exit 2
fi

if !(git diff --name-only --exit-code -- $files); then
    echo "The files listed above have been changed since last commit."

    if test -z "$use_force"; then
        echo "Commit these files or run with --force."
        exit 1
    else
        echo "Proceeding anyway: --force given."
    fi
fi

cleanup() {
    exit_code=$1

    echo
    echo "Something went wrong. You may want to undo with git reset --hard."

    if test -n "$use_force"; then
        echo "However, be extra careful because you have used --force."
    fi

    exit $exit_code
}

uniformdir=`dirname $0`
echo "$files" | while IFS= read -r file; do
    # run formatter on file
    filename=$(basename "$file")
    extension="${filename##*.}"

    if test "$extension" = "js"; then
        test -e "$uniformdir/javascript-formatter" || contunue
        tempfile=`mktemp`
        node "$uniformdir/javascript-formatter" "$file" 1> "$tempfile" || cleanup $?
        chmod --reference="$file" "$tempfile" || cleanup $?
        mv "$tempfile" "$file" || cleanup $?
    fi

    if test "$extension" = "cc" -o "$extension" = "cpp" -o \
        "$extension" = "h" -o "$extension" = "hpp";
    then
        command -v uncrustify >/dev/null 2>&1 || continue
        uncrustify --no-backup "$file" || cleanup $?
        # run again; uncrustify fails to fix some problems [correctly]
        # during the first run!
        uncrustify --no-backup "$file" || cleanup $?
    fi
done

# TODO: Warn _once_ about each missing (needed but absent) formatter.

exit 0
