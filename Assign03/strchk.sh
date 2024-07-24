
desired_ip=$1
desired_name=$2
aaa=$(grep -E "^\s*$desired_ip\s+$desired_name(\s|$)" ./hosts)
echo "$aaa"

