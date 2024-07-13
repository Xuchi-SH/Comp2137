echo "Disk(s):"
# Get the harddisk information
# 1, grep: get the section of each harddisk
# 2, 1) awk: get the disk type, manufacturer, logcial name and size by the key words of description, vendor, logical name and size
#    2) output format: title row, then disk information rows
sudo lshw -c disk | grep 'SCSI Disk' -A 9 | awk '

BEGIN {
    # Print the header
    printf "%-20s %-10s %-12s %-10s\n", "   Model", " Make", " Name", " Size"
}


/description/ {desc = $2 " " $3}
/vendor:/ {vendor = substr($2, 1, length($2) - 1)}
/product:/ {for (i=2; i<=NF; i++) hdmodel=hdmodel " " $i;}
/logical name:/ {name = $3}
/size:/ {size = $2}
{
    if (desc && vendor && name && size && hdmodel) {
        printf "%-20s %-10s %-12s %-10s\n", hdmodel, vendor, name, size
        desc = vendor = name = size = hdmodel = ""
    }
}'

