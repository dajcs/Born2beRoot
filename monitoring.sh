#!/bin/bash
# Broadcast system health to every logged-in TTY

#── grab data ————————————————————————————————————————————————
arch=$(uname -a)

nr_sockets=$(lscpu | grep -i "Socket(s):" | awk '{print $NF}')

physical_cores=$(lscpu -b -p=Core,Socket | grep -v '^#' | sort -u | wc -l)

virt_cpu=$(grep -c ^processor /proc/cpuinfo)

read total_mem used_mem <<<$(free -m | awk '/Mem:/ {print $2, $3}')
mem_pct=$(awk "BEGIN {printf \"%.1f\", $used_mem/$total_mem*100}")

read total_disk used_disk <<<$(df -BM --total | awk '/total/ {print substr($2,1,length($2)-1), substr($3,1,length($3)-1)}')
disk_pct=$(awk "BEGIN {printf \"%.1f\", $used_disk/$total_disk*100}")

# sudo apt install sysstat
cpu_pct=$(mpstat | grep "all" | awk '{print 100 - $NF}')

last_boot=$(who -b | awk '{print $3, $4}')

lvm_active=$(lsblk | grep -q " lvm " && echo "yes" || echo "no")

# tcp_conn=$(ss -ta state established 2>/dev/null | grep -c ESTAB)
tcp_conn=$(ss -ta | grep ESTAB | wc -l)

logged_users=$(who | wc -l)

ip_addr=$(hostname -I | awk '{print $1}')
mac_addr=$(ip link show | awk '/link\/ether/ {print $2; exit}')

sudo_runs=$(sudo find /var/log/sudo -type f 2>/dev/null | wc -l)

datetime=$(date)

#── build message ——————————————————————————————————————————————
msg=$(cat <<EOF
$arch

# Nr CPU sockets : $nr_sockets
# Phys CPU cores : $physical_cores
# Virt CPU cores : $virt_cpu
# RAM Usage      : ${used_mem}/${total_mem} MB (${mem_pct}%)
# Disk Usage     : ${used_disk}/${total_disk} GB (${disk_pct}%)
# CPU Load       : ${cpu_pct}%
# Last Boot      : $last_boot
# LVM Active     : $lvm_active
# TCP Conns      : $tcp_conn ESTABLISHED
# Users Logged   : $logged_users
# IP / MAC       : $ip_addr  ($mac_addr)
# sudo Commands  : $sudo_runs
# TimeStamp      : $datetime
EOF
)

#── broadcast without the “wall” banner ————————————————
/usr/bin/wall -n "$msg"

