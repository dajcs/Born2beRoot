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

Hypervisors are of two types, the **first one** being the **bare-metal** hypervisors, they don’t need to load an underlying OS that exists on the host machine, but instead have direct contact with the hardware through their own integrated kernel. Microsoft designates **Hyper-V** as a Type 1 hypervisor. Hyper-V installs on Windows but runs directly on the physical hardware, inserting itself underneath the host OS. All guest operating systems then run through the hypervisor, but the host operating system gets special access to the hardware, giving it a performance advantage.

**The second** type are the **hosted hyper-vs**, they need the host machine kernel’s (OS) to establish the connection between the hardware and the VM. A Type 2 hypervisor doesn’t run directly on the underlying hardware. Instead, it runs as an application in an OS (**VirtualBox**, **VMware Fusion**). Type 2 hypervisors rarely show up in server-based environments. Instead, they’re suitable for individual PC users needing to run multiple operating systems.

**Type 1 or type 2 ?**

A **Type 2 hypervisor** may function **slower** than a Type 1, as all of its commands must be filtered through the host computer’s operating system, creating a lag time which makes hyper-v of **type 1** more **efficient**. It also introduces potential security risks if an attacker compromises the host OS because they could then manipulate any guest OS running in the Type 2 hypervisor.



### The difference between `aptitude` and `apt`

**Aptitude** is a **higher-level package manager** while **apt** is **lower-level** package manager which can be used by other higher-level package managers.

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

Run `aa-status` to check if **AppArmor** is running.




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
# Status: active
#
# To                         Action      From
# --                         ------      ----
# 4242/tcp                   ALLOW       Anywhere                   # SSH service
# 80                         ALLOW       Anywhere
# 4242/tcp (v6)              ALLOW       Anywhere (v6)              # SSH service
# 80 (v6)                    ALLOW       Anywhere (v6)
```

### Check that the SSH service is started

```bash
systemctl status ssh
# ● ssh.service - OpenBSD Secure Shell server
#      Loaded: loaded (/lib/systemd/system/ssh.service; enabled; preset: enabled)
#      Active: active (running) since Thu 2025-06-26 09:00:56 CEST; 1h 12min ago
#        Docs: man:sshd(8)
#              man:sshd_config(5)
#     Process: 685 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
#    Main PID: 693 (sshd)
#       Tasks: 1 (limit: 2296)
#      Memory: 11.1M
#         CPU: 119ms
#      CGroup: /system.slice/ssh.service
#              └─693 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
```

### Check that the operating system is Debian

```bash
cat /etc/os-release | grep PRETTY
# PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
```

## User


### Check that `anemet` is member of `sudo` and `user42` groups

```bash
groups anemet
# anemet : anemet cdrom floppy sudo audio dip video plugdev users netdev user42
```

### Check password policy rules

Password expiry: line ~164

```bash
cat /etc/login.defs | grep "^PASS_"
# PASS_MAX_DAYS	30
# PASS_MIN_DAYS	2
# PASS_WARN_AGE	7
```

```bash
PASS_MAX_DAYS   30   # expire after 30 days
PASS_MIN_DAYS    2   # must wait 2 days before changing again
PASS_WARN_AGE    7   # 7-day heads-up e-mail + login banner
```

Password policy: line 25.

```bash
cat /etc/security/pwquality.conf | egrep "difok|minlen|dcredit|ucredit|lcredit|maxrepeat|usercheck =|enforce_for_root"
# difok = 7
# minlen = 10
# dcredit = -1
# ucredit = -1
# lcredit = -1
# maxrepeat = 3
# usercheck = 1
# enforce_for_root
```

```bash
difok           = 7         # ≥7 chars different from previous
minlen          = 10        # ≥10 chars
dcredit         = -1        # at least 1 digit
ucredit         = -1        # at least 1 uppercase
lcredit         = -1        # at least 1 lowercase
maxrepeat       = 3         # no “aaaa”, “1111”…
usercheck       = 1         # forbid name inside password
enforce_for_root            # root must obey (except difok)
```

### Create a new user & confirm password policy

```bash
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

### Explain how password rules were setup

```bash
vim /etc/security/pwquality.conf
```

## Create group `evaluating` and add created user

```bash
sudo addgroup evaluating
# Adding group `evaluating' (GID 1003) ...
# Done.

sudo adduser demo evaluating
# Adding user `demo' to group `evaluating' ...
# Done.
```

### Check that user belongs to new group

```bash
groups demo
# demo : demo users evaluating
```

## Explain advantages of password policy and advantages and disadvantages of policy implementation

In theory, the main benefit of password complexity rules is that they enforce the use of unique passwords that are harder to crack. The more requirements you enforce, the higher the number of possible combinations of letters, numbers, and characters.

Password complexity rules try to enforce this “difficult to crack” requirement, but they aren’t always successful. This is partly to do with the diminishing returns involved in increasing complexity

How much better is a 15 character password than a 30 character password if hackers know that longer password is frequently used? And is it better if the user can’t remember the password? Password complexity only scales up to a certain point. Beyond a certain point, a complex password can be difficult to crack if the number of possible combinations is extremely high, but it can also be too complex to be useful to users.

## Check that the hostname of the machine is `anemet42`

```bash
uname -n
# anemet42

hostname
# anemet42
```

## Modify hostname with evaluator login (`demo`) and reboot to confirm change

```bash
sudo adduser demo sudo
# Adding user `demo' to group `sudo' ...
# Done.

su - demo
# Password:
# demo@anemet42:~$

sudo vim /etc/hostname
# change anemet42 -> demo42
# save

sudo reboot

# Broadcast message from root@anemet42 on pts/2 (Thu 2025-06-26 10:48:08 CEST):

# The system will reboot now!

```

### Restore original hostname

```bash
# after reboot
# demo42 login:

sudo vim /etc/hostname # change to anemet42
sudo reboot
```

## How to view partitions

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
```

### Compare partition output with example in subject

```bash
NAME                    MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
sda                       8:0    0 30.8G  0 disk
├─sda1                    8:1    0  500M  0 part  /boot
├─sda2                    8:2    0    1K  0 part
└─sda5                    8:5    0 30.3G  0 part
  └─sda5_crypt          254:0    0 30.3G  0 crypt
    ├─LVMGroup-root     254:1    0   10G  0 lvm   /
    ├─LVMGroup-swap     254:2    0  2.3G  0 lvm   [SWAP]
    ├─LVMGroup-home     254:3    0    5G  0 lvm   /home
    ├─LVMGroup-var      254:4    0    3G  0 lvm   /var
    ├─LVMGroup-srv      254:5    0    3G  0 lvm   /srv
    ├─LVMGroup-tmp      254:6    0    3G  0 lvm   /tmp
    └─LVMGroup-var--log 254:7    0    4G  0 lvm   /var/log
sr0                      11:0    1 1024M  0 rom
```

## Brief explanation of how LVM works

It works by chunking the physical volumes (PVs) into physical extents (PEs). The PEs are mapped onto logical extents (LEs) which are then pooled into volume groups (VGs). These groups are linked together into logical volumes (LVs) that act as virtual disk partitions and that can be managed as such by using LVM.

[Read more](https://searchdatacenter.techtarget.com/definition/logical-volume-management-LVM)

## What is LVM about

Logical volume management (LVM) is a form of storage virtualization that offers system administrators a more flexible approach to managing disk storage space than traditional partitioning. The goal of LVM is to facilitate managing the sometimes conflicting storage needs of multiple end users.

## Check `sudo` program is properly installed

```bash
dpkg -l sudo
# Desired=Unknown/Install/Remove/Purge/Hold
# | Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
# |/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
# ||/ Name           Version            Architecture Description
# +++-==============-==================-============-======================================================# =
# ii  sudo           1.9.13p3-1+deb12u1 amd64        Provide limited super user privileges to specific # users
# ~
```

## Assign new user to `sudo` group

```bash
sudo adduser demo sudo
# adduser: The user `demo' is already a member of `sudo'.
```

## Explain value and operation of sudo using examples

Sudo stands for SuperUser DO and is used to access restricted files and operations. By default, Linux restricts access to certain parts of the system preventing sensitive files from being compromised.

The sudo command temporarily elevates privileges allowing users to complete sensitive tasks without logging in as the root user.

```bash
apt update
# Reading package lists... Done
# E: Could not open lock file /var/lib/apt/lists/lock - open (13: Permission denied)
# E: Unable to lock directory /var/lib/apt/lists/
# W: Problem unlinking the file /var/cache/apt/pkgcache.bin - RemoveCaches (13: Permission denied)
# W: Problem unlinking the file /var/cache/apt/srcpkgcache.bin - RemoveCaches (13: Permission denied)

sudo apt update
# Hit:1 http://deb.debian.org/debian bookworm InRelease
# Get:2 http://deb.debian.org/debian bookworm-updates InRelease [55.4 kB]
# Get:3 http://security.debian.org/debian-security bookworm-security InRelease [48.0 kB]
# Get:4 http://security.debian.org/debian-security bookworm-security/main Sources [140 kB]
# Get:5 http://security.debian.org/debian-security bookworm-security/main amd64 Packages [269 kB]
# Get:6 http://security.debian.org/debian-security bookworm-security/main Translation-en [161 kB]
# Fetched 673 kB in 0s (2,739 kB/s)
# Reading package lists... Done
# Building dependency tree... Done
# Reading state information... Done
# 1 package can be upgraded. Run 'apt list --upgradable' to see it.
```

[https://phoenixnap.com/kb/linux-sudo-command](https://phoenixnap.com/kb/linux-sudo-command)

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
sudo ls -l /var/log/sudo
# total 24
# drwx------ 283 root root 20480 Jun 26 11:10 anemet
# drwx------   4 root root  4096 Jun 26 10:48 demo

sudo ls -l /var/log/sudo/demo
# total 8
# drwx------ 2 root root 4096 Jun 26 10:47 20250626-104706-vim
# drwx------ 2 root root 4096 Jun 26 10:48 20250626-104808-reboot

sudo ls -l /var/log/sudo/demo/20250626-104706-vim
# total 32
# -rw------- 1 root root   77 Jun 26 10:47 log
# -rw------- 1 root root 2603 Jun 26 10:47 log.json
# -rw------- 1 root root   25 Jun 26 10:47 stderr
# -rw------- 1 root root   25 Jun 26 10:47 stdin
# -rw------- 1 root root   25 Jun 26 10:47 stdout
# -r-------- 1 root root  365 Jun 26 10:47 timing
# -rw------- 1 root root  129 Jun 26 10:47 ttyin
# -rw------- 1 root root  611 Jun 26 10:47 ttyout
```

### Check contents of files in this folder

```bash
sudo apt update

sudo ls -l /var/log/sudo/anemet | tail
# drwx------ 2 root root 4096 Jun 26 11:02 20250626-110238-adduser
# drwx------ 2 root root 4096 Jun 26 11:02 20250626-110240-adduser
# drwx------ 2 root root 4096 Jun 26 11:05 20250626-110552-apt
# drwx------ 2 root root 4096 Jun 26 11:06 20250626-110607-apt
# drwx------ 2 root root 4096 Jun 26 11:10 20250626-111018-ls
# drwx------ 2 root root 4096 Jun 26 11:10 20250626-111030-ls
# drwx------ 2 root root 4096 Jun 26 11:12 20250626-111216-ls
# drwx------ 2 root root 4096 Jun 26 11:13 20250626-111359-apt
# drwx------ 2 root root 4096 Jun 26 11:14 20250626-111428-ls

# play with sudo replay
sudo sudoreplay /var/log/sudo/anemet/20250626-111359-apt
# Replaying sudo session: /usr/bin/apt update
# Hit:1 http://deb.debian.org/debian bookworm InRelease
# Hit:2 http://deb.debian.org/debian bookworm-updates InRelease
# Hit:3 http://security.debian.org/debian-security bookworm-security InRelease
# Reading package lists... Done
# Building dependency tree... Done
# Reading state information... Done
# 1 package can be upgraded. Run 'apt list --upgradable' to see it.
```

### delete user `demo` and group `evaluating`

```bash
sudo deluser --remove-home demo
# [sudo] password for anemet:
# Looking for files to backup/remove ...
# Removing files ...
# Removing crontab ...
# Removing user `demo' ...
# Done.
```

```bash
sudo groupdel evaluating
```



## Check that UFW is properly installed

```bash
dpkg -l ufw
# Desired=Unknown/Install/Remove/Purge/Hold
# | Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
# |/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
# ||/ Name           Version      Architecture Description
# +++-==============-============-============-=========================================
# ii  ufw            0.36.2-1     all          program for managing a Netfilter firewall
#
```

### Check that it is working properly

```bash
sudo ufw status
# Status: active
#
# To                         Action      From
# --                         ------      ----
# 4242/tcp                   ALLOW       Anywhere                   # SSH service
# 80                         ALLOW       Anywhere
# 4242/tcp (v6)              ALLOW       Anywhere (v6)              # SSH service
# 80 (v6)                    ALLOW       Anywhere (v6)
#
```

### Explain what UFW is and the value of using it

Uncomplicated Firewall is a program for managing a netfilter firewall designed to be easy to use. It uses a command-line interface consisting of a small number of simple commands, and uses iptables for configuration.

UFW aims to provide an easy to use interface for people unfamiliar with firewall concepts, while at the same time simplifies complicated iptables commands to help an administrator who knows what he or she is doing.

[https://wiki.ubuntu.com/UncomplicatedFirewall](https://wiki.ubuntu.com/UncomplicatedFirewall)

### List active rules should include one for port 4242

```bash
sudo ufw status | grep 4242
# 4242/tcp                   ALLOW       Anywhere                   # SSH service
# 242/tcp (v6)              ALLOW       Anywhere (v6)              # SSH service
```

### Add a new rule for port 8080

```bash
sudo ufw allow 8080
# Rule added
# Rule added (v6)

sudo ufw status verbose
# Status: active
# Logging: on (low)
# Default: deny (incoming), allow (outgoing), disabled (routed)
# New profiles: skip
#
# To                         Action      From
# --                         ------      ----
# 4242/tcp                   ALLOW IN    Anywhere                   # SSH service
# 80                         ALLOW IN    Anywhere
# 8080                       ALLOW IN    Anywhere
# 4242/tcp (v6)              ALLOW IN    Anywhere (v6)              # SSH service
# 80 (v6)                    ALLOW IN    Anywhere (v6)
# 8080 (v6)                  ALLOW IN    Anywhere (v6)
```

### Delete the new rule

List rules numbered

```bash
sudo ufw status numbered
# Status: active
#
#      To                         Action      From
#      --                         ------      ----
# [ 1] 4242/tcp                   ALLOW IN    Anywhere                   # SSH service
# [ 2] 80                         ALLOW IN    Anywhere
# [ 3] 8080                       ALLOW IN    Anywhere
# [ 4] 4242/tcp (v6)              ALLOW IN    Anywhere (v6)              # SSH service
# [ 5] 80 (v6)                    ALLOW IN    Anywhere (v6)
# [ 6] 8080 (v6)                  ALLOW IN    Anywhere (v6)
```

Delete rule [6]

```bash
sudo ufw delete 6
# Deleting:
#  allow 8080
# Proceed with operation (y|n)? y
# Rule deleted (v6)
```

```bash
sudo ufw status numbered
# Status: active
#
#      To                         Action      From
#      --                         ------      ----
# [ 1] 4242/tcp                   ALLOW IN    Anywhere                   # SSH service
# [ 2] 80                         ALLOW IN    Anywhere
# [ 3] 8080                       ALLOW IN    Anywhere
# [ 4] 4242/tcp (v6)              ALLOW IN    Anywhere (v6)              # SSH service
# [ 5] 80 (v6)                    ALLOW IN    Anywhere (v6)
```

```bash
sudo ufw delete allow 8080
# Rule deleted
# Could not delete non-existent rule (v6)

sudo ufw status
# Status: active
#
# To                         Action      From
# --                         ------      ----
# 4242/tcp                   ALLOW       Anywhere                   # SSH service
# 80                         ALLOW       Anywhere
# 4242/tcp (v6)              ALLOW       Anywhere (v6)              # SSH service
# 80 (v6)                    ALLOW       Anywhere (v6)
```

## Check that the SSH service is properly installed

```bash
dpkg -l openssh-server
# Desired=Unknown/Install/Remove/Purge/Hold
# | Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
# |/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
# ||/ Name           Version           Architecture Description
# +++-==============-=================-============-==========================================>
# ii  openssh-server 1:9.2p1-2+deb12u6 amd64        secure shell (SSH) server, for secure acce>
```

### Check that it is working properly

```bash
systemctl status  ssh
# ● ssh.service - OpenBSD Secure Shell server
#      Loaded: loaded (/lib/systemd/system/ssh.service; enabled; preset: enabled)
#      Active: active (running) since Thu 2025-06-26 16:18:13 CEST; 17min ago
#        Docs: man:sshd(8)
#              man:sshd_config(5)
#     Process: 701 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
#    Main PID: 715 (sshd)
#       Tasks: 1 (limit: 2296)
#      Memory: 8.3M
#         CPU: 55ms
#      CGroup: /system.slice/ssh.service
#              └─715 "sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups"
```

### Explain what SSH is and the value of using it

Secure Shell (SSH) is a cryptographic network protocol for operating network services securely over an unsecured network. Typical applications include remote command-line, login, and remote command execution, but any network service can be secured with SSH.

SSH provides password or public-key based authentication and encrypts connections between two network endpoints. It is a secure alternative to legacy login protocols (such as telnet, rlogin) and insecure file transfer methods (such as FTP).

[https://en.wikipedia.org/wiki/Secure_Shell](https://en.wikipedia.org/wiki/Secure_Shell)

### Verify that the SSH service only uses port 4242

```bash
sudo service ssh status | grep listening
# Jun 26 16:18:13 anemet42 sshd[715]: Server listening on 0.0.0.0 port 4242.
# Jun 26 16:18:13 anemet42 sshd[715]: Server listening on :: port 4242.

# or check sshd_config
sudo vim /etc/ssh/sshd_config
```

### Login with SSH from host machine

```bash
ssh -p 4242 anemet@127.0.0.1   # or
ssh -p 4242 anemet@0.0.0.0     # or
ssh -p 4242 anemet@localhost
# anemet@localhost's password:
#
# Linux anemet42 6.1.0-37-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.140-1 (2025-05-22) x86_64
#
# # Nr CPU sockets : 1
# # Phys CPU cores : 2
# # Virt CPU cores : 2
# # RAM Usage      : 470/1967 MB (23.9%)
# # Disk Usage     : 2323/30887 GB (7.5%)
# # CPU Load       : 0.81%
# # Last Boot      : 2025-06-26 16:17:59
# # LVM Active     : yes
# # TCP Conns      : 3 ESTABLISHED
# # Users Logged   : 1
# # IP / MAC       : 10.0.2.15  (08:00:27:c5:54:9a)
# # sudo Commands  : 469
# # TimeStamp      : Thu Jun 26 16:41:11 CEST 2025
#
# The programs included with the Debian GNU/Linux system are free software;
# the exact distribution terms for each program are described in the
# individual files in /usr/share/doc/*/copyright.
#
# Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
# permitted by applicable law.
# Last login: Thu Jun 26 16:18:49 2025 from 10.0.2.2
```

### Make sure you cannot SSH login with root user

```bash
ssh -p 4242 root@localhost
# root@localhost's password:
# Permission denied, please try again.
# root@localhost's password:
# Permission denied, please try again.
# root@localhost's password:
# root@localhost: Permission denied (publickey,password).
```

## Explanation of the monitoring script by showing the code

### architecture

```bash
uname -snrvm
# Linux anemet42 6.1.0-37-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.1.140-1 (2025-05-22) x86_64
```
- -s, --kernel-name `Linux`
- -n, --nodename `anemet42`
- -r, --kernel-release `6.1.0-37-amd64`
- -v, --kernel-version `#1 SMP PREEMPT_DYNAMIC Debian 6.1.140-1 (2025-05-22)`
- -m, --machine `x86_64`

uname (short for unix name) is a computer program in Unix and Unix-like computer operating systems that prints the name, version and other details about the current machine and the operating system running on it.

### physical CPU sockets, physical CPU cores

```bash
man lscpu
# LSCPU(1)                               User Commands                              LSCPU(1)
#
# NAME
#        lscpu - display information about the CPU architecture
#
# SYNOPSIS
#        lscpu [options]
#
# DESCRIPTION
#        lscpu gathers CPU architecture information from sysfs, /proc/cpuinfo and any
#        applicable architecture-specific libraries (e.g. librtas on Powerpc). The command
#
#        -b, --online
#            Limit the output to online CPUs (default for -p). This option may only be
#            specified together with option -e or -p.
#
#        -p, --parse[=list]
#            Optimize the command output for easy parsing.
#            When specifying the list argument, the string of option, equal sign (=), and
#            list must not contain any blanks or other whitespace. Examples: '-p=cpu,node'
#            or '--parse=cpu,node'.
#            The default list of columns may be extended if list is specified in the format
#            +list (e.g., lscpu -p=+MHZ).
```

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


### virtual_cpu

```bash
man proc
#         ...
#        /proc/cpuinfo
#               This is a collection of CPU and system  architecture  dependent  items,  for
#               each  supported  architecture a different list.  Two common entries are pro‐
#               cessor which gives CPU number and bogomips; a system constant that is calcu‐
#               lated  during kernel initialization.  SMP machines have information for each
#               CPU.  The lscpu(1) command gathers its information from this file.
#         ...
```

Use `/proc/cpuinfo` file that lists CPUs.

[https://webhostinggeeks.com/howto/how-to-display-the-number-of-processors-vcpu-on-linux-vps/](https://webhostinggeeks.com/howto/how-to-display-the-number-of-processors-vcpu-on-linux-vps/)

If your processors are multi-core, you need to know how many virtual processors you have. You can count those by looking for lines that start with "processor".

[https://www.networkworld.com/article/2715970/counting-processors-on-your-linux-box.html](https://www.networkworld.com/article/2715970/counting-processors-on-your-linux-box.html)

```bash
# getting nr virtual CPU:
grep  ^processor /proc/cpuinfo
# processor	: 0
# processor	: 1

# script command
virt_cpu=$(grep -c ^processor /proc/cpuinfo)
```

### memory_usage

[`awk` built-in variables](https://www.thegeekstuff.com/2010/01/8-powerful-awk-built-in-variables-fs-ofs-rs-ors-nr-nf-filename-fnr/)

[https://linuxcommando.blogspot.com/2008/04/using-awk-to-extract-lines-in-text-file.html](https://linuxcommando.blogspot.com/2008/04/using-awk-to-extract-lines-in-text-file.html)

```bash
man free

#        free - Display amount of free and used memory in the system
#
#        -m, --mebi
#               Display the amount of memory in mebibytes.
```

```bash
free -m
#                total        used        free      shared  buff/cache   available
# Mem:            1967         255        1506           0         348        1711
# Swap:           2191           0        2191

# script command
read total_mem used_mem <<<$(free -m | awk '/Mem:/ {print $2, $3}')
mem_pct=$(awk "BEGIN {printf \"%.1f\", $used_mem/$total_mem*100}")
```

### disk storage

```bash
man df
# NAME
#        df - report file system space usage

#        -B, --block-size=SIZE
#               scale  sizes by SIZE before printing them; e.g., '-BM' prints sizes in units of 1,048,576
#               bytes; see SIZE format below
```


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
```

```bash
# script command
read total_disk used_disk <<<$(df -BM --total | awk '/total/ {print substr($2,1,length($2)-1), substr($3,1,length($3)-1)}')
disk_pct=$(awk "BEGIN {printf \"%.1f\", $used_disk/$total_disk*100}")
```


### cpu_load

```bash
# install `sysstat`
sudo apt install sysstat
```

```bash
man mpstat
#       mpstat - Report processors related statistics.
```

```bash
mpstat
# Linux 6.1.0-37-amd64 (anemet42) 	06/23/2025 	_x86_64_	(2 CPU)
#
# 05:14:10 PM  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
# 05:14:10 PM  all    0.01    0.00    0.06    1.83    0.00    0.09    0.00    0.00    0.00   98.00

# script command
cpu_pct=$(mpstat | grep "all" | awk '{print 100 - $NF}')
```

### last_boot


```bash
man uptime

#        uptime - Tell how long the system has been running.
#
#        -s, --since
#              system up since, in yyyy-mm-dd HH:MM:SS format
```

```bash
uptime -s
# 2025-06-25 18:56:06
```

```bash
# script command
last_boot=$(uptime -s)
```

### LVM active

```bash
man lsblk
# NAME
#        lsblk - list block devices
#
# SYNOPSIS
#        lsblk [options] [device...]
#
# DESCRIPTION
#        lsblk lists information about all available or the specified block devices. The lsblk command reads the sysfs filesystem
#        and udev db to gather information. If the udev db is not available or lsblk is compiled without udev support, then it
#        tries to read LABELs, UUIDs and filesystem types from the block device. In this case root permissions are necessary.
```

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
```

```bash
# script command
lvm_active=$(lsblk | grep -q " lvm " && echo "yes" || echo "no")
```

### tcp_connections

```bash
man ss
# NAME
#        ss - another utility to investigate sockets
#
# SYNOPSIS
#        ss [options] [ FILTER ]
#
# DESCRIPTION
#        ss  is  used  to  dump socket statistics. It allows showing information similar to netstat.  It can display more TCP and
#        state information than other tools.
#
# OPTIONS
#        When no option is used ss displays a list of open non-listening sockets (e.g. TCP/UNIX/UDP) that have  established  con‐
#        nection.
#
#        -a, --all
#               Display both listening and non-listening (for TCP this means established connections) sockets.
#        -t, --tcp
#               Display TCP sockets.
#
# USAGE EXAMPLES
#        ss -t -a
#               Display all TCP sockets.
```

```bash
ss -ta
# State         Recv-Q        Send-Q                Local Address:Port                 Peer Address:Port         Process
# LISTEN        0             128                         0.0.0.0:4242                      0.0.0.0:*
# ESTAB         0             0                         10.0.2.15:4242                     10.0.2.2:46420
# LISTEN        0             128                            [::]:4242                         [::]:*
```

```bash
# script command
tcp_conn=$(ss -ta | grep ESTAB | wc -l)
```

### users_logged_in

```bash
man who
# NAME
#        who - show who is logged on
#
# SYNOPSIS
#        who [OPTION]... [ FILE | ARG1 ARG2 ]
#
# DESCRIPTION
#        Print information about users who are currently logged in.
```

```bash
who
# anemet   tty1         2025-06-23 08:14
# anemet   pts/0        2025-06-23 08:16 (10.0.2.2)
```

```bash
# script command
logged_users=$(who | wc -l)
```

### ipv4_address

```bash
man hostname
# NAME
#        hostname - show or set the system's host name
#
#        -I, --all-ip-addresses
#               Display  all network addresses of the host. This option enumerates all configured addresses on all network inter‐
#               faces. The loopback interface and IPv6 link-local addresses are omitted. Contrary to option -i, this option  does
#               not depend on name resolution. Do not make any assumptions about the order of the output.
```

```bash
hostname -I
# 10.0.2.15
```

```bash
# script command
ip_addr=$(hostname -I | awk '{print $1}')
```

### mac_address

```bash
man ip-link
#    ip link show - display device attributes
#        dev NAME (default)
#               NAME specifies the network device to show.
#
#        group GROUP
#               GROUP specifies what group of devices to show.
#
#        up     only display running interfaces.
#
#        master DEVICE
#               DEVICE specifies the master device which enslaves devices to show.
#
#        vrf NAME
#               NAME specifies the VRF which enslaves devices to show.
#
#        type TYPE
#               TYPE specifies the type of devices to show.
#
#               Note that the type name is not checked against the list of supported types - instead it is sent as-is to the ker‐
#               nel. Later it is used to filter the returned interface list by comparing it with the relevant attribute in case
#               the kernel didn't filter already. Therefore any string is accepted, but may lead to empty output.
#
#        nomaster
#               only show devices with no master
```

```bash
ip link show
# 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
#     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
# 2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
#     link/ether 08:00:27:c5:54:9a brd ff:ff:ff:ff:ff:ff
```

```bash
#script command
mac_addr=$(ip link show | awk '/link\/ether/ {print $2; exit}')
```

### sudo_commands_count

```bash
man journalctl
# NAME
#        journalctl - Query the systemd journal

# SYNOPSIS
#        journalctl [OPTIONS...] [MATCHES...]

# DESCRIPTION
#        journalctl may be used to query the contents of the systemd(1) journal as written by systemd-journald.service(8).
#
#        If called without parameters, it will show the full contents of the journal, starting with the oldest entry collected.
#
#        If one or more match arguments are passed, the output is filtered accordingly. A match is in the format "FIELD=VALUE",
#        e.g.  "_SYSTEMD_UNIT=httpd.service", referring to the components of a structured journal entry. See systemd.journal-
#        fields(7) for a list of well-known fields. If multiple matches are specified matching different fields, the log entries
#        are filtered by both, i.e. the resulting output will show only entries matching all the specified matches of this kind.
#        If two matches apply to the same field, then they are automatically matched as alternatives, i.e. the resulting output
#        will show entries matching any of the specified matches for the same field. Finally, the character "+" may appear as a
#        separate word between other terms on the command line. This causes all matches before and after to be combined in a
#        disjunction (i.e. logical OR).
#
#        It is also possible to filter the entries by specifying an absolute file path as an argument. The file path may be a
#        file or a symbolic link and the file must exist at the time of the query. If a file path refers to an executable binary,
#        an "_EXE=" match for the canonicalized binary path is added to the query. If a file path refers to an executable script,
#        a "_COMM=" match for the script name is added to the query. If a file path refers to a device node, "_KERNEL_DEVICE="
#
#        -q, --quiet
#            Suppresses all informational messages (i.e. "-- Journal begins at ...", "-- Reboot --"), any warning messages
#            regarding inaccessible system journals when run as a normal user.
 ```


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
```

```bash
#script command
sudo_runs=$(journalctl -q _COMM=sudo | grep "COMMAND=" | wc -l)
```

[https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs](https://www.digitalocean.com/community/tutorials/how-to-use-journalctl-to-view-and-manipulate-systemd-logs)

If a file path refers to an executable script, a "_COMM=" match for the script name is added to the query.


## What is `cron`

The cron command-line utility, also known as cron job is a job scheduler on Unix-like operating systems. Users who set up and maintain software environments use cron to schedule jobs (commands or shell scripts) to run periodically at fixed times, dates, or intervals. It typically automates system maintenance or administration—though its general-purpose nature makes it useful for things like downloading files from the Internet and downloading email at regular intervals.

[https://en.wikipedia.org/wiki/Cron](https://en.wikipedia.org/wiki/Cron)

### How to set up the script to run every 10mins

```bash
sudo crontab -u root -e
```

Add following line

```cpp
*/10 * * * * /home/anemet/monitoring.sh
```

### Verify correct functioning of the script

Check print out in console.

### Change run of script to every minute

```bash
sudo crontab -u root -e
```

Add following line

```cpp
*/1 * * * * /home/anemet/monitoring.sh
```

### Make the script stop running after reboot without modifying it

Remove the scheduling line on the crontab

```bash
sudo crontab -u root -e
```

commet out following line/s

```cpp
@reboot /home/monitoring.sh
*/1 * * * * /home/monitoring.sh
```

- [x] Restart server
- [x] Check script still exists in the same place
- [x] Check that its rights have remained the same
- [x] Check that it has not been modified
