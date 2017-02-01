set -x
if [ $# != 2 ]; then
    echo "Usage: $0 <shmdir> <output>"
    exit 1
fi

timeline=$1/engine/timeline
csv=$2
[ -f $timeline ] || (echo "file not found: $timeline"; exit 1)

#(snabb; true) > $csv
snabb snsh -e "require('core.timeline').dump('$timeline')" > $csv


