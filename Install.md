# Install

Guide to install the **Debian** version of the project.

We have installed in 42 Luxembourg the [**VirtualBox v7.0**](https://www.virtualbox.org/wiki/Downloads).

Download the [**Debian**](https://www.debian.org/download) image.

At the time of writing the latest stable version: [debian-12.11.0-amd64-netinst.iso](https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.11.0-amd64-netinst.iso)


## Virtual Machine Settings

Launch **VirtualBox** and follow the create wizard:

### Name and Operating System

1. Create a new Virtual Machine
2. Name: **Born2beRoot**
3. Folder: <where you have space for about 5..10 GB>, I'm using a USB stick
4. ISO Image: debian-12.11.0-amd64-netinst.iso

5. Type: **Linux** (autofilled from ISO image)
6. Version: **Debian (64-bit)** (autofilled from ISO image)
7. **✔** Skip unattended installation - tick it - we do our own install

### Unattended Install

we don't / can't set here anything

### Hardware

1. Base Memory: **2048 MB** (out of 16384 MB host memory)
2. Processors: **2** (out of 16 host CPUs)
3. Enable EFI: **Nope**

### Hard Disk

0. Create a Virtual HD Now:

1. HD File Location: **<path>/Born2beRoot/Born2beRoot.vdi**
2. HD Size: **31 GB** (this is the max size, the .vdi file is dinamically growing)

3. HD File Type: **VDI**
4. Pre-allocate Full Size: **Nope**

### Finish


## Debian Installation

### 1. Click Start (or Detachable Start)

Run the virtual machine and follow the OS install wizard.

1. `Install` (Not `Graphical install`)
2.  Language: `English`
3.  Country: `other` \ `Europe` \ `Luxembourg`
4.  Country to bae default locale settings on: `United States` - `en_US.UTF-8`
5.  Keymap to use: `American English`

6.  Hostname: **anemet42** (userid42)
7.  Domain name: **42.fr** \
    Root password: ... \
    Re-enter: ... \
    Full name new user: **Attila Nemet** \
    Username: **anemet** \
    Password: ... \
    Re-enter: ...


### Partition setup

For bonus part:

1.  Partition method: **Manual**
2.  `SCSIX (0,0,0) (sda) -> 33.3 GB ATA VBOX HARDDISK`
3.  `Create new partition`
4.  `pri/log 33.3 GB FREE SPACE`
5.  `Create a new partition` \
    size: `500M` \
    type: `Primary` \
    location: `Beginning` \
        Mount point: `/boot` \
        `Done setting up the partition`

6.  `pri/log 32.8 GB FREE SPACE`
7.  `Create a new partition`
    `32.8 GB` or `max` \
    `Logical` \
    `Mount point` \
    `Do not mount it` -> `none`\
    `Done setting up the partition`

8.  `Configure encrypted volumes` \
    Write the changes to disk and configure encrypted volumes? **Yes** \
    `Create encrypted volumes` \
    `[*] /dev/sda5` \
    `Done setting up the partition` \
    Encryption configuration actions: `Finish` \
    Really erase the data? **Yes** \
    Writing of random data... can be `Cancel`-ed
9.  Encryption passphrase
10. `Configure the Logical Volume Manager` \
    Write the changes to disk and configure encrypted volumes? **Yes** \
    `Create volume group` \
    **LVMGroup** \
    Devices for new volume group: `[*] /dev/mapper/sda5_crypt` \
    Volume group: `LVMGroup` \
    `Create Logical Volume` - `group` - `name` - `size` (see table below)
11. | Create logical volume | [ **LVMGroup** ] | name | size |
    | --- | --- | --- | --- |
    | --> | LVMGroup | `root` | 10G |
    | --> | LVMGroup | `swap` | 2.3G |
    | --> | LVMGroup | `home` | 5G |
    | --> | LVMGroup | `var` | 3G |
    | --> | LVMGroup | `srv` | 3G |
    | --> | LVMGroup | `tmp` | 3G |
    | --> | LVMGroup | `var-log` | 6471M (Remaining) |

    `Finish` \

    `Configure Encrypted Volumes`

12. | Select | Use as: | Mount point: | Done setting up the partition |
    | --- | --- | --- | --- |
    | `home #1 ...` | **EXT4 journaling file system** | `/home` | --> |
    | `root #1 ...` | **EXT4 journaling file system** | `/` | --> |
    | `srv #1 ...` | **EXT4 journaling file system** | `/srv` | --> |
    | `swap #1 ...` | **swap area** | N/A | --> |
    | `tmp #1 ...` | **EXT4 journaling file system** | `/tmp` | --> |
    | `var #1 ...` | **EXT4 journaling file system** | `/var` | --> |
    | `var-log #1 ...` | **EXT4 journaling file system** | Enter manually `/var/log` | --> |

    scroll down to:
13. `Finish partitioning and write changes to disk?` **Yes**
14. `Write changes to disk?` **Yes**
### Final Steps

- Scan another CD or DVD? **NO**
- Debian archive mirror country: **Belgium**
- `deb.debian.org`
- Leave proxy info field empty.
- Participate in the package usage survey? **NO**
- Unselect SSH server & standart system utilities
- GRUB **YES**
- Device for boot loader installation: `/dev/sda`
