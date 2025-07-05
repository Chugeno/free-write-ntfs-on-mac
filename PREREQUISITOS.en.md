# Installation Prerequisites

> ⚠️ **Important:** We recommend opening this guide on a secondary device (like your phone) to easily follow the steps while restarting your Mac.

These steps are **essential** to allow the system to install and run the necessary drivers for writing to NTFS disks. You only need to perform them once.

---

### 1. Disable System Integrity Protection (SIP)

1.  Shut down your Mac completely.
2.  Turn on your Mac and continue to press and hold the **power button** until you see the startup options window.
3.  Click **Options**, then click **Continue**.
4.  Select your administrator user and enter your password if prompted.
5.  In the top menu bar, go to **Utilities > Terminal**.
6.  In the Terminal window, execute the following command:
    ```bash
    csrutil disable
    ```
7.  The system will require you to write your **administrator user** and then enter their password to authorize the change.
8.  Once confirmed, close the Terminal window.

### 2. Adjust the Secure Boot Policy

1.  In the same recovery mode, go to **Utilities > Startup Security Utility**.
2.  Select your system's startup disk (usually "Macintosh HD").
3.  **If your disk is protected with FileVault**, you may need to click **Unlock** and enter your password before proceeding.
4.  Click the **Security Policy...** button.
5.  Select the **Reduced Security** option.
6.  Under this option, make sure the checkbox for **"Allow user management of kernel extensions from identified developers"** is checked.
7.  Click **OK** and enter your password if prompted.

### 3. Restart the System

1.  Go to the Apple menu () in the top-left corner and select **Restart**.

---

Once your Mac has restarted, the system will be ready. You can now proceed with the [script installation](README.en.md#installation).
