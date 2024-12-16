# Free Write NTFS on Mac 🚀

This project aims to enable writing to NTFS disks on macOS using NTFS-3G and MacPorts.

## Overview

This repository contains a tutorial on how to install NTFS-3G and automate the mounting of NTFS disks on macOS. 

### Quick Steps

1. **Install MacPorts**: Visit [MacPorts](https://www.macports.org/) and follow the installation instructions.
2. **Install NTFS-3G**: Run the following command in the terminal:
   ```bash
   sudo port install ntfs-3g
   ```
3. **Mount the NTFS Disk**: Use the following command to mount the disk:
   ```bash
   sudo /opt/local/bin/ntfs-3g -o auto_xattr /dev/diskXsY /Volumes/NAME -olocal -oallow_other
   ```
   Replace `diskXsY` with the correct identifier for your disk and `NAME` with the desired mount point.
4. **Automate Mounting**: Create an Automator application using the provided script in the tutorial.

### Full Tutorial

For detailed instructions, please refer to the full tutorial [here](tutorial.md). This tutorial also includes a script to automate the mounting of your NTFS disk.

### Support the Project

If you would like to support this small project, you can do so here:
- [Buy Me a Coffee](http://buymeacoffee.com/chugeno)
- [Mercado Pago](http://link.mercadopago.com.ar/eugenioazurmendi)

### Spanish Version

Para leer el README en español, haz clic [aquí](README.es.md).

Thank you for checking out this project! If you have any questions or feedback, feel free to reach out. 😊