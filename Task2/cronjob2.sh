
#!/bin/bash
set +x

cd /Task2/ || exit

function calculate1AVG()
{
   data=""

   TIMESTAMP=$(date '+%Y-%m-%d_%H:%M:%S')

   files=$(ls -1t | grep "$1")
   for f in $files; do
      # Read each line in the files and send data to HTML
      while read -r value; do
         time=$(echo $f | awk -F'_' '{print $4 "\t" $5}')
         data+="&nbsp;$value &nbsp;  &nbsp; &nbsp; $time<br>"
      done < "$f"
   done

     sum=0
     count=0

     # iterate through the last 5 files and calculate the avg
     files=$(ls -1t | grep "$1" | tail -n 5)

     for f in $files; do
         while read -r value; do
            sum=$(awk -v sum="$sum" -v value="$value" 'BEGIN {print sum + value}')
            count=$((count + 1))
            done < "$f"
     done

   if [ $count -ne 0 ]; then
        average=$(awk -v sum="$sum" -v count="$count" 'BEGIN {print sum / count}')
    else
        average=0
    fi

    echo "$average $TIMESTAMP" >> /Task2/cAVG.txt


}


function calculate2AVG() {

  freeavg=0
  usedavg=0
  data2=""

  files=$(ls -1t | grep "$1")

  # iterate through files and send data to HTML
  for ff in $files; do
     while read -r free1 used1; do
           time=$(echo $ff | awk -F'_' '{print $4 "\t" $5}')
           data2+="  $free1  &ensp; $used1 &ensp; $time<br>"
      done < "$ff"
  done

   #iterate through the last 5 files and calculate AVG
   files=$(ls -1t | grep "$1" | tail -n 5)

      for ff in $files; do
        sumfree=0
        sumused=0
        count=0
        while read -r free used; do
           sumfree=$(awk -v sum1="$sumfree" -v value1="$free" 'BEGIN {print sum1 + value1}')
           sumused=$(awk -v sum2="$sumused" -v value2="$used" 'BEGIN {print sum2 + value2}')
           count=$((count + 1))
         done < "$ff"
      done

    if [ $count -ne 0 ]; then
        freeavg=$(awk -v sum1="$sumfree" -v count="$count" 'BEGIN {print sum1 / count}')
        usedavg=$(awk -v sum2="$sumused" -v count="$count" 'BEGIN {print sum2 / count}')

    else
        freeavg=0
        usedavg=0
    fi

    echo "$freeavg $usedavg $TIMESTAMP" $ >> /Task2/MAVG.txt

}


function calculate3AVG()
{
  # Initialize associative arrays to hold the sum and count for each disk
   declare -A free_sum
   declare -A available_sum
   count=0

   data3=""

  files=$(ls -1t | grep "$1")

  # Iterate over files and send data to HTML
  for fff in $files; do
      while read -r disk free available; do
          time=$(echo $fff | awk -F'_' '{print $4 "\t" $5}')
           data3+=" &emsp; $disk &emsp; &emsp;  &emsp;  &emsp; $free  &emsp; &emsp; &emsp;  $available &emsp; &emsp;  &emsp; $time  <br>"
      done < "$fff"
  done

  files=$(ls -1t | grep "$1" | tail -n 5)
  for fff in $files; do
      while read -r disk free available; do
          # Add the values to the corresponding disk's sum and increase the count
          free1=$(echo $free | tr -d 'M')
          available1=$(echo $available | tr -d 'M')
          free_sum[$disk]=$((${free_sum[$disk]:-0} + $free1))
          available_sum[$disk]=$((${available_sum[$disk]:-0} + $available1))
          count=$(( count + 1))
      done < "$fff"
   done

  data3AVG=""

  for disk in "${!free_sum[@]}"; do
      avg_free=$(echo "${free_sum[$disk]} / ${count}" | bc)
      avg_available=$(echo "${available_sum[$disk]} / ${count}" | bc)
      echo "$disk $avg_free $avg_available $TIMESTAMP" >> /Task2/dAVG.txt
      data3AVG+="Disk $disk Free space average = $avg_free M and Average used space = $avg_available M taken at $time <br>"

  done

   echo "$disk $avg_free $avg_available $TIMESTAMP" >> /Task2/dAVG.txt


}

calculate1AVG cpu

calculate2AVG memory

calculate3AVG disk

cat << EOF > /var/www/html/cpu.html

  <title>CPU</title>
  <body style="background-color:powderblue;">
  <h1 style="font-family:verdana; text-align:center;"  > Task 2 </h1>
  <h2 style="font-family:verdana; text-align:center;" > CPU statistics </h2>

  <h2> Average CPU Utilization = $average taken at $TIMESTAMP </h2>
  <h2> Collected data : </h2>
  <h2> Value &nbsp; TimeStamp </h2>
  <h3> ${data} </h3>
  </body>

EOF



cat << EOF > /var/www/html/memory.html

  <title>Memory</title>
  <body style="background-color:powderblue;">
  <h1 style="font-family:verdana; text-align:center;"  > Task 2 </h1>
  <h2 style="font-family:verdana; text-align:center;" > Memory statistics </h2>

  <h2> Average Used Memory  = $usedavg taken at $TIMESTAMP </h2>
  <h2> Average Free Memory  = $freeavg taken at $TIMESTAMP </h2>
  <h2> Collected data : </h2>
  <h2> &nbsp; Free &ensp; Used  &ensp; TimeStamp </h2>
  <h3> ${data2} </h3>
  </body>

EOF

cat << EOF > /var/www/html/disk.html

   <title>Disk</title>
   <body style="background-color:powderblue;">
   <h1 style="font-family:verdana; text-align:center;">Task 2</h1>
   <h2 style="font-family:verdana; text-align:center;">Disk statistics</h2>

   <h2>$data3AVG</h2>
   <h2>Collected data:</h2>
   <h2>&nbsp; DiskName &emsp; AverageFree &emsp; AverageUsed &emsp; TimeStamp</h2>
   <h3>${data3}</h3>
   </body>

EOF
