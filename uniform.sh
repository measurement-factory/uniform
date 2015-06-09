#! /usr/bin/env sh

use_force=""
if test "$1" = "--force"; then
    use_force=1
    shift
fi

if test "$1" = "--"; then
    shift
fi

args=$@

# --name-only = Only show filepath
# -r = Recurse into subtrees
# HEAD = look at current git commit
# $args is passed to allow specifying specific files
files=`git ls-tree -r --name-only HEAD $args`

if !(git diff --name-only --exit-code $args); then
    echo "The files listed above have been changed since last commit."

    if test -z "$use_force"; then
        echo "Commit these files or run with --force."
        exit 1
    else
        echo "Proceeding anyway: --force given."
    fi
fi

uniformdir=dirname $0
for file in $files; do
    # run formatter on file
    filename=$(basename $file)
    extension=${filename##*.}

    if test $extension = "js"; then
        tempfile=`mktemp`
        node "$uniformdir/pretty-generator.js" $file 1>$tempfile
        exit_code=$?
        if test $exit_code -ne 0; then
            exit $exit_code
        fi
        mv $tempfile $file || exit $?
    fi
done
