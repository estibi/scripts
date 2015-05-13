#! /bin/sh

export PATH=/usr/bin:/usr/sbin

LIMIT=40
TO_REMOVE=20

cleanup() {
    for i in `zfs list -r -t snapshot -H -o name ${DATASET} | \
        grep "${DATASET}@backup_[0-9][0-9][0-9][0-9][0-3][0,2-9]" | \
        head -${TO_REMOVE}`
    do
        zfs list ${i} && time zfs destroy ${i};
    done
}

show_snapshots() {
    zfs list -r -t snapshot -H -o name ${DATASET} |
        grep "${DATASET}@backup_[0-9][0-9][0-9][0-9][0-3][0,2-9]"
}

show_usage() {
    zfs get usedbydataset,usedbysnapshots ${DATASET}
}


for DATASET in $(zfs list -r -H -o name -t filesystem,volume)
do
    echo "DATASET: ${DATASET}"
    SNAP_NUM=$(zfs list -r -t snapshot -H -o name ${DATASET} | \
        grep "${DATASET}@backup_[0-9][0-9][0-9][0-9][0-3][0,2-9]" | wc -l)
    echo "${SNAP_NUM} snapshots"

    if [ ${SNAP_NUM} -gt ${LIMIT} ]; then
        echo "MORE THEN ${LIMIT}"
        cleanup
        show_snapshots
        show_usage
    fi

    echo
done

# EOF
