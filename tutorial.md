# Tutorial: How to Install and Use NTFS-3G on macOS with MacPorts

This tutorial details how to install NTFS-3G on macOS using MacPorts to enable writing to NTFS-formatted disks. It also includes instructions on how to mount NTFS disks from the terminal and how to automate the process.

## Step 1: Install MacPorts

1. Visit the official MacPorts website: https://www.macports.org/
2. Download the installer corresponding to your version of macOS.
3. Follow the on-screen installation instructions.

## Step 2: Install NTFS-3G

Once you have MacPorts installed, open a terminal and run the following command:

'''bash
sudo port install ntfs-3g
'''

This command will install NTFS-3G along with all its dependencies.

## Step 3: Identify and Unmount the NTFS Disk

Before mounting an NTFS disk in write mode, follow these steps:

1. Connect your NTFS disk to the Mac.
2. Check the disk identifier with:
   '''bash
   diskutil list
   '''
   Look for your NTFS disk in the list (e.g., /dev/disk4s1).

3. Find out the UUID of the disk with the following command:
   '''bash
   diskutil info /dev/diskXsY ''' grep "Volume UUID"
   '''
   Replace `diskXsY` with the correct identifier for your disk.

4. Unmount the disk with:
   '''bash
   sudo diskutil unmount /dev/diskXsY
   '''
   Replace `diskXsY` with the correct identifier for your disk.

## Step 4: Mount the NTFS Disk in Write Mode

To mount the disk with write support, use the following command:

'''bash
sudo /opt/local/bin/ntfs-3g -o auto_xattr /dev/diskXsY /Volumes/NAME -olocal -oallow_other
'''

### Explanation of the Command:

- `sudo`: Runs the command with administrator privileges.
- `/opt/local/bin/ntfs-3g`: Path to the NTFS-3G executable.
- `-o auto_xattr`: Enables automatic handling of extended attributes (necessary for macOS).
- `/dev/diskXsY`: Replace `diskXsY` with the identifier of your NTFS disk.
- `/Volumes/NAME`: Replace `NAME` with the name you want to assign to the mounted disk.
- `-olocal`: Indicates that the disk is a local file system.
- `-oallow_other`: Allows other users to access the file system.

## Step 5: Automate the Process with Automator

To facilitate the mounting of NTFS disks, you can create an application with Automator that runs a script. Use the following script in Automator:

'''bash
#!/bin/bash

# Unique UUID of the disk
DISK_UUID="6256AD4A-B8C3-44AA-A382-22F5EAAE7896"  # Replace with your disk's UUID
MOUNT_POINT="/Volumes/Elements"  # Change to your desired mount point

# Function to show notifications
notify() {
    osascript -e "display notification \"$1\" with title \"Auto Mount NTFS\""
}

# Function to mount the disk
mount_disk() {
    notify "Disk with UUID $DISK_UUID detected. Proceeding to unmount and mount with NTFS-3G..."
    DISK_DEVICE=$(diskutil info "$DISK_UUID" ''' grep "Device Node" ''' awk '{print $3}')
    sudo diskutil unmount $DISK_DEVICE
    sudo /opt/local/bin/ntfs-3g -o auto_xattr $DISK_DEVICE $MOUNT_POINT -olocal -oallow_other
    notify "Disk successfully mounted at $MOUNT_POINT"
}

# Loop to constantly observe disk connections
while true; do
    if diskutil info "$DISK_UUID" &> /dev/null; then
        mount_disk
        while diskutil info "$DISK_UUID" &> /dev/null; do
            sleep 5
        done
    fi
    sleep 5
done
'''

### Additional Note:

This command does not configure automatic mounting. If you want the disk to mount automatically every time you connect it, you can configure the `/etc/fstab` file. Ask for help if you need to set this up.

You can also add the application created in Automator to the login items. Go to "System Preferences," then "Users & Groups," select your user, and in the "Login Items" tab, click "+" to add the application. A spinning gear will appear in the top bar (where the clock is) indicating that the script is running.

With these steps, you will be able to enable writing to your NTFS disks on macOS. If you have questions or issues, feel free to leave a comment!