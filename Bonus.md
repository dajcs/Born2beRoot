# Linux Lighttpd MariaDB PHP (LLMP) Stack

## 1. Lighttpd

Lighttpd: is a web server designed to be fast, secure, flexible, and standards-compliant. It is optimized for environments where speed is a top priority because it consumes less CPU and RAM than other servers.

Installation of Lighttpd packages.

```bash
sudo apt update
sudo apt install lighttpd
```

Start the service and make sure it comes up after every reboot
```bash
sudo systemctl enable --now lighttpd
```
- `enable` – add a boot-time symlink so the daemon auto-starts.
- `--now` – flip the switch immediately so no need to reboot just to test.


Confirm it’s running
```bash
systemctl status lighttpd --no-pager
```
Look for `Active: active (running)`  \
Logs are in `journalctl -u lighttpd`.

### Open firewall port 80

Allow incoming connections using Port 80

```bash
sudo ufw allow 80
```

Check `ufw` status

```bash
sudo ufw status verbose
```

### Manage port forwarding on Virtualbox VM

Find the VM’s IP so you can hit it from the host
```bash
hostname -I
# 10.0.2.15

# or

ip -brief address
# lo               UNKNOWN        127.0.0.1/8 ::1/128
# enp0s3           UP             10.0.2.15/24 fe80::a00:27ff:fec5:549a/64
```
The first address on the enp0s3 / eth0 interface is usually the VM's IP.

(VirtualBox) punch a hole if you’re in NAT mode \
If your VM uses the default NAT adapter, forward port 80:

```bash
# this command should be entered on the Ubuntu host
VBoxManage modifyvm "Born2beRoot" --natpf1 "http,tcp,,8088,10.0.2.15,80"
```

Alternatively the port forwarding can be setup from the GUI - as seen at SSH host to guest setup.

Now browsing to http://localhost:8088/ on your host should show the “lighttpd Debian Placeholder” page.

### Tweaking later on

- Config lives in `/etc/lighttpd/lighttpd.conf` (+ snippets in `conf-available/`).
- Reload after config edits `sudo systemctl reload lighttpd`


## 2. MariaDB

1. Refresh your package index (again – it never hurts)
```bash
sudo apt update
```

2. Pull in MariaDB Server
```bash
sudo apt install mariadb-server
```
Debian 12 ships the 10.11-LTS branch.

3. Start it and make it boot-persistent
```bash
sudo systemctl enable --now mariadb
```

Exactly like we did with lighttpd:
- `enable` adds a boot-time symlink.
- `--now` starts the service immediately

4. Verify it’s alive
```bash
systemctl status mariadb --no-pager
```
Look for `Active: active (running)`. \
Logs live in `journalctl -u mariadb`.

5. Run the hardening script
```bash
sudo mariadb-secure-installation
```

You’ll get a handful of interactive prompts – here’s the quick playbook:

| Prompt                          | Recommended answer | Reason                                                                                             |
| ------------------------------- | ------------------ | -------------------------------------------------------------------------------------------------- |
| `Switch to unix_socket auth?`   | **Y** (default)    | Lets `root` log in *only* from the shell via sudo, no password to remember, harder to brute-force. |
| `Change the root password?`     | **N** (skip)       | Not needed if you kept unix\_socket.                                                               |
| `Remove anonymous users?`       | **Y**              | Less attack surface.                                                                               |
| `Disallow root login remotely?` | **Y**              | Root should never tunnel in over TCP.                                                              |
| `Remove test database?`         | **Y**              | It’s world-readable by default.                                                                    |
| `Reload privilege tables?`      | **Y**              | Activates the changes immediately.                                                                 |

<BR>

6. Smoke-test the connection
```bash
sudo mariadb -e "SELECT VERSION();"
```
Should print 10.11.x-MariaDB-.... If that works, the daemon is listening on its UNIX socket and accepting local connections.






## 2. WordPress

WordPress: It is a content management system focused on the creation of any type of website.

To install the latest version of WordPress we must first install wget and zip.
- wget: It is a command line tool used to download files from the web.
- zip: It is a command line utility for compressing and decompressing files in ZIP format.

```bash
sudo apt install wget zip
```
Go to directory `/var/www`

```bash
cd /var/www
```



























Download WordPress to `/var/www/html`.

```bash
sudo wget http://wordpress.org/latest.tar.gz -P /var/www/html
```

Extract downloaded content.

```bash
sudo tar -xzvf /var/www/html/latest.tar.gz
```

Remove tarball.

```bash
sudo rm /var/www/html/latest.tar.gz
```

Copy content of `/var/www/html/wordpress` to `/var/www/html`.

```bash
sudo cp -r /var/www/html/wordpress/* /var/www/html
```

Remove `/var/www/html/wordpress`

```bash
sudo rm -rf /var/www/html/wordpress
```

Create WordPress configuration file from its sample.

```bash
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
```

Configure WordPress to reference previously-created MariaDB database & user.

```bash
sudo vi /var/www/html/wp-config.php
```

Replace the below

```
line23 define( 'DB_NAME', 'database_name_here' );
line26 define( 'DB_USER', 'username_here' );
line29 define( 'DB_PASSWORD', 'password_here' );
```

with:

```
line23 define( 'DB_NAME', '<database-name>' );
line26 define( 'DB_USER', '<username-2>' );
line29 define( 'DB_PASSWORD', '<password-2>' );
```


## Step 2: Installing & Configuring MariaDB

```bash
sudo apt-get install mariadb-server
```

Start interactive script to remove insecure default settings

```bash
sudo mysql_secure_installation
```

Enter current password for root (enter for none): #Just press Enter (do not confuse database root with system root)

```
Set root password? [Y/n] n
Remove anonymous users? [Y/n] Y
Disallow root login remotely? [Y/n] Y
Remove test database and access to it? [Y/n] Y
Reload privilege tables now? [Y/n] Y
```

Log in to the MariaDB console via sudo mariadb.

```bash
sudo mariadb
```

```
CREATE DATABASE paxfamilia;
```

Create new database user and grant them full privileges on the newly-created database

```
GRANT ALL ON paxfamilia.* TO '<username-2>'@'localhost' IDENTIFIED BY '<password-2>' WITH GRANT OPTION;
```

Flush the privileges

```
FLUSH PRIVILEGES;
```

Exit the MariaDB shell via exit.

```
exit
```

Verify whether database user was successfully created by logging in to the MariaDB console

```bash
mariadb -u <username-2> -p
```

Confirm whether database user has access to the database

```
SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| paxfamilia         |
| information_schema |
+--------------------+
```

## Step 3: Installing PHP

Install php-cgi & php-mysql.

```bash
sudo apt-get install php-cgi php-mysql
```


### Step 5: Configuring Lighttpd

Enable below modules.

```bash
sudo lighty-enable-mod fastcgi
sudo lighty-enable-mod fastcgi-php
sudo service lighttpd force-reload
```
