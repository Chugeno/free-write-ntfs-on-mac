# VERSION 2.1 - Automatic Installation and NTFS Disk Mounting on macOS 🚀

Welcome to version 2.1 of this script! 🎉 This update automates the installation process of everything needed to enable write support for NTFS drives on macOS.

## Quick Start Steps

1. **Run the installation script:** 
   ```bash
   bash install_ntfs.sh
   ```
2. **Configure Sudoers:** Allow the script to run without password prompt. (Replace `your_username` with your actual username.)
   ```bash
   sudo visudo -f /private/etc/sudoers.d/your_username
   ```
   - Add the following line to the file:
     ```
     your_username ALL=(ALL) NOPASSWD: /opt/local/bin/ntfs-3g
     ```
   - Save and exit the editor.

   - Change the file permissions:
     ```bash
     sudo chmod 0440 /private/etc/sudoers.d/your_username
     ```

3. **Edit the script in `Automator`.**

## Complete Tutorial

You can find detailed instructions [here](./instalacion_automatica.es.md)

Or if you prefer a manual installation, check [here](./instalacion_manual.es.md).

## Contribute! ☕

If this project has been helpful to you, consider supporting it:
- [Buy Me a Coffee](http://buymeacoffee.com/chugeno)
- [Mercado Pago](http://link.mercadopago.com.ar/eugenioazurmendi)

### Spanish Version

Para leer el README en español, haz clic [aquí](README.es.md).

Thanks for your support and enjoy writing to your NTFS drives! 😊 