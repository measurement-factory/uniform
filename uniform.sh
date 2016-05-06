#! /usr/bin/env sh

# process command line options
FilterBefore=""
FilterAfter=""
use_force=""
while test ${#} -gt 0
do
    case "$1" in
        --filter-before)
            shift;
            FilterBefore="$1";
            ;;

        --filter-after)
            shift;
            FilterAfter="$1";
            ;;

        --force)
            use_force=1;
            ;;

        --)
            shift;
            break;
            ;;

        *)
            break;
            ;;
    esac
    shift;
done

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
    echo "The files listed above are modified but not yet staged for commit."

    if test -z "$use_force"; then
        echo "Either stage/commit these files or run with --force."
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

    # XXX: exit only exits the loop if called from an echo|while loop below
    exit $exit_code
}

findConfig() {
    fname="$1"

    # in the current directory
    test -e "./$fname" && echo "./$fname" && return;

    # in the top-level directory of the current repository
    topDir=`git rev-parse --show-toplevel`
    test -e "$topDir/$fname" && echo "$topDir/$fname" && return;

    # in the code-style directory of the current repository
    csDir="$topDir/code-style"
    test -e "$csDir/$fname" && echo "$csDir/$fname" && return;
}

uncrustifyOpt="--no-backup -L1"
uncrustifyCfg="`findConfig uncrustify.cfg`"
if test -n "$uncrustifyCfg"
then
    uncrustifyOpt="$uncrustifyOpt -c $uncrustifyCfg"
fi

uniformdir=`dirname $0`
echo "$files" | while IFS= read -r file; do
    # run formatter on file
    filename=$(basename "$file")
    extension="${filename##*.}"

    if test "$extension" = "js"; then
        test -e "$uniformdir/javascript-formatter" || contunue
        tempfile=`mktemp`
        test -n "$FilterBefore" && $FilterBefore "$file"
        node "$uniformdir/javascript-formatter" "$file" 1> "$tempfile" || cleanup $?

        # OS X lacks --reference in chmod.
        unamestr=`uname`
        if test "$unamestr" = "Darwin"; then
            filemode=`stat -n -f "%p" "$file"`
            chmod $filemode "$tempfile" || cleanup $?
        else
            chmod --reference="$file" "$tempfile" || cleanup $?
        fi

        mv "$tempfile" "$file" || cleanup $?
        test -n "$FilterAfter" && $FilterAfter "$file"
    fi

    if test "$extension" = "cc" -o "$extension" = "cpp" -o \
        "$extension" = "h" -o "$extension" = "hpp";
    then
        command -v uncrustify >/dev/null 2>&1 || continue
        test -n "$FilterBefore" && $FilterBefore "$file"
        uncrustify $uncrustifyOpt "$file" || cleanup $?
        # run again; uncrustify fails to fix some problems [correctly]
        # during the first run!
        uncrustify $uncrustifyOpt "$file" || cleanup $?
        test -n "$FilterAfter" && $FilterAfter "$file"
    fi
done

# TODO: Warn _once_ about each missing (needed but absent) formatter.

exit $?
