#!/usr/bin/env fish

function usage
    echo "Usage: batch_rename.fish [OPTIONS] <match-pattern> <replacement>"
    echo
    echo "Batch rename files in the current directory using regex."
    echo
    echo "Options:"
    echo "  -r, --recursive      Rename files recursively (in subdirectories)"
    echo "  -d, --dry-run        Show what would be renamed, but don't actually rename"
    echo "  -h, --help           Show this help message"
    echo
    echo "Example:"
    echo "  batch_rename.fish '[ ]+' '_'"
    echo "      Replaces all runs of spaces with underscores in filenames"
end

function main
    set -l recursive 0
    set -l dryrun 0

    # Parse options
    while set -q argv[1]
        switch $argv[1]
            case -r --recursive
                set recursive 1
                set -e argv[1]
            case -d --dry-run
                set dryrun 1
                set -e argv[1]
            case -h --help
                usage
                exit 0
            case --*
                echo "Unknown option: $argv[1]"
                usage
                exit 1
            case '*'
                break
        end
    end

    if test (count $argv) -lt 2
        usage
        exit 1
    end

    set -l match_regex $argv[1]
    set -l replacement $argv[2]

    if test $recursive -eq 1
        set -l files (find . -type f | string trim -c './')
    else
        set -l files (ls -1)
    end

    set -l count 0
    for file in $files
        if test -f "$file"
            # Use string match and string replace --regex for regex support
            set -l newfile (string replace --regex -- $match_regex $replacement -- $file)
            if test "$file" != "$newfile"
                if test $dryrun -eq 1
                    echo "Would rename: '$file' -> '$newfile'"
                else
                    mv -- "$file" "$newfile"
                    echo "Renamed: '$file' -> '$newfile'"
                end
                set count (math $count + 1)
            end
        end
    end

    if test $count -eq 0
        echo "No files matched the pattern."
    end
end

main $argv
