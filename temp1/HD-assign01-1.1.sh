#!/bin/bash


#=========================Hardware Information Section=================================
# Get CPU Information
CPUINFO=$(lscpu | grep "Model name"|sed 's/Model name:\s*//')
# Get Maxium and Current CPU Speed. 
CURSPD=$(< /proc/cpuinfo grep MHz | sort -n -k 4 | head -n 1 | sed 's/.*: //')"MHz(Current)"
MAXSPD=$(< /proc/cpuinfo grep MHz | sort -r -k 4 | head -n 1 | sed 's/.*: //')"MHz(Maximum)"
# Get Memory Size 
RAMSIZE=$(free -h | grep Mem | awk '{print $2}')
# Get Video Information
VIDEOINFO=$(lspci | grep -i "VGA" | sed 's/.*controller: //')

echo
echo "Hardware Information"
echo "--------------------"
echo "cpu: $CPUINFO"
echo "Speed: $CURSPD $MAXSPD"
echo "Ram: $RAMSIZE"

echo "Disk(s):"
# Get the harddisk information
# 1, grep: get the section of each harddisk
# 2, 1) awk: get the disk type, manufacturer, logcial name and size by the key words of description, vendor, logical name and size
#    2) output format: title row, then disk information rows
sudo lshw -c disk | grep 'SCSI Disk' -A 9 | awk '

BEGIN {
    # Print the header
#    printf "%-20s %-20s %-20s %-20s\n", "Description", "Vendor", "Logical Name", "Size"
   printf "%-12s %-10s %-12s %-10s\n", "Disk Type", "Vendor", "Name", "Size"
}

/description/ {desc = $2 " " $3}
/vendor:/ {vendor = substr($2, 1, length($2) - 1)}
/logical name:/ {name = $3}
/size:/ {size = $2}
{
    if (desc && vendor && name && size) {
#       printf "%-20s %-20s %-20s %-20s\n", desc, vendor, name, size
        printf "%-12s %-10s %-12s %-10s\n", desc, vendor, name, size
        desc = vendor = name = size = ""
    }
}'

echo "Video: $VIDEOINFO"

