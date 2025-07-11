# Linux Lighttpd MariaDB PHP (LLMP) Stack

## 1. Lighttpd

Lighttpd: is a web server designed to be fast, secure, flexible, and standards-compliant. It is optimized for environments where speed is a top priority because it consumes less CPU and RAM than other servers.

1. Installation of Lighttpd packages.

```bash
sudo apt update
sudo apt install lighttpd
```

2. Start the service and make sure it comes up after every reboot
```bash
sudo systemctl enable --now lighttpd
```
- `enable` – add a boot-time symlink so the daemon auto-starts.
- `--now` – flip the switch immediately so no need to reboot just to test.


3. Confirm it’s running
```bash
systemctl status lighttpd --no-pager
```
Look for `Active: active (running)`  \
Logs are in `journalctl -u lighttpd`.

### Open firewall port 80

4. Allow incoming connections using Port 80

```bash
sudo ufw allow 80
```

5. Check `ufw` status

```bash
sudo ufw status verbose
```

### Manage port forwarding on Virtualbox VM

6. Find the VM’s IP so you can hit it from the host
```bash
hostname -I
# 10.0.2.15

# or

ip -brief address
# lo               UNKNOWN        127.0.0.1/8 ::1/128
# enp0s3           UP             10.0.2.15/24 fe80::a00:27ff:fec5:549a/64
```
- The first address on the enp0s3 / eth0 interface is usually the VM's IP.

7. (VirtualBox) punch a hole if you’re in NAT mode \
If your VM uses the default NAT adapter, forward port 80:


```bash
# this command should be entered on the Ubuntu host
VBoxManage modifyvm "Born2beRoot" --natpf1 "http,tcp,,8088,10.0.2.15,80"
```
- `--natpf1` specifies that the rule applies to the first NAT network adapter (adapter 1).
- `http`: The name of the rule (purely descriptive).
- `tcp`: The protocol (can be tcp or udp).
- `,,` The empty field (between tcp and 8088): Host IP (empty means all host IPs).
- `8088`: The port on the host machine.
- `10.0.2.15`: The IP address of the guest (the VM).
- `80`: The port on the guest machine.


Alternatively the port forwarding can be setup from the GUI - as seen at SSH host to guest setup.

8. Test browsing to http://localhost:8088/ on your host should show the **lighttpd Debian Placeholder** page:
---
> ###  Placeholder page
---
> **You should replace this page with your own web pages as soon as possible.**
---
> Unless you changed its configuration, your new server is configured as follows:
---
- Configuration files can be found in /etc/lighttpd. Please read /etc/lighttpd/conf-available/README file.
- The DocumentRoot, which is the directory under which all your HTML files should exist, is set to /var/www/html.
- CGI scripts are looked for in /usr/lib/cgi-bin, which is where Debian packages will place their scripts. You can enable cgi module by using command "lighty-enable-mod cgi".
- Log files are placed in /var/log/lighttpd, and will be rotated weekly. The frequency of rotation can be easily changed by editing /etc/logrotate.d/lighttpd.
- The default directory index is index.html, meaning that requests for a directory /foo/bar/ will give the contents of the file /var/www/html/foo/bar/index.html if it exists (assuming that /var/www/html is your DocumentRoot).
- You can enable user directories by using command "lighty-enable-mod userdir"
---

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
- Look for `Active: active (running)`. \
- Logs live in `journalctl -u mariadb`.

5. Run the hardening script
```bash
sudo mariadb-secure-installation
```

You’ll get a handful of interactive prompts – here’s the quick playbook:

| Prompt                          | Recommended answer | Reason                                                                                             |
| ------------------------------- | ------------------ | -------------------------------------------------------------------------------------------------- |
| `Enter current passw for root ` | press **\<enter\>**| If you've just installed MariaDB, and haven't set the root password yet, just press enter          |
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
# +----------------------------+
# | VERSION()                  |
# +----------------------------+
# | 10.11.11-MariaDB-0+deb12u1 |
# +----------------------------+
```
Should print 10.11.x-MariaDB-.... If that works, the daemon is listening on its UNIX socket and accepting local connections.

7. Pre-create a database and user for WordPress (optional but tidy)
```bash
sudo mariadb
```
Inside the prompt:
```sql
CREATE DATABASE wordpress
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

CREATE USER 'wpuser'@'localhost'
  IDENTIFIED BY 'changeThisPassword!';

GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```
- utf8mb4 handles every emoji and multilingual character WP might store.
- Scoping the user to 'localhost' means it can’t log in from anywhere else (good).
- Granting on only the wordpress database keeps access tight.

8. Networking sanity-check (you usually leave MariaDB internal)

- WordPress will talk to MariaDB over the local socket or 127.0.0.1; you don’t need to expose port 3306 to the host.
- If you do later decide to open it, add a new NAT rule in VirtualBox similar to what we did for port 80 – but most setups keep the DB private.


## 3. PHP install → wire it to lighttpd

This finishes the “L-P-M” stack so WordPress can run.


0. Make sure you don't have Apache so it doesn’t fight lighttpd for port 80
```bash
sudo systemctl disable --now apache2
sudo apt purge -y apache2 libapache2-mod-php8.2 apache2-bin apache2-utils apache2-data
sudo apt autoremove -y          # toss the now-orphaned libs
```


1. Install FPM + the WordPress extensions
```bash
sudo apt install -y php8.2-fpm php-mysql php-gd php-xml php-curl php-mbstring php-zip php-intl
```

2. Enable and start the FPM pool
```bash
sudo systemctl enable --now php8.2-fpm
systemctl status php8.2-fpm --no-pager    # should show “active (running)”
```
- Look for `Active: active (running)` and the socket path, usually `/run/php/php8.2-fpm.sock`.

Debian ships two mutually-exclusive snippets in `/etc/lighttpd/conf-available`:
- `15-fastcgi-php.conf`	Tells lighttpd to spawn its own php-cgi workers ("bin-path" => "/usr/bin/php-cgi").
- `15-fastcgi-php-fpm.conf`	Tells lighttpd to proxy to an external PHP-FPM socket.

We chose PHP-FPM because it’s faster, has a real process manager, and is maintained by the PHP team. The _cgi model wastes RAM and restarts PHP for every request.
```bash
sudo lighty-disable-mod fastcgi-php        # turns off php-cgi
sudo lighty-enable-mod fastcgi-php-fpm     # points to PHP-FPM
sudo systemctl reload lighttpd
```

3. End-to-end test. Create a mini-website with the one-liner PHP script `<?php phpinfo(); ?>` which, when hit in a browser, dumps every detail about the PHP runtime. Put this into `/var/www/html/info.php`:

```bash
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php
```

- Test the website http://localhost:8088/info.php from a browser in the host computer.
- You should see the purple phpinfo() page showing PHP 8.2 with mysqli, curl,
gd, intl, etc.
- Delete the test file when you’re satisfied:
```bash
sudo rm /var/www/html/info.php
```

## 4. WordPress

0. To install the latest version of WordPress, make sure we have installed `curl`, `wget` and `zip`.
```bash
sudo apt install curl wget zip
```

1. Grab the current WordPress release and unpack it
```bash
cd /tmp
curl -LO https://wordpress.org/latest.tar.gz      # 6.8.1 as of June 24 2025
sudo tar -xzf latest.tar.gz -C /var/www/           # creates /var/www/wordpress
```
- `curl -LO` writes the tarball (-O) and follows redirects (-L).
- `/var/www/wordpress` keeps WP separate from any other sites you might host.

2. Hand the files to the web server user
```bash
sudo chown -R www-data:www-data /var/www/wordpress
```
- `www-data` is the user/group lighttpd and PHP-FPM run as; ownership avoids permission headaches when WP tries to upload plugins, themes, or media.

3. Create the WordPress config
```bash
cd /var/www/wordpress
sudo cp wp-config-sample.php wp-config.php
sudo vim wp-config.php
```

- edit 4 lines:
```php
define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', 'wpuser' );
define( 'DB_PASSWORD', 'changeThisPassword!' );
define( 'DB_HOST', 'localhost' );   // leave as-is
```

- cut-paste fresh secret keys at the end of `wp-config.php`:
```bash
curl -s https://api.wordpress.org/secret-key/1.1/salt/ | sudo tee -a wp-config.php
```

4. Point lighttpd at the new doc-root
- Open the main config:
```bash
sudo vim /etc/lighttpd/lighttpd.conf
```
- Find the existing server.document-root line and change it:
```bash
server.document-root = "/var/www/wordpress"
# Make sure index-file.names already contains index.php (Debian’s default does)
# index-file.names            = ( "index.php", "index.html" )
```
- save file

- to have pretty permalinks, enable mod_rewrite:
```bash
sudo lighty-enable-mod rewrite
# Enabling rewrite: ok
# Run "service lighttpd force-reload" to enable changes
```
- finally reload `lighttpd`:
```bash
sudo systemctl reload lighttpd
```

5. Kick off the browser installer
- Host machine browser URL: http://localhost:8088/
- At first login this redirects to the install page: http://localhost:8088/wp-admin/install.php
    - Site Title – anything you like (Hello World!)
    - Username / Password – new WP admin creds (anemet / psw)
    - Your Email (anemet@student.42luxembourg.lu)
    - press `Install WordPress`
- **Success!** - WordPress has been installed. Thank you, and enjoy!

6. Post-install housekeeping
- Delete the tarball to reclaim space

```bash
rm /tmp/latest.tar.gz
```

- You can manage your WP site on the WP dashboard: http://localhost:8088/wp-admin/index.php
    - Settings → Permalinks → choose a pretty format
    - Update to any newer 6.8.x maintenance release when prompted.


## 5. Extra Service

We have to set up a service of our choice that is useful (NGINX / Apache2 excluded!) and we have to justify our choice.

Here are some services to choose from:

| Service                                           | What it does                                                                                                                                                          | One-liner pitch                                                                           |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| **Fail2ban**                                      | Monitors log files (lighttpd, SSH, WordPress XML-RPC, etc.) and auto-blocks IPs that show repeated bad behavior via `iptables`.                                              | “It gives the server a self-defense reflex against brute-force attacks without me babysitting log files.”            |
| **Redis-server** (plus the `php-redis` extension) | Runs as an in-memory key/value store. When you activate a WordPress object-cache plugin it slashes DB round-trips and page-generation time—especially noticeable under load. | “It’s a performance turbo: WordPress shoves transient data into RAM instead of hitting MariaDB for every page view.” |
| **Certbot (Let’s Encrypt client)**                | Automates getting and renewing a free TLS certificate; hooks exist for lighttpd so HTTPS is set-and-forget.                                                                  | “Zero-cost, auto-renewing HTTPS means no expired-certificate outages and Google stops whining about ‘Not Secure’.”   |


## Extra Service - Fail2ban

1. Install & bootstrap
```bash
sudo apt update
sudo apt install fail2ban
sudo systemctl enable --now fail2ban
```

2. Make your own `jail.local`.
- Directly editing the original `jail.conf` is not recommended because updates may overwrite your changes.

```bash
sudo nano /etc/fail2ban/jail.local
```

- Minimal tweaks worth doing:

```ini
[DEFAULT]
bantime   = 15m
findtime  = 10m
maxretry  = 5
backend   = systemd

[sshd]
enabled   = true

[wordpress]
enabled   = true
backend   = pyinotify   ; watch the file directly (falls back to polling if inotify not available)
logpath   = /var/log/lighttpd/access.log
port      = http,https
maxretry  = 10
findtime  = 10m
bantime   = 15m
```

3. Turn on lighttpd’s access-log
```bash
sudo lighty-enable-mod accesslog          # activates 10-accesslog.conf
sudo systemctl reload lighttpd
```
- The default snippet writes to /var/log/lighttpd/access.log and uses the common-log format (one line per request).

- Check:
```bash
# access.log should now exist, size > 0 after a page hit
sudo ls -l /var/log/lighttpd/access.log
```
- Browse your WordPress site once, then:
```bash
# you should see the GET / HTTP/1.1 line(s)
sudo tail /var/log/lighttpd/access.log
```

4. Add the filter for WordPress, create and edit file `wordpress.conf`
```bash
sudo nano /etc/fail2ban/filter.d/wordpress.conf
```
- add the lines below:
```ini
[Definition]
failregex = ^<HOST> .* "(GET|POST) /wp-login\.php HTTP/.*"$
ignoreregex =
```

5. Suppress the `allowipv6` warning, by creating a `fail2ban.local` file
- modifying the original `fail2ban.conf` is not recommended because updates might overwrite the changes)
```bash
sudo nano /etc/fail2ban/fail2ban.local
```
- add the lines:
```ini
[Definition]
allowipv6 = auto
```

6. Check config & restart & check status
```bash
# Check config, should end with "OK”
sudo fail2ban-server -t
# OK: configuration test is successful

sudo systemctl restart fail2ban

# check sshd and wordpress jails
sudo fail2ban-client status
# Status
# |- Number of jail:	2
# `- Jail list:	sshd, wordpress
```

7. Verify it fires
- From a different terminal (or browser privacy window) hit [/wp-login.php](http://localhost:8088/wp-login.php) ~12 times with a bad password.

- Check the jail again

```bash
sudo fail2ban-client status wordpress
```
- expected:
```yaml
|- Filter
|  |- Currently failed:   12
|  |- Total failed:       12
`- Actions
   |- Currently banned:   1
   |- Total banned:       1
   `- Banned IP list:     10.0.2.2
```

- to unban the host IP
```bash
# syntax: fail2ban-client set <jail-name> unbanip <IP>
sudo      fail2ban-client set wordpress   unbanip 10.0.2.2

# or if multiple jails, free from all the jails at once:
sudo fail2ban-client unban 10.0.2.2
```


- Fail2ban now guards SSH and WordPress login attempts.

