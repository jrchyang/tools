#!/bin/bash

module="all"

if ! GETOPT_ARGS=$(getopt -q -o rm:i --long rpm,module:inactive -- "$@");then
    echo "Error: Invalid option." >&2
    exit 1
fi
eval set -- "$GETOPT_ARGS"

# 获取参数
while [ -n "$1" ]; do
    case "$1" in
        -r|--rpm)
            echo "will build rpm"
            shift
            ;;
        -m|--module)
            if [ -z "$2" ]; then
                echo "Error: -m requires a value." >&2
                exit 1
            fi
	    module="$2"
            echo "will build module $module"
            shift 2
            ;;
        -i|--inactive)
            echo "will create inactively"
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "unimplemented option"
            exit 1
            ;;
    esac
done
