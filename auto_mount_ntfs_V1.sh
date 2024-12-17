#!/bin/bash

# UUID único del disco
DISK_UUID="6256AD4A-B8C3-44AA-A382-22F5EAAE7896"  # Reemplázalo con el UUID de tu disco
MOUNT_POINT="/Volumes/Elements"  # Cambia por el nombre de tu punto de montaje

# Función para montar el disco
mount_disk() {
    echo "Disco con UUID $DISK_UUID detectado. Procediendo a desmontar y montar con NTFS-3G..."
    DISK_DEVICE=$(diskutil info "$DISK_UUID" | grep "Device Node" | awk '{print $3}')
    sudo diskutil unmount $DISK_DEVICE
    sudo /opt/local/bin/ntfs-3g -o auto_xattr $DISK_DEVICE $MOUNT_POINT -olocal -oallow_other
    echo "Disco montado correctamente en $MOUNT_POINT"
}

# Loop para observar constantemente las conexiones de discos
while true; do
    # Verifica si el disco con el UUID está conectado
    if diskutil info "$DISK_UUID" &> /dev/null; then
        mount_disk
        # Espera hasta que el disco sea desconectado antes de volver a buscarlo
        while diskutil info "$DISK_UUID" &> /dev/null; do
            sleep 5
        done
    fi
    # Revisa cada 5 segundos si se conecta el disco
    sleep 5
done
