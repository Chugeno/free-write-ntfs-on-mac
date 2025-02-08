#!/bin/bash

# Función para mostrar notificaciones
notify() {
    osascript -e "display notification \"$1\" with title \"Auto Mount NTFS\""
}

# Función para verificar si el disco es NTFS
is_ntfs() {
    if diskutil info "$1" | grep -q "Windows_NTFS"; then
        return 0  # Verdadero
    else
        return 1  # Falso
    fi
}

# Función para desmontar y montar el disco
mount_ntfs() {
    DISK_DEVICE="$1"
    MOUNT_POINT="/Volumes/$(basename "$DISK_DEVICE")"  # Usa el nombre del dispositivo como punto de montaje

    # Verificar si el punto de montaje comienza con "macFUSE"
    if [[ "$MOUNT_POINT" == /Volumes/macFUSE* ]]; then
        echo "El punto de montaje comienza con 'macFUSE', no se montará."
        return
    fi

    echo "Desmontando $DISK_DEVICE..."
    if diskutil unmount "$DISK_DEVICE"; then
        echo "Desmontado correctamente: $DISK_DEVICE"
        notify "Desmontado correctamente: $DISK_DEVICE"  # Notificación de desmontaje
        echo "Montando $DISK_DEVICE en $MOUNT_POINT..."
        if sudo /opt/local/bin/ntfs-3g -o auto_xattr "$DISK_DEVICE" "$MOUNT_POINT" -olocal -oallow_other; then
            echo "Disco montado correctamente en $MOUNT_POINT"
            notify "Disco montado correctamente en $MOUNT_POINT"  # Notificación de montaje
        else
            echo "Error al montar el disco: $DISK_DEVICE"
            notify "Error al montar el disco: $DISK_DEVICE"  # Notificación de error
        fi
    else
        echo "Error al desmontar el disco: $DISK_DEVICE"
        notify "Error al desmontar el disco: $DISK_DEVICE"  # Notificación de error
    fi
}

# Monitorear todos los discos conectados
# Listar discos conectados
echo "Buscando discos NTFS conectados..."
diskutil list | while read -r LINE; do
    # Verificar si la línea contiene "Windows_NTFS"
    if echo "$LINE" | grep -q "Windows_NTFS"; then
        # Extraer el identificador del disco
        DISK_IDENTIFIER=$(echo "$LINE" | awk '{print $NF}')  # Obtener el último campo (IDENTIFIER)
        
        # Construir la cadena del dispositivo
        DEVICE_PATH="/dev/$DISK_IDENTIFIER"
        echo "Construyendo la cadena del dispositivo: $DEVICE_PATH"  # Mostrar cómo se arma la cadena
        
        # Verificar si es NTFS
        if is_ntfs "$DEVICE_PATH"; then
            echo "$DISK_IDENTIFIER es NTFS."
            # Llamar a la función para desmontar y montar
            mount_ntfs "$DEVICE_PATH"
        fi
    fi
done