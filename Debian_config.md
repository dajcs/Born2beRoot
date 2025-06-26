
# Debian setup

After reboot enter HD decrypt password and login with user `anemet`


## 0 - Installing sudo & adding it in groups


First we need to install sudo.

```bash
# 1) Become root (if you aren’t already)
su -

# 2) Pull the package
apt update
apt install -y sudo

# 3) Grant your user sudo rights
usermod -aG sudo anemet

# 4) Reload group membership
exit                        # leave the root shell
exec su - anemet            # log again in to get the sudo superpowers
```

Test:

```bash
sudo -v                     # should ask for your password, then succeed
```
`sudoers` is already set up so anyone in the sudo group gains full sudo access; no manual editing needed.

Since we are working with groups and the project asks us to create group `user42` and add the login user to it:

```bash
sudo addgroup user42
sudo adduser anemet user42
groups anemet    # check result
```

Verify if user was successfully added to **sudo** group.

```bash
getent group sudo
```


## 1 - Install `vim` - might come handy later


```bash
sudo apt install vim
echo "set number" > ~/.vimrc          # to display line number by default
sudo echo "set number" > /root/.vimrc      # to display line number when editing as root
```



## 2 - Installing SSH

```bash
sudo apt install -y openssh-server
```

Edit `/etc/ssh/sshd_config` (use the newly installed `vim`):

```bash
sudo vim /etc/ssh/sshd_config
```


Change `#Port 22` to `Port 4242` and \
`#PermitRootLogin prohibit-password` to `PermitRootLogin no`

```bash
# Change #Port 22 to
Port 4242

# Change #PermitRootLogin prohibit-password to
PermitRootLogin no
```

Difference between `sshd_config` and `ssh_config`?

- `ssh_config` - configures the client
- `sshd_config` - configures the server

Start the service and enable it on boot:

```bash
sudo systemctl restart ssh
sudo systemctl enable  ssh      # start on boot
```

---

> ### Note: What is `systemctl`?
>
> - `systemctl` is the Swiss-army knife for systemd, the init system and service manager that boots Debian (and most modern Linux distros) and keeps everything running
> - Old Debian used a pile of SysV init scripts in `/etc/init.d/`. They were simple but brittle and slow. Systemd replaced that with:
>     - **Units** - declarative files (`*.service`, `*.socket`, `*.mount`, …) that describe how to start, stop, order, and monitor things.
>     - **cgroups** + **journald** - process tracking and unified logging
>    - **Parallel boot** - starts independent units at the same time, shaving seconds off boot
>    - `systemctl` is the CLI frontend to summon these units, in our case it spared us a restart

---

Verify SSH listening:

```bash
ss -lnt | grep 4242
```


Test `ssh` into VM

```bash
ssh anemet@127.0.0.1 -p 4242 # or
ssh anemet@0.0.0.0 -p 4242 # or
ssh anemet@localhost -p 4242
```

Test that `root` ssh is not permitted:

```bash
ssh root@127.0.0.1 -p 4242
```

---
## Note: SSH from Ubuntu/Windows host to the Debian VM
- **Why**: This is one more extra test, but more importantly after this setup and ssh to Debian VM you can use the **copy/paste in the terminal**.
- **Concept**: You will tell VirtualBox: "Any connection that comes to my host machine on a specific port (e.g., 2222) should be forwarded to the guest machine's IP on port (4242)."
- **Steps**:
    - Shut down your Debian VM.
    - In VirtualBox, select your Debian VM and go to Settings > Network.
    - Ensure "Attached to:" is still set to NAT (Network Address Translation, the default setting)
    - Expand the "Advanced" section and click the "Port Forwarding" button.
    - Click the green "+" icon to add a new rule.
    - Fill in the fields like this:
        - Name: SSH (or any name you like)
        - Protocol: TCP
        - Host IP: Leave blank
        - Host Port: 2222 -- in theory you can pick any unused port above 1024, but port 4242 was not working at 42 Luxembourg, so I choose a different one
        - Guest IP: 10.0.2.15  (Your Debian VM's IP, check with command: `hostname -I` )
        - Guest Port: 4242 (The SSH port set up previously)
    - Click OK on all windows to save.

Alternatively the Virtualbox GUI setting can be replaced by the command line below in the Host terminal:

```bash
# this command should be entered on the Ubuntu host
VBoxManage modifyvm "Born2beRoot" --natpf1 "ssh,tcp,,2222,10.0.2.15,4242"
```

You can add another redirecting port 2223, and this will allow to ssh into VM simultaneously from 2 different terminals on your host (to execute special tests or just to play around):

```bash
# this command should be entered on the Ubuntu host
VBoxManage modifyvm "Born2beRoot" --natpf1 "ssh,tcp,,2223,10.0.2.15,4242"
```


    - Start your Debian VM.
- **How to Connect from Ubuntu**:  \
    Now, from your Ubuntu host terminal, you will SSH to your own host machine (localhost or 127.0.0.1) on the port you specified (2222). VirtualBox will catch this and forward it to the guest (on port 4242).
    ```bash
    # On your Ubuntu Host
    # You are connecting to your own machine (localhost) on the forwarded port
    ssh anemet@127.0.0.1 -p 2222
    ```
- **How to Connect from Windows**:  \
If you have a Windows host, you can use the WSL (Windows Subsystem for Linux) terminal for login, but there is an extra step to find out the WSL terminal default gateway IP address. WSL and the Windows host are on different networks, so we have to use this gateway IP instead of localhost in the previous case.
    ```bash
    # get the IP of the Default Gateway inside the WSL terminal
    ip route | grep default | awk '{print $3}'
    # 172.28.160.1

    # use this <def_GW_IP> instead of localhost to ssh to Debian
    ssh anemet@172.28.160.1 -p 2222
    ```
---

## 3 - Installing UFW

UFW - Uncomplicated FireWall

```bash
sudo apt install -y ufw

# default deny incoming, allow outgoing
sudo ufw default deny incoming
sudo ufw default allow outgoing

# allow SSH on 4242/tcp only
sudo ufw allow 4242/tcp comment 'SSH service'

# enable and make persistent
sudo ufw enable      # answers “y” to the prompt
sudo systemctl enable ufw
```

Quick sanity check:

```bash
sudo ufw status verbose
```
you should see:

```vbnet
anemet@anemet42:~$ sudo ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
4242/tcp                   ALLOW IN    Anywhere                   # SSH service
4242/tcp (v6)              ALLOW IN    Anywhere (v6)              # SSH service
```



## 4 - Configuring sudo

- `sudo` must be installed following these rules:
    - authentication using sudo has to be limited to 3 attempts in the event of an incorrect password.
    - a custom message has to be displayed if an error due to a wrong password occurs when using sudo
    - each action using sudo has to be archived, both inputs and outputs. The log file has to be saved in the `/var/log/sudo` folder.
    - the TTY mode has to be enabled for security reasons.
    - for security reasons too, the paths that can be used by sudo must be restricted. Example:
      `/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin`

### 4.1 Prepare the log directory

```bash
sudo mkdir -p /var/log/sudo
sudo chmod 0700 /var/log/sudo
sudo chown root:root /var/log/sudo
```

### 4.2 `visudo`

The `sudo` configuration is stored in the file `/etc/sudoers.d/sudoconfig`. This file should not be edited directly, edit **only** through command `visudo`:

```bash
sudo visudo
```

Insert the block below **after** the existing `Defaults` lines:

```bash
###############################################################################
##  Hardening rules – required by Born2beRoot
###############################################################################

# 3 attempts max
Defaults        passwd_tries=3

# Custom error on bad password
Defaults        badpass_message="Access denied: incorrect password."

# Full I/O logging (command, stdin, stdout, stderr)
Defaults        log_input, log_output
# sub-dir per user
Defaults        iolog_dir=/var/log/sudo/%{user}
# file per run (timestamp)
Defaults        iolog_file=%Y%m%d-%H%M%S-%{command}

# Force an attached TTY
Defaults        requiretty

# Tight PATH in sudo context
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
```

Save & exit; `visudo` will refuse to close if you mistyped anything.

### 4.3 Verify hardened sudo rules

```bash
# as the normal user
sudo -l                   # display Defaults / allowed commands

sudo -k                   # forget cached creds

# intentionally fail 3×
sudo ls -al /root   # intentionally enter wrong password 3x

# succeed once and run something
sudo apt update

# confirm logs exist
sudo ls -lrt /var/log/sudo/anemet

# replays the I/O capture of a command, e.g. replay previous `apt update`
sudo sudoreplay /var/log/sudo/anemet/apt_11:52:58
```




## 5 - Setting up a strong password policy


- a strong password policy should be implemented:
    - the password has to expire every 30 days
    - the minimum number of days allowed before the modification of a password will be set to 2
    - warning message 7 days before the password expires
    - password at least 10 characters long. Must contain an uppercase letter, a lower case letter and a number. It must not contain more than 3 consecutive identical characters.
    - the password must not include the name of the user
    - the password must have at least 7 characters not part of the former password
    - the root password has to comply with this policy, except the last "7 character" rule


### 5.1 Password-age policy (30 / 2 / 7)

```bash
sudo vim /etc/login.defs
```

```bash
PASS_MAX_DAYS   30   # expire after 30 days
PASS_MIN_DAYS    2   # must wait 2 days before changing again
PASS_WARN_AGE    7   # 7-day heads-up e-mail + login banner
```

These values will be used for every new account at creation.

For any account that already exists (including root) run:

```bash
sudo chage -M 30 -m 2 -W 7 anemet     # update psw aging for user anemet
sudo chage -M 30 -m 2 -W 7 root       # update psw aging for root
```

### 5.2 Quality rules (length, character classes, repeats, username test, 7-char diff)

Install the helper `libpam-pwquality`:

```bash
sudo apt install -y libpam-pwquality
```

Then open `/etc/security/pwquality.conf`:

```bash
sudo vim /etc/security/pwquality.conf
```

and perform requested password quality settings by uncommenting the lines and setting the corresponding values

```bash

difok           = 7         # ≥7 chars different from previous
minlen          = 10        # ≥10 chars
dcredit         = -1        # at least 1 digit
ucredit         = -1        # at least 1 uppercase
lcredit         = -1        # at least 1 lowercase
maxrepeat       = 3         # no “aaaa”, “1111”…
usercheck       = 1         # forbid name inside password
enforce_for_root            # root must obey (see note below)

```

**root exception**
pam_pwquality can’t compare old vs. new when root changes its own password—the old hash is never asked for -- so `difok=7` simply doesn’t apply to root, yet all the other checks still do.


### 5.3 Wire the module into PAM (if the installer didn’t already)



Open `/etc/pam.d/common-password`:

```bash
sudo vim /etc/pam.d/common-password
```

...and make sure it has the line below (or add it if missing):
```bash
password  requisite  pam_pwquality.so retry=3
```

That's it -- from now `pwquality.conf` drives the rules.


Change previous passwords to comply with the new rules:

```bash
passwd          # for login user anemet
sudo passwd     # for root
```

### 5.4 Password Policy setup check

```bash
# create a throw-away user for tests
sudo adduser demo
# try several week passwords: demo, demo1, Demo1:
# ----------------------------------------------
# Adding user `demo' ...
# Adding new group `demo' (1002) ...
# Adding new user `demo' (1002) with group `demo (1002)' ...
# Creating home directory `/home/demo' ...
# Copying files from `/etc/skel' ...
# New password:
demo
# BAD PASSWORD: The password contains less than 1 digits
# New password:
demo1
# BAD PASSWORD: The password contains less than 1 uppercase letters
# New password:
Demo1
# BAD PASSWORD: The password is shorter than 10 characters
# passwd: Have exhausted maximum number of retries for service
# passwd: password unchanged
# Try again? [y/N]
y
# some more passwords: Demo1Demo1111, Demo1Demo111, Test1Test111
# New password:
Demo1Demo1111
# BAD PASSWORD: The password contains more than 3 same characters consecutively
# New password:
Demo1Demo111
# BAD PASSWORD: The password contains the user name in some form
# New password:
Test1Test111
# Retype new password:
# passwd: password updated successfully
# Changing the user information for demo
# Enter the new value, or press ENTER for the default
# 	Full Name []: Demo
# 	Room Number []:
# 	Work Phone []:
# 	Home Phone []:
# 	Other []:
# Is the information correct? [Y/n]
# Adding new user `demo' to supplemental / extra groups `users' ...
# Adding user `demo' to group `users' ...

```

```bash
# delete demo user and remove it's home directory
sudo userdel -r demo
```

## 6. The `monitoring.sh` script

- create a simple script called `monitoring.sh` developed in `bash`.
- at server startup, the script will display the informations listed below on all terminals and every 10 minutes. The banner is optional. No error must be visible. The script displays:
    - the architecture of the OS and its kernel version
    - the number of physical processors
    - the number of virtual processors
    - the current available RAM and its utilization rate as a percentage.
    - the current available storage and its utilization rate as a parcentage.
    - the current utilization rate of the processors as a percentage
    - the date and time of the last reboot
    - whether LVM is active or not
    - the number of active connections
    - the number of users using the server
    - the IPv4 address of the server and its MAC address.
    - the number of commands executed with the `sudo` program


### 6.1 Commands used to collect the requested info

#### 6.1.1 The architecture of the OS and its kernel version

```bash
uname -snrvm
# Linux anemet42 6.1.0-37-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.140-1 (2025-05-22) x86_64
```
- -s, --kernel-name `Linux`
- -n, --nodename `anemet42`
- -r, --kernel-release `6.1.0-37-amd64`
- -v, --kernel-version `#1 SMP PREEMPT_DYNAMIC Debian 6.1.140-1 (2025-05-22)`
- -m, --machine `x86_64`

#### 6.1.2 The number physical CPU sockets, CPU cores

```bash
# getting nr_socket:
lscpu | grep -i "Socket(s):"
# Socket(s):                               1

# script command
nr_sockets=$(lscpu | grep -i "Socket(s):" | awk '{print $NF}')
```

```bash
# getting nr physical core:
lscpu -b -p=Core,Socket | grep -v "^#"
# 0,0
# 1,0

# script command
physical_cores=$(lscpu -b -p=Core,Socket | grep -v '^#' | sort -u | wc -l)
```

#### 6.1.4 The number of virtual CPU(s)

```bash
# getting nr virtual CPU:
grep  ^processor /proc/cpuinfo
# processor	: 0
# processor	: 1

# script command
virt_cpu=$(grep -c ^processor /proc/cpuinfo)
```

#### 6.1.5 Memory availability and utilization

```bash
free -m
#                total        used        free      shared  buff/cache   available
# Mem:            1967         255        1506           0         348        1711
# Swap:           2191           0        2191

# script command
read total_mem used_mem <<<$(free -m | awk '/Mem:/ {print $2, $3}')
mem_pct=$(awk "BEGIN {printf \"%.1f\", $used_mem/$total_mem*100}")
```

#### 6.1.6 Available storage and utilization


```bash
df -BM --total
# Filesystem                    1M-blocks  Used Available Use% Mounted on
# udev                               957M    0M      957M   0% /dev
# tmpfs                              197M    1M      197M   1% /run
# /dev/mapper/LVMGroup-root         9287M 1384M     7410M  16% /
# tmpfs                              984M    0M      984M   0% /dev/shm
# tmpfs                                5M    0M        5M   0% /run/lock
# /dev/mapper/LVMGroup-home         4611M    1M     4357M   1% /home
# /dev/sda1                          436M  118M      291M  29% /boot
# /dev/mapper/LVMGroup-srv          2743M    1M     2584M   1% /srv
# /dev/mapper/LVMGroup-tmp          2743M    1M     2584M   1% /tmp
# /dev/mapper/LVMGroup-var          2743M  237M     2348M  10% /var
# /dev/mapper/LVMGroup-var--log     5987M   51M     5612M   1% /var/log
# tmpfs                              197M    0M      197M   0% /run/user/1000
# total                            30887M 1790M    27521M   7% -

# script command
read total_disk used_disk <<<$(df -BM --total | awk '/total/ {print substr($2,1,length($2)-1), substr($3,1,length($3)-1)}')
disk_pct=$(awk "BEGIN {printf \"%.1f\", $used_disk/$total_disk*100}")
```

#### 6.1.7 CPU utilization rate

```bash
# install `sysstat`
sudo apt install sysstat

mpstat
# Linux 6.1.0-37-amd64 (anemet42) 	06/23/2025 	_x86_64_	(2 CPU)
#
# 05:14:10 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
# 05:14:10 PM  all    0.01    0.00    0.06    1.83    0.00    0.09    0.00    0.00    0.00   98.00

# script command
cpu_pct=$(mpstat | grep "all" | awk '{print 100 - $NF}')
```

#### 6.1.8 Last boot

```bash
uptime -s
# 2025-06-25 18:56:06

# script command
last_boot=$(uptime -s)
```

#### 6.1.9 LVM active

```bash
lsblk
# NAME                    MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
# sda                       8:0    0   31G  0 disk
# ├─sda1                    8:1    0  476M  0 part  /boot
# ├─sda2                    8:2    0    1K  0 part
# └─sda5                    8:5    0 30.5G  0 part
#   └─sda5_crypt          254:0    0 30.5G  0 crypt
#     ├─LVMGroup-root     254:1    0  9.3G  0 lvm   /
#     ├─LVMGroup-swap     254:2    0  2.1G  0 lvm   [SWAP]
#     ├─LVMGroup-home     254:3    0  4.7G  0 lvm   /home
#     ├─LVMGroup-var      254:4    0  2.8G  0 lvm   /var
#     ├─LVMGroup-srv      254:5    0  2.8G  0 lvm   /srv
#     ├─LVMGroup-tmp      254:6    0  2.8G  0 lvm   /tmp
#     └─LVMGroup-var--log 254:7    0    6G  0 lvm   /var/log
# sr0                      11:0    1 1024M  0 rom

# script command
lvm_active=$(lsblk | grep -q " lvm " && echo "yes" || echo "no")
```

#### 6.1.10 Number of active connections

```bash
ss -ta
# State         Recv-Q        Send-Q                Local Address:Port                 Peer Address:Port         Process
# LISTEN        0             128                         0.0.0.0:4242                      0.0.0.0:*
# ESTAB         0             0                         10.0.2.15:4242                     10.0.2.2:46420
# LISTEN        0             128                            [::]:4242                         [::]:*

# script command
tcp_conn=$(ss -ta | grep ESTAB | wc -l)
```

#### 6.1.11 Number of users logged in the server

```bash
who
# anemet   tty1         2025-06-23 08:14
# anemet   pts/0        2025-06-23 08:16 (10.0.2.2)

# script command
logged_users=$(who | wc -l)
```

#### 6.1.12 IP address

```bash
hostname -I
# 10.0.2.15

# script command
ip_addr=$(hostname -I | awk '{print $1}')
```

#### 6.1.13 MAC address

```bash
ip link show
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
#     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
# 2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
#     link/ether 08:00:27:c5:54:9a brd ff:ff:ff:ff:ff:ff

#script command
mac_addr=$(ip link show | awk '/link\/ether/ {print $2; exit}')
```

#### 6.1.14 Number of commands executed with `sudo`

```bash
journalctl -q _COMM=sudo | tail
# Jun 25 19:35:27 anemet42 sudo[1381]: pam_unix(sudo:session): session closed for user root
# Jun 25 19:35:32 anemet42 sudo[1392]:   anemet : TTY=pts/0 ; PWD=/etc/update-motd.d ; USER=root ; TSID=20250625-193532-nano ; # COMMAND=/usr/bin/nano 99-monitoring-banner
# Jun 25 19:35:32 anemet42 sudo[1392]: pam_unix(sudo:session): session opened for user root(uid=0) by anemet(uid=1000)
# Jun 25 19:39:54 anemet42 sudo[1392]: pam_unix(sudo:session): session closed for user root
# Jun 25 19:43:39 anemet42 sudo[1566]:   anemet : TTY=pts/2 ; PWD=/etc/update-motd.d ; USER=root ; TSID=20250625-194339-chmod ; # COMMAND=/usr/bin/chmod -x 10-uname
# Jun 25 19:43:39 anemet42 sudo[1566]: pam_unix(sudo:session): session opened for user root(uid=0) by anemet(uid=1000)
# Jun 25 19:43:39 anemet42 sudo[1566]: pam_unix(sudo:session): session closed for user root
# Jun 25 21:05:33 anemet42 sudo[2178]:   anemet : TTY=pts/2 ; PWD=/etc/update-motd.d ; USER=root ; TSID=20250625-210533-chmod ; # COMMAND=/usr/bin/chmod +x 10-uname
# Jun 25 21:05:33 anemet42 sudo[2178]: pam_unix(sudo:session): session opened for user root(uid=0) by anemet(uid=1000)
# Jun 25 21:05:33 anemet42 sudo[2178]: pam_unix(sudo:session): session closed for user root

#script command
sudo_runs=$(journalctl -q _COMM=sudo | grep "COMMAND=" | wc -l)
```


#### 6.1.15 Printing out the collected results

```bash
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


# ------------- broadcast $msg, -n: suppressing the banner ------
wall -n "$msg"

```

#### 6.1.16 Assembling the script `monitoring.sh`

Here is the assembled result of the script: [monitoring.sh](./monitoring.sh)


### 6.2 Crontab

Copy the content of [monitoring.sh](./monitoring.sh) into a file in the home directory.

```bash
sudo nano /home/monitoring.sh
```

Make executable

```bash
sudo chmod +x /home/monitoring.sh
```

Edit crontab

```bash
# -u root -> root's crontab, -e -> edit
sudo crontab -u root -e
```

- After last comment line `# m h dom mon dow command`
    - `m` - minutes
    - `h` - hours
    - `dom` - day of month
    - `mon` - month
    - `dow` - day of week
    - `command` - command to be executed

- edit the next line as follows:
```bash
# m   h  dom mon dow  command
*/10  *   *   *   *   /home/anemet/monitoring.sh
```

Check scheduled jobs

```bash
# -l -> list
sudo crontab -u root -l
# # m   h  dom mon dow   command
# */10  *   *   *   *    /home/anemet/monitoring.sh
```

There is one more task:
> **At server startup**, the script will display some information (listed below) on all terminals
and every 10 minutes ...

We could add the `@reboot` condition to the crontab:

```ini
# m   h  dom mon dow   command
*/10  *   *   *   *    /home/anemet/monitoring.sh
@reboot                sleep 20 && /home/anemet/monitoring.sh
```
- here we have several issues:
    - if we're executing the script without a delay of 20 seconds (`sleep 20`), then in the early boot phase there is no terminal ready yet to receive the display message
    - putting a random timer is still no perfect solution, the message will be displayed only if a user is logging in within the 20 seconds after reboot, otherwise the message is lost

- A better solution could be when the monitoring message is displayed at user login.

Let's implement the better solution.

Comment out the `@reboot` in the crontab:
```bash
sudo crontab -u root -e

# comment out or delete the line starting with @reboot
```
```ini
# m   h  dom mon dow   command
*/10  *   *   *   *    /home/anemet/monitoring.sh
#@reboot                sleep 20 && /home/anemet/monitoring.sh
```
- save the file

- goto the update "Message Of The Day" directory
```bash
cd /etc/update-motd.d/
```
- copy file `~/monitoring.sh` as `99-monitoring`
```bash
sudo cp ~/monitoring.sh ./99-monitoring
```
- edit file `99-monitoring` and replace in the last line the `wall -n` command with `echo`
```bash
sudo vim 99-monitoring

# replace: wall -n  "$msg"
# with   : echo "$msg"
```
- the file `10-uname` in the `update-motd.d` directory is displaying the architecture, which is already in our script, therefore we can take away the executable rights from `10-uname`:
```bash
sudo chmod -x 10-uname

# check files in directory
 ls -l
total 8
-rw-r--r-- 1 root root   23 Apr  4  2017 10-uname
-rwxr-xr-x 1 root root 1776 Jun 25 23:44 99-monitoring
```

- check if these settings display monitoring message at login
```bash
ssh anemet@localhost -p 4242
# anemet@localhost's password:
#
# Linux anemet42 6.1.0-37-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.140-1 (2025-05-22) x86_64
#
# # Nr CPU sockets : 1
# # Phys CPU cores : 2
# # Virt CPU cores : 2
# # RAM Usage      : 514/1967 MB (26.1%)
# # Disk Usage     : 2302/30887 GB (7.5%)
# # CPU Load       : 0.49%
# # Last Boot      : 2025-06-25 18:56:06
# # LVM Active     : yes
# # TCP Conns      : 5 ESTABLISHED
# # Users Logged   : 3
# # IP / MAC       : 10.0.2.15  (08:00:27:c5:54:9a)
# # sudo Commands  : 408
# # TimeStamp      : Wed Jun 25 23:52:00 CEST 2025
#
# The programs included with the Debian GNU/Linux system are free software;
# the exact distribution terms for each program are described in the
# individual files in /usr/share/doc/*/copyright.
#
# Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
# permitted by applicable law.
# Last login: Wed Jun 25 23:51:40 2025 from 172.28.161.182
# anemet@anemet42:~$
```
