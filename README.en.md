# NTFS for Mac - Automatic Mount

This project provides a complete solution to automatically mount NTFS-formatted drives on macOS with read and write permissions. It uses `ntfs-3g` and `macFUSE` along with a `launchd` agent to detect and mount drives seamlessly for the user.

[Versión en Español](README.md)

---

## Features

-   **Automatic Mounting:** NTFS drives are mounted automatically upon connection.
-   **Write Permissions:** Full read and write access to your NTFS disks.
-   **Notifications:** You will receive real-time notifications about the mount status.
-   **Simple Installation:** A single script handles the installation of all dependencies and system configuration.
-   **Uninstaller Included:** A script to safely revert all changes.

---

## Installation

### 1. Meet the Prerequisites

Before installing, it is **crucial** to prepare your system. Follow all the instructions detailed in the guide below:

➡️ **[Installation Prerequisites Guide](PREREQUISITOS.en.md)**

### 2. Run the Installation Script

Once you have completed the prerequisites and restarted your Mac, open a terminal and run the following command. You can copy and paste it.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Chugeno/free-write-ntfs-on-mac/main/install_ntfs.sh)"
```

The script will guide you through the installation of `ntfs-3g`, `macFUSE`, and `terminal-notifier` using MacPorts, and will set up the automatic mounting agent.

---

## Uninstallation

If you wish to remove the auto-mount solution and/or the installed tools, you can use the uninstaller script.

Run the following command in your terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Chugeno/free-write-ntfs-on-mac/main/uninstall.sh)"
```

The uninstaller will give you two options:
-   **Partial Uninstall:** Removes only the auto-mount configuration, but leaves `ntfs-3g`, `macFUSE`, and `terminal-notifier` on your system.
-   **Complete Uninstall:** Removes the configuration AND all tools installed by the script.

---

## How It Works

-   **`install_ntfs.sh`**: The main script that installs dependencies (`macFUSE`, `ntfs-3g`, `terminal-notifier`) via MacPorts and sets up a Launch Agent (`launchd`).
-   **`auto_mount_ntfs.sh`**: The script that runs in the background. It is triggered by `launchd` whenever a new volume is connected in `/Volumes`. It detects if it is an NTFS drive, unmounts it, and remounts it using `ntfs-3g` with write permissions.
-   **`uninstall.sh`**: The script that stops and removes the Launch Agent and offers to uninstall the dependencies.
-   **`launchd` Agent**: A service (`com.user.automountntfs.plist`) that runs in the background and watches the `/Volumes` folder to launch `auto_mount_ntfs.sh` when needed.
