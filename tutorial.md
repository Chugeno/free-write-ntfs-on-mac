# Tutorial: VERSION 2 - Enable Writing to NTFS Disks on macOS

This tutorial details how to install and configure NTFS-3G on macOS to enable writing to NTFS-formatted disks. This is version 2 of the script, which automates the process of mounting NTFS disks.

## Step 1: Install MacPorts

1. Visit the official MacPorts website: [MacPorts](https://www.macports.org/).
2. Download the installer corresponding to your version of macOS.
3. Follow the on-screen installation instructions.

## Step 2: Install NTFS-3G

Once you have MacPorts installed, open a terminal and run the following command:
```bash
sudo port install ntfs-3g
```
This command will install NTFS-3G along with all its dependencies.

## Step 3: Configure Sudoers

To allow the script to run without prompting for a password, you need to create or edit the sudoers configuration file. Follow these steps:

1. Open the terminal and run the following command:
```bash
sudo nano /etc/sudoers.d/ntfs
```

2. Add the following line to allow your user to run `ntfs-3g` without needing to enter a password:
```bash
your_username ALL=(ALL) NOPASSWD: /opt/local/bin/ntfs-3g
```

3. Save and exit the editor (in nano, press `Ctrl + X`, then `Y`, and `Enter`).

## Step 4: Configure Automator

1. Open **Automator** on your Mac.
2. Select **New Folder Action**.
3. Choose the `/Volumes/` folder located on the main disk.
4. Search for **Run Shell Script** in the actions library and drag it to the workspace.
5. Paste the following script into the shell script text box:

   [Download the script `auto_mount_ntfs.sh`](./auto_mount_ntfs.sh)

6. Save the folder action with a descriptive name, such as "Automatic NTFS Mounting".

## Step 5: Enjoy Writing to Your NTFS Disk

Now you can enjoy writing to your NTFS disk on macOS. Every time you connect an NTFS disk, the script will automatically run and mount the disk with write support.

## Extra: Mount a Specific NTFS Disk

If you want to mount only a specific NTFS disk for writing, you can use the following command:

1. Connect your NTFS disk to the Mac.
2. Check the disk identifier with:
```bash
diskutil list
```
Look for your NTFS disk in the list (e.g., /dev/disk4s1).

3. Mount the disk with the following command:
```bash
sudo /opt/local/bin/ntfs-3g -o auto_xattr /dev/diskXsY /Volumes/NAME -olocal -oallow_other
```
Replace `diskXsY` with the correct identifier for your disk and `NAME` with the name you want to assign to the mounted disk.

### Explanation of the command:

- `sudo`: Runs the command with administrator privileges.
- `/opt/local/bin/ntfs-3g`: Path to the NTFS-3G executable.
- `-o auto_xattr`: Enables automatic handling of extended attributes (necessary for macOS).
- `/dev/diskXsY`: Replace `diskXsY` with the identifier of your NTFS disk.
- `/Volumes/NAME`: Replace `NAME` with the name you want to assign to the mounted disk.
- `-olocal`: Indicates that the disk is a local file system.
- `-oallow_other`: Allows other users to access the file system.

---

If you need more adjustments or have any other requests, let me know! I'm here to help.