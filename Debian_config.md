
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

Since we are working with groups, the project asks us to create group `user42` and add the login user to it:

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
echo "set number" ~/.vimrc  # to display line number by default
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
> ### Note: SSH from Ubuntu host to the Debian VM
>
> **Why**: This is one more extra test, but more importantly after this setup and ssh to Debian VM you can use the copy/paste in the terminal.
>
> **Concept**: You will tell VirtualBox: "Any connection that comes to my host machine on a specific port (e.g., 4242) should be forwarded to the guest machine's IP on port (4242)."
>
> **Steps**:
>
>     - Shut down your Debian VM.
>     - In VirtualBox, select your Debian VM and go to Settings > Network.
>     - Ensure "Attached to:" is still set to NAT (Network Address Translation, the default setting)
>     - Expand the "Advanced" section and click the "Port Forwarding" button.
>     - Click the green "+" icon to add a new rule.
>     - Fill in the fields like this:
>         - Name: SSH (or any name you like)
>         - Protocol: TCP
>         - Host IP: Leave blank (or use 127.0.0.1)
>         - Host Port: 4242 (You can pick any unused port above 1024)
>         - Guest IP: 10.0.2.15 (Your guest's IP, check with command "ip addr", addr in row starting with: inet x.x.x.x)
>         - Guest Port: 4242 (The standard SSH port)
>     - Click OK on all windows to save.
>
>     Start your Debian VM.
>
> How to Connect:
>
> Now, from your Ubuntu host terminal, you will SSH to your own host machine (localhost or 127.0.0.1) on the port you specified (4242). VirtualBox will catch this and forward it to the guest.
>
```bash
# On your Ubuntu Host
# You are connecting to your own machine (localhost) on the forwarded port
ssh anemet@127.0.0.1 -p 4242
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

### Prepare the log directory

```bash
sudo mkdir -p /var/log/sudo
sudo chmod 0700 /var/log/sudo
sudo chown root:root /var/log/sudo
```

The `sudo` configuration is stored in the file `/etc/sudoers.d/sudoconfig`. This file should not be edited directly, edit *only* though command `visudo`:

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
Defaults        iolog_file=%{command}_%T

# Force an attached TTY
Defaults        requiretty

# Tight PATH in sudo context
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
```

Save & exit; `visudo` will refuse to close if you mistyped anything.

### Verify hardened sudo rules

```bash
# as the normal user
sudo -l                   # display Defaults / allowed commands

sudo -k                   # forget cached creds

# intentionally fail 3×
sudo ls -al /root   # intentionally enter wrong password 3x

# succeed once and run something
sudo ls -al /root

# confirm logs exist
sudo ls -l /var/log/sudo/anemet
# replays the I/O capture of a command, e.g.
sudo sudoreplay /var/log/sudo/anemet/ls_01:57:24
```




## 5 - Setting up a strong password policy

```bash
sudo vi /etc/login.defs
```

```
PASS_MAX_DAYS    99999 -> PASS_MAX_DAYS    30
PASS_MIN_DAYS    0     -> PASS_MIN_DAYS    2
```

`PASS_WARN_AGE` is 7 by defaults.

```bash
sudo apt-get install libpam-pwquality
sudo vi /etc/pam.d/common-password
```

Add to the end of the `password requisite pam_pwqiality.so retry=3` line:

```
minlen=10 ucredit=-1 dcredit=-1 maxrepeat=3 reject_username difok=7 enforce_for_root
```

Change previous passwords.

```bash
passwd
sudo passwd
```

## `cron`

Create script file

```bash
sudo vi /home/monitoring.sh
```

Make executable

```bash
sudo chmod +x /home/monitoring.sh
```

Edit cron jobs

```bash
sudo crontab -u root -e
```

After line23 `# m h dom mon dow command`

Put line24

```
*/10 * * * * /home/monitoring.sh
```

Check scheduled jobs

```bash
sudo crontab -u root -l
```

### Disable `dhcpclient` open port 68

> dont, needed to run package manager

```bash
sudo vi /etc/network/interfaces
```

Comment out `iface enp0s3 inet dhcp`

```bash
sudo reboot
```
