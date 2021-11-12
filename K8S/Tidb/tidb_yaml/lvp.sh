#!/bin/bash
for i in $(seq 1 5); do
  mkdir -p /mnt/disks-bind/vol${i}
  mkdir -p /mnt/disks/vol${i}
  mount --bind /mnt/disks-bind/vol${i} /mnt/disks/vol${i}
done
