
#!/bin/bash
# This script monitors CPU, Memory and Disk usage

 # for debugging
 set +x

 # get the the timestamp
 TIMESTAMP=$(date '+%Y-%m-%d_%H:%M:%S')

  # Get the current usage of each item
  cpuUsage=$(top -bn1 | awk '/Cpu/{print $2}')
  memUsage=$(free -h  | awk '/Mem/{print $3}')
  freeMem=$(free -h   | awk '/Mem/{print $4}')

lsblk -l -o NAME,TYPE,MOUNTPOINT -n | while read name type mount; do
  if [[ -n "$mount" && "$mount" != "[SWAP]" ]]; then
     df -BM "$mount" | tail -n +2 | awk -v name="$name" '{print name "(part) " $3" " $4}' >> /Task2/disk_usage_at_${TIMESTAMP}_.txt
  fi

  if [[ "$type" == "disk" ]]; then
     df -BM "/dev/$name" | tail -n +2 | awk -v name="$name" '{print name "(Disk) " $3" " $4}' >> /Task2/disk_usage_at_${TIMESTAMP}_.txt
  fi

done


  # store each item data in a file named with the item name and the timestamp
  echo "$cpuUsage" >> /Task2/cpu_usage_at_${TIMESTAMP}_.txt

  echo "$freeMem $memUsage" >> /Task2/memory_usage_at_${TIMESTAMP}_.txt
