#! /bin/sh

PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/local/sbin:/opt/local/bin:/usr/gnu/bin

NOW=$(date '+%y%m%d_%H:%M.%S')

for FS in $(zfs list -H -o name | grep -v rpool/dump | grep -v rpool/swap)
do
        echo "Current filesystem: ${FS}"
        unset snap_array
        for snapshot in $(zfs list -r -t snapshot -H -o name ${FS})
        do
                snap_array=("${snap_array[@]}" "${snapshot}")
        done

        if [ "${#snap_array[@]}" -gt 1 ]; then
                #echo "${snap_array[@]}"
                # filesystem has a snapshots
                snap_amount=${#snap_array[@]}
                offset=$(expr ${snap_amount} - 1)
                latest_snap_name=${snap_array[${offset}]}
                used_size=$(zfs get -Hp -o value used ${latest_snap_name})
                if [ ${used_size} -eq 0 ]; then
                        # no data were changed since the latest snapshot
                        continue
                fi
        fi
        echo
        echo "Creating new snapshot: ${FS}@backup_${NOW}"
        zfs snapshot ${FS}@backup_${NOW}
done

# EOF

