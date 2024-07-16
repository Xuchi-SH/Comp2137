# Parse command-line arguments
echo "$@"
param1=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        -verbose)
            VERBOSE=true
	    echo "verbose is true"
	    param1=" -verbose"
            ;;
        *)
	    echo "wrong inputs"
            exit 1
            ;;
    esac
    shift
done

ssh remoteadmin@server2-mgmt -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3 -verbose

eval "ssh remoteadmin@server2-mgmt -- /root/configure-host.sh -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3 $param1"


