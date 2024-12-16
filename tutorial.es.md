# Tutorial: Cómo instalar y usar NTFS-3G en macOS con MacPorts

Este tutorial detalla cómo instalar NTFS-3G en macOS utilizando MacPorts para habilitar la escritura en discos con formato NTFS. También incluye instrucciones sobre cómo montar discos NTFS desde la terminal y cómo automatizar el proceso.

## Paso 1: Instalar MacPorts

1. Visita el sitio oficial de MacPorts: https://www.macports.org/
2. Descarga el instalador correspondiente a tu versión de macOS.
3. Sigue las instrucciones de instalación en pantalla.

## Paso 2: Instalar NTFS-3G

Una vez que tengas MacPorts instalado, abre una terminal y ejecuta el siguiente comando:

```bash
sudo port install ntfs-3g
```

Este comando instalará NTFS-3G junto con todas sus dependencias.

## Paso 3: Identificar y desmontar el disco NTFS

Antes de montar un disco NTFS en modo escritura, sigue estos pasos:

1. Conecta tu disco NTFS al Mac.
2. Verifica el identificador del disco con:
   ```bash
   diskutil list
   ```
   Busca en la lista tu disco NTFS (por ejemplo, /dev/disk4s1).

3. Averigua el UUID del disco con el siguiente comando:
   ```bash
   diskutil info /dev/diskXsY | grep "Volume UUID"
   ```
   Reemplaza `diskXsY` con el identificador correcto de tu disco.

4. Desmonta el disco con:
   ```bash
   sudo diskutil unmount /dev/diskXsY
   ```
   Reemplaza `diskXsY` con el identificador correcto de tu disco.

## Paso 4: Montar el disco NTFS en modo escritura

Para montar el disco con soporte de escritura, usa el siguiente comando:

```bash
sudo /opt/local/bin/ntfs-3g -o auto_xattr /dev/diskXsY /Volumes/NAME -olocal -oallow_other
```

### Explicación del comando:

- `sudo`: Ejecuta el comando con privilegios de administrador.
- `/opt/local/bin/ntfs-3g`: Ruta al ejecutable de NTFS-3G.
- `-o auto_xattr`: Habilita el manejo automático de atributos extendidos (necesario para macOS).
- `/dev/diskXsY`: Reemplaza `diskXsY` con el identificador de tu disco NTFS.
- `/Volumes/NOMBRE`: Reemplaza `NOMBRE` con el nombre que deseas asignar al disco montado.
- `-olocal`: Indica que el disco es un sistema de archivos local.
- `-oallow_other`: Permite que otros usuarios accedan al sistema de archivos.

## Paso 5: Automatizar el Proceso con Automator

Para facilitar el montaje de discos NTFS, puedes crear una aplicación con Automator que ejecute un script. Utiliza el siguiente script en Automator:

```bash
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
    DISK_DEVICE=$(diskutil info "$DISK_UUID" ``` grep "Device Node" ``` awk '{print $3}')
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
```

### Nota adicional:

Este comando no configura el montaje automático. Si deseas que el disco se monte automáticamente cada vez que lo conectes, puedes configurar el archivo `/etc/fstab`. Pide ayuda si necesitas configurar esto.

Además, puedes agregar la aplicación creada en Automator a los elementos de inicio. Ve a "Preferencias del Sistema", luego a "Usuarios y Grupos", selecciona tu usuario, y en la pestaña "Elementos de inicio de sesión", haz clic en "+" para agregar la aplicación. Aparecerá un engranaje girando en la barra superior (donde está el reloj) que indica que el script está corriendo.

Con estos pasos, podrás habilitar la escritura en tus discos NTFS en macOS. Si tienes dudas o problemas, ¡deja un comentario!