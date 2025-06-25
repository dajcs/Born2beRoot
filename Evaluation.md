# Evaluation Questions

Create a `signature.txt` of the virtual machine image on the Host machine.

```bash
# command on Ubuntu host terminal
sha1sum ~/goinfre/Born2beRoot/Born2beRoot.vdi > signature.txt

# check result
cat signature.txt
# 4070117ace51c2060df23cafb3b344c3444830b7  /home/anemet/goinfre/Born2beRoot/Born2beRoot.vdi

```
# Mandatory part

## Project overview

The student should explain simply:
- how a virtual machine works
- the choice of operating system
- basic differences between CentOS and Debian
- the purpose of VMs
- if OS == CentOS: what is SELinux and DNF?
- if OS == Debian:
    - difference between `aptitude` and `apt`
    - what is APPArmor?
- during the defense the monitoring script should display info every 10 minutes

### How a Virtual Machine works

A virtual machine uses software emulation of hardware to create an isolated environment on top of hardware where a separate system with its own OS can be run. Therefore allowing for things like running Debian inside a Mac.

In order to run a separate secondary OS on your machine, you’ll need a Virtual Machine. It's like a computer program that acts like a separate computer, so a virtual computer inside a real computer. It runs inside your physical computer but is isolated from it. It has its own "virtual" hardware (lCPU, memory, storage…) that is simulated by software (hypervisors).

### Virtualization and the Hypervisor(VMM)
Virtualization is the process of creating a virtual machine on a physical machine with the help of hypervisors which are a lightweight software layer. The hypervisor acts like an intermediate or also referred to as virtualization layer between the physical hardware of the host the machine and the virtual machines and the applications running on them. Think of the hardware as a restaurant which have appliances (stove, oven…), the chef is the hypervisor taking orders (processes) from the customers (OS and apps) of each table(VM) in the restaurant.

The **virtual machine manager** or **monitor** is a software that enables the creation and management of virtual machines. It manages the backend operation of these VMs by allocating the necessary computing, memory, storage and input/output resources. It also offers an interface that manages the status and availability of VMs that are installed over a single host or interconnected hosts. (VirtualBox is a type-2 hypervisor)



### Choice of Operating System

It's easier to install and configure than CentOS (and I haven't used CentOS before). I use Ubuntu and Pop OS for personal use which are both Debian flavours and wanted to understand them more deeply.

### The basic differences between CentOS and Debian

CentOS vs Debian are two flavors of Linux operating systems. CentOS, as said above, is a Linux distribution. It is free and open-source. It is enterprise-class – industries can use meaning for server building; it is supported by a large community and is functionally supported by its upstream source, Red Hat Enterprise Linux. Debian is a Unix like computer operating system that is made up of open source components. It is built and supported by a group of individuals who are under the Debian project.

Debian uses Linux as its Kernel. Fedora, CentOS, Oracle Linux are all different distribution from Red Hat Linux and are variant of RedHat Linux. Ubuntu, Kali, etc., are variant of Debian. CentOS vs Debian both are used as internet servers or web servers like web, email, FTP, etc.


### The purpose of virtual machines

VMs may be deployed to accommodate different levels of processing power needs, to run software that requires a different operating system, or to test applications in a safe, sandboxed environment.

Hypervisors are of two types, the **first one** being the **bare-metal** hypervisors, they don’t need to load an underlaying OS that exists on the host machine, but instead have direct contact with the hardware through their own integrated kernel. Microsoft designates **Hyper-V** as a Type 1 hypervisor. Hyper-V installs on Windows but runs directly on the physical hardware, inserting itself underneath the host OS. All guest operating systems then run through the hypervisor, but the host operating system gets special access to the hardware, giving it a performance advantage.

**The second** type are the hosted hyper-vs, they need the host machine kernel’s (OS) to establish the connection between the hardware and the VM. A Type 2 hypervisor doesn’t run directly on the underlying hardware. Instead, it runs as an application in an OS (**VirtualBox**, **VMware Fusion**). Type 2 hypervisors rarely show up in server-based environments. Instead, they’re suitable for individual PC users needing to run multiple operating systems.

**Type 1 or type 2 ?**

A Type 2 hypervisor may function **slower** than a Type 1, as all of its commands must be filtered through the host computer’s operating system, creating a lag time which makes hyper-v of type 1 more **efficient**. It also introduces potential security risks if an attacker compromises the host OS because they could then manipulate any guest OS running in the Type 2 hypervisor.



### The difference between `aptitude` and `apt`

Aptitude is a higher-level package manager while APT is lower-level package manager which can be used by other
higher-level package managers.

Aptitude has more functionality than **apt-get** and integrates functionalities of **apt-get** and its other variants including **apt-mark** and **apt-cache**.

[Read more](https://www.tecmint.com/difference-between-apt-and-aptitude/)


**dpkg** is the core infrastructure that handles package installation, removal, and updates within a Linux distribution in Debian-based distributions like Ubuntu. It handles Managing package files, Resolving dependencies, Maintaining package state and Performing updates.

**Aptitude** and **apt** itself doesn't handle these core tasks directly. Instead, it builds upon **dpkg** and other tools, providing a more user-friendly interface and advanced features. However, the security of those features ultimately depends on the underlying package management system's robustness and trustworthiness.

Imagine **dpkg** as the foundation of a house, responsible for the structural integrity. **Aptitude** and **apt** is like an architect who designs and builds the house on top of that foundation, adding features and functionality. While the architect can make the house beautiful and functional, its overall security depends on the quality of the foundation materials and construction techniques.

**apt-get** or **apt** (Advanced package tool) is a lower level package manager that comes by default and lacks UI so it’s restricted only to command line. To install a package, you need to specify the name of the package just after the **apt install** command. The package manager reads the /etc/apt/sources.list file and the contents of the /etc/apt/sources.list.d folder to retrieve the ones that you need with all the dependencies. It combines functionalities from **apt-get** and **apt-cache**. Comes by default.

**Aptitude** is a higher-level tool which has a default text-only interactive interface along with option of command-line. (includes the **ncurses** library for GUI-like) It doesn't come by default, so you need to install it with the apt command.

- **Installation** : While removing any installed package, **Aptitude** will automatically remove unused packages, while **apt** would need user to explicitly specify this by either adding additional option of **—auto-remove** or specifying **apt autoremove**.
- aptitude has the **why** and **why-not** commands to tell you which manually installed packages are preventing an action that you might want to take.
- When facing a **package conflict**, apt will not fix the issue while aptitude will suggest a resolution that can do the job.




### What is APPArmor


**AppArmor (on Debian) vs SELinux (on CentOS)**

**SELinux** stands for Security-Enhanced Linux. It uses **labels** to assign security contexts to processes and resources (objects), and checks these labels against a set of policies to determine whether an access request is allowed or denied. Imagine a label (Security context) on each object and process in your system, like a name tag that holds details about the object's role, permissions, and origin. SELinux has a set of pre-defined rules or policies that dictate how objects with specific contexts can interact with each other.

**AppArmor** stands for Application Armor and uses profiles to define and enforce rules for processes and resources. Profiles are files that specify the permissions and restrictions for each process or application, such as which files, directories, sockets, ports, and devices it can access, and how. Takes a **path-based** approach. It defines profiles for applications, specifying which files and directories they can access (read, write, execute). Imagine each profile like a map given to the app, it specifies which areas is it allowed to access, which it’s not authorized to, which resources it can use…

**SELinux** is more complex and difficult to learn, configure, manage and troubleshoot because of labels, security contexts, policies, and modes. **AppArmor**, on the other hand, is simpler and more intuitive due to profiles that are easier to create, modify, and debug.

Run ```aa-status``` to check if **AppArmor** is running.




Check APPArmor status

```bash
sudo aa-status
```

AppArmor ("Application Armor") is a Linux kernel security module that allows the system administrator to restrict programs' capabilities with per-program profiles.

Profiles can allow capabilities like network access, raw socket access, and the permission to read, write, or execute files on matching paths.

[Read more](https://en.wikipedia.org/wiki/AppArmor)


## Simple setup

- ensure the VM has no GUI.
- login to VM with a user different from root

### Check

- [x] Script running every 10min
- [x] No graphical user interface
- [x] Password requested on boot up
- [x] Login with `anemet`
- [x] Password must follow rules

### Check that the UFW service is started

```bash
sudo ufw status
```

### Check that the SSH service is started

```bash
sudo service ssh status
```

### Check that the operating system is Debian

```bash
cat /etc/os-release | grep PRETTY
```

## User


### Check that `anemet` is member of `sudo` and `user42` groups

```bash
groups anemet
```

### Check password policy rules

Password expiry: line ~164

```bash
vim /etc/login.defs
```
```
PASS_MAX_DAYS   30   # expire after 30 days
PASS_MIN_DAYS    2   # must wait 2 days before changing again
PASS_WARN_AGE    7   # 7-day heads-up e-mail + login banner
```

Password policy: line 25.

```bash
vim /etc/security/pwquality.conf
```
```
difok           = 7         # ≥7 chars different from previous
minlen          = 10        # ≥10 chars
dcredit         = -1        # at least 1 digit
ucredit         = -1        # at least 1 uppercase
lcredit         = -1        # at least 1 lowercase
maxrepeat       = 3         # no “aaaa”, “1111”…
usercheck       = 1         # forbid name inside password
enforce_for_root            # root must obey (except difok)
```

### Create a new user

```bash
sudo adduser demo
```

### Assign password

Confirm it follows the password policy

### Explain how password rules were setup

```bash
vim /etc/security/pwquality.conf
```

## Create group `evaluating` and add created user

```bash
sudo addgroup evaluating
sudo adduser demo evaluating
```

### Check that user belongs to new group

```bash
groups demo
```

## Explain advantages of password policy and advantages and disadvantages of policy implementation

In theory, the main benefit of password complexity rules is that they enforce the use of unique passwords that are harder to crack. The more requirements you enforce, the higher the number of possible combinations of letters, numbers, and characters.

Password complexity rules try to enforce this “difficult to crack” requirement, but they aren’t always successful. This is partly to do with the diminishing returns involved in increasing complexity

How much better is a 15 character password than a 30 character password if hackers know that longer password is frequently used? And is it better if the user can’t remember the password? Password complexity only scales up to a certain point. Beyond a certain point, a complex password can be difficult to crack if the number of possible combinations is extremely high, but it can also be too complex to be useful to users.

## Check that the hostname of the machine is `anemet42`

```bash
uname -n
# or
hostname
```

## Modify hostname with evaluator login and reboot to confirm change

```bash
sudo adduser demo sudo
sudo login demo
sudo vim /etc/hostname # change to demo42
sudo reboot
```

### Restore original hostname

```bash
sudo vim /etc/hostname # change to anemet42
sudo reboot
```

## How to view partitions

```bash
lsblk
```

### Compare partition output with example in subject

```bash
NAME                    MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                       8:0    0    8G  0 disk
|-sda1                    8:1    0  476M  0 part  /boot
|-sda2                    8:2    0    1K  0 part
`-sda5                    8:5    0  7.5G  0 part
  `-sda5_crypt          254:0    0  7.5G  0 crypt
    |-LVMGroup-root     254:1    0  1.9G  0 lvm   /
    |-LVMGroup-swap     254:2    0  952M  0 lvm   [SWAP]
    |-LVMGroup-home     254:3    0  952M  0 lvm   /home
    |-LVMGroup-var      254:4    0  952M  0 lvm   /var
    |-LVMGroup-srv      254:5    0  952M  0 lvm   /srv
    |-LVMGroup-tmp      254:6    0  952M  0 lvm   /tmp
    `-LVMGroup-var--log 254:7    0    1G  0 lvm   /var/log
sr0                      11:0    1 1024M  0 rom
```

## Brief explanation of how LVM works

It works by chunking the physical volumes (PVs) into physical extents (PEs). The PEs are mapped onto logical extents (LEs) which are then pooled into volume groups (VGs). These groups are linked together into logical volumes (LVs) that act as virtual disk partitions and that can be managed as such by using LVM.

[Read more](https://searchdatacenter.techtarget.com/definition/logical-volume-management-LVM)

## What is LVM about

Logical volume management (LVM) is a form of storage virtualization that offers system administrators a more flexible approach to managing disk storage space than traditional partitioning. The goal of LVM is to facilitate managing the sometimes conflicting storage needs of multiple end users.

## Check `sudo` program is properly installed

```bash
dpkg -l | grep sudo
```

## Assign new user to `sudo` group

```bash
sudo adduser demo sudo
```

## Explain value and operation of sudo using examples

Sudo stands for SuperUser DO and is used to access restricted files and operations. By default, Linux restricts access to certain parts of the system preventing sensitive files from being compromised.

The sudo command temporarily elevates privileges allowing users to complete sensitive tasks without logging in as the root user.

```bash
apt update # Error 13: Permission denied
sudo apt update
```

[Read more](https://phoenixnap.com/kb/linux-sudo-command)

## Show the implementation of the subject rules

```bash
# vim /etc/sudoers.d/sudoconfig
sudo visudo
```

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

### Why **Force an attached TTY** ?
| Scenario                                                                                                  | TTY present?                                | Works with *requiretty*? |
| --------------------------------------------------------------------------------------------------------- | ------------------------------------------- | ------------------------ |
| You’re at an interactive shell prompt and type `./myscript.sh` (or `myscript.sh` calls `sudo` inside)     | **Yes** – the script inherits your terminal | ✅                        |
| You run `ssh -t server "sudo systemctl restart apache2"` (note `-t` forces a pseudo-tty)                  | **Yes**                                     | ✅                        |
| You run a cron job, systemd timer, or non-interactive SSH command like `ssh server sudo reboot` (no `-t`) | **No**                                      | ❌ – sudo will refuse     |
| A web application, CI job, or any daemon tries `sudo something`                                           | **No**                                      | ❌                        |



- Regular scripts you launch by hand are fine. They’re children of your interactive shell, so they inherit the same TTY. Nothing to change.
- Automation without a terminal fails. If you really need a specific daemon, cron job, or CI user to run sudo, either:
    - Add `ssh -tt` / `ansible_ssh_extra_args: -tt` / similar so it gets a pseudo-tty, or
    - Give that account an exception in `sudoers`:
        ```
        Defaults:jenkins !requiretty
        ```

**Conclusion**: `requiretty` blocks only the headless, background sudo calls; anything you execute personally from a normal shell keeps working.


## Verify that the `/var/log/sudo/` folder exists and has a file

```bash
sudo ls /var/log/sudo/
```

Has file `seq`.

### Check contents of files in this folder

```bash
sudo apt update
sudo ls -lrt /var/log/sudo/anemet

# run sudo replay
sudo sudoreplay /var/log/sudo/anemet/ls...
sudo sudoreplay /var/log/sudo/anemet/apt...
```


## Check that UFW is properly installed

```bash
dpkg -l | grep ufw
```

### Check that it is working properly

```bash
sudo ufw status
```

### Explain what UFW is and the value of using it

Uncomplicated Firewall is a program for managing a netfilter firewall designed to be easy to use. It uses a command-line interface consisting of a small number of simple commands, and uses iptables for configuration.

UFW aims to provide an easy to use interface for people unfamiliar with firewall concepts, while at the same time simplifies complicated iptables commands to help an administrator who knows what he or she is doing.

[https://wiki.ubuntu.com/UncomplicatedFirewall](https://wiki.ubuntu.com/UncomplicatedFirewall)

### List active rules should include one for port 4242

```bash
sudo ufw status | grep 4242
```

### Add a new rule for port 8080

```bash
sudo ufw allow 8080
sudo ufw status
```

### Delete the new rule

List rules numbered

```bash
sudo ufw status numbered
```

Delete rule

```bash
sudo ufw delete $NUMBER
```

## Check that the SSH service is properly installed

```bash
dpkg -l | grep openssh-server
```

### Check that it is working properly

```bash
sudo service ssh status
```

### Explain what SSH is and the value of using it

Secure Shell (SSH) is a cryptographic network protocol for operating network services securely over an unsecured network. Typical applications include remote command-line, login, and remote command execution, but any network service can be secured with SSH.

SSH provides password or public-key based authentication and encrypts connections between two network endpoints. It is a secure alternative to legacy login protocols (such as telnet, rlogin) and insecure file transfer methods (such as FTP).

[https://en.wikipedia.org/wiki/Secure_Shell](https://en.wikipedia.org/wiki/Secure_Shell)

### Verify that the SSH service only uses port 4242

```bash
sudo service ssh status | grep listening
# or check configs
sudo vim /etc/ssh/sshd_config
# sudo vim /etc/ssh/ssh_config
```

### Login with SSH from host machine

```bash
ssh anemet@127.0.0.1 -p 4242 # or
ssh anemet@0.0.0.0 -p 4242 # or
ssh anemet@localhost -p 4242
```

### Make sure you cannot SSH login with root user

```bash
anemet@anemet42:~$ login root
login: Cannot possibly work without effective root
```

## Explanation of the monitoring script by showing the code

### architecture

```bash
architecture=$(uname -a)
```

uname (short for unix name) is a computer program in Unix and Unix-like computer operating systems that prints the name, version and other details about the current machine and the operating system running on it.

### physical_cpu

[https://www.cyberciti.biz/faq/check-how-many-cpus-are-there-in-linux-system/](https://www.cyberciti.biz/faq/check-how-many-cpus-are-there-in-linux-system/)

```bash
physical_cpu=$(grep "physical id" /proc/cpuinfo | sort | uniq | wc -l)
# or
lscpu | grep "CPU(s)"
```

Use `/proc/cpuinfo` file that lists CPUs.

### virtual_cpu

[https://webhostinggeeks.com/howto/how-to-display-the-number-of-processors-vcpu-on-linux-vps/](https://webhostinggeeks.com/howto/how-to-display-the-number-of-processors-vcpu-on-linux-vps/)

If your processors are multi-core, you need to know how many virtual processors you have. You can count those by looking for lines that start with "processor".

[https://www.networkworld.com/article/2715970/counting-processors-on-your-linux-box.html](https://www.networkworld.com/article/2715970/counting-processors-on-your-linux-box.html)

```bash
virtual_cpu=$(grep -c ^processor /proc/cpuinfo)
```

`-c` flag is a count on the `grep`

### memory_usage

[`awk` built-in variables](https://www.thegeekstuff.com/2010/01/8-powerful-awk-built-in-variables-fs-ofs-rs-ors-nr-nf-filename-fnr/)

[https://linuxcommando.blogspot.com/2008/04/using-awk-to-extract-lines-in-text-file.html](https://linuxcommando.blogspot.com/2008/04/using-awk-to-extract-lines-in-text-file.html)

```bash
memory_usage=$(free -m | awk 'NR==2{printf "%s/%sMB (%.2f%%)\n", $3,$2,$3*100/$2 }')
```

### total_disk

```bash
total_disk=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{ft += $2} END {print ft}')
```

`df` disk utility, `-Bg` displays in Gigabytes.

`ft` is a variable name, `END` stops the command from reaching the print until it has gone through all the lines.

Add-up total.

`-v` flag on `grep` returns non-matching lines.

### used_disk

```bash
used_disk=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} END {print ut}')
```

`-Bm` displays in Megabytes.

Add-up used.

### percent_used_disk

```bash
percent_used_disk=$(df -Bm | grep '^/dev/' | grep -v '/boot$' | awk '{ut += $3} {ft+= $2} END {printf("%d"), ut/ft*100}')
```

Need to do the same as before but both in the same measuring unit to get a meaningful percentage.

### cpu_load

```bash
cpu_load=$(top -bn1 | grep load | awk '{printf "%.2f%%\n", $(NF-2)}')
```

[`top` utility](https://man7.org/linux/man-pages/man1/top.1.html)

`-b` flag for batch mode, allows to pipe output to file or another command.
`-n1` flag for 1 interation.
`NF` number of fields in the record (row), `$(NF-2)` selects the thrid counting from the last.

### last_boot

```bash
last_boot=$(who -b | awk '$1 == "system" {print $3 " " $4}')
```

`who -b` shows time of last system boot.

### lvm_partitions

```bash
lvm_partitions=$(lsblk | grep -c "lvm")
```

Count `lvm` type partitions from `lsblk` command output.

### lvm_is_used

```bash
lvm_is_used=$(if [ $lvm_partitions -eq 0 ]; then echo no; else echo yes; fi)
```

Conditional to check if previous variable is zero or not.

### tcp_connections

```bash
# [$ sudo apt-get install net-tools]
tcp_connections=$(cat /proc/net/sockstat{,6} | awk '$1 == "TCP:" {print $3}')
```

[Read more](https://unix.stackexchange.com/questions/67150/getting-current-tcp-connection-count-on-a-system)

`/proc/net/sockstat{,6}` fies include connections established count.

Find line where first is `TCP:` and print third value which is the `inuse` (in use) amount.

### users_logged_in

```bash
users_logged_in=$(w -h | wc -l)
```

`w` - Show who is logged on and what they are doing.
`-h` flag is without header.
Each line has info about a logged in user.
Count of lines is how many users logged in.

### ipv4_address

```bash
ipv4_address=$(hostname -I)
```

`-I` flag to display IP address.

### mac_address

```bash
mac_address=$(ip link show | awk '$1 == "link/ether" {print $2}')
```

`ip` util with `link` object, then select line where `link/ether` is and print second column: MAC address.

### sudo_commands_count

```bash
sudo_commands_count=$(journalctl _COMM=sudo | grep -c COMMAND)
```

[https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs](https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs)

If a file path refers to an executable script, a "_COMM=" match for the script name is added to the query.

## What is `cron`

The cron command-line utility, also known as cron job is a job scheduler on Unix-like operating systems. Users who set up and maintain software environments use cron to schedule jobs (commands or shell scripts) to run periodically at fixed times, dates, or intervals. It typically automates system maintenance or administration—though its general-purpose nature makes it useful for things like downloading files from the Internet and downloading email at regular intervals.

[https://en.wikipedia.org/wiki/Cron](https://en.wikipedia.org/wiki/Cron)

### How to set up the script to run every 10mins

```bash
sudo crontab -e
```

Add following line

```
*/10 * * * * /usr/local/bin/monitoring.sh
```

### Verify correct functioning of the script

Check print out in console.

### Change run of script to every minute

```bash
sudo crontab -e
```

Add following line

```
*/1 * * * * /home/monitoring.sh
```

### Make the script stop running after reboot without modifying it

Remove the scheduling line on the crontab

```bash
sudo crontab -e
```

Remove following line/s

```
@reboot /home/monitoring.sh
*/1 * * * * /home/monitoring.sh
```

- [x] Restart server
- [x] Check script still exists in the same place
- [x] Check that its rights have remained the same
- [x] Check that it has not been modified
