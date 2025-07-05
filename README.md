# NTFS para Mac - Montaje Automático

Este proyecto proporciona una solución completa para montar automáticamente unidades con formato NTFS en macOS con permisos de lectura y escritura. Utiliza `ntfs-3g` y `macFUSE` junto con un agente de `launchd` para detectar y montar las unidades de forma transparente para el usuario.

[English Version](README.en.md)

---

## Características

-   **Montaje Automático:** Las unidades NTFS se montan automáticamente al conectarse.
-   **Permisos de Escritura:** Acceso completo de lectura y escritura en tus discos NTFS.
-   **Notificaciones:** Recibirás notificaciones en tiempo real sobre el estado del montaje.
-   **Instalación Sencilla:** Un único script se encarga de instalar todas las dependencias y configurar el sistema.
-   **Desinstalador Incluido:** Un script para revertir todos los cambios de forma segura.

---

## Instalación

### 1. Cumplir los Pre-requisitos

Antes de instalar, es **crucial** que prepares tu sistema. Sigue todas las instrucciones detalladas en la siguiente guía:

➡️ **[Guía de Pre-requisitos de Instalación](PREREQUISITOS.md)**

### 2. Ejecutar el Script de Instalación

Una vez completados los pre-requisitos y reiniciado tu Mac, abre una terminal y ejecuta el siguiente comando. Puedes copiarlo y pegarlo.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/eugenioazurmendi/NTFS-MAC-PORTS-SCRIPT/main/install_ntfs.sh)"
```

El script te guiará a través de la instalación de `ntfs-3g`, `macFUSE` y `terminal-notifier` usando Homebrew, y configurará el agente de montaje automático.

---

## Desinstalación

Si deseas eliminar la solución de montaje automático y/o las herramientas instaladas, puedes usar el script de desinstalación.

Ejecuta el siguiente comando en tu terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/eugenioazurmendi/NTFS-MAC-PORTS-SCRIPT/main/uninstall.sh)"
```

El desinstalador te dará dos opciones:
-   **Desinstalación Parcial:** Elimina únicamente la configuración de montaje automático, pero deja `ntfs-3g`, `macFUSE` y `terminal-notifier` en tu sistema.
-   **Desinstalación Completa:** Elimina la configuración Y todas las herramientas instaladas por el script.

---

## ¿Cómo funciona?

-   **`install_ntfs.sh`**: Script principal que instala las dependencias (`macFUSE`, `ntfs-3g`, `terminal-notifier`) a través de Homebrew y configura un Agente de Lanzamiento (`launchd`).
-   **`auto_mount_ntfs.sh`**: Script que se ejecuta en segundo plano. Es activado por `launchd` cada vez que se conecta un nuevo volumen en `/Volumes`. Detecta si es una unidad NTFS, la desmonta y la vuelve a montar usando `ntfs-3g` con permisos de escritura.
-   **`uninstall.sh`**: Script que detiene y elimina el Agente de Lanzamiento y ofrece desinstalar las dependencias.
-   **Agente de `launchd`**: Un servicio (`com.user.automountntfs.plist`) que se ejecuta en segundo plano y vigila la carpeta `/Volumes` para lanzar `auto_mount_ntfs.sh` cuando sea necesario.