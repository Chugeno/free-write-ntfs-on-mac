#!/bin/bash

# Función para mostrar notificaciones
notify() {
    osascript -e "display notification \"$1\" with title \"Auto Mount NTFS\""
}

# Función para verificar si el disco es NTFS
is_ntfs() {
    if diskutil info "$1" | grep "File System Personality:" | grep -q "NTFS"; then
        return 0  # Verdadero
    else
        return 1  # Falso
    fi
}

# Función para desmontar y montar el disco
mount_ntfs() {
    DISK_DEVICE="$1"
    
    # Obtener el nombre del disco
    DISK_NAME=$(diskutil info "$DISK_DEVICE" | grep "Volume Name" | awk -F ': ' '{print $2}' | xargs)
    
    # Construir el punto de montaje
    MOUNT_POINT="/Volumes/macFUSE $DISK_NAME"  # Concatenar "macFUSE " con el nombre del disco

    # Verificar si el punto de montaje contiene "macFUSE"
    if diskutil info "$DISK_DEVICE" | grep -q "macFUSE"; then
        echo "El punto de montaje es 'macFUSE', no se montará."
        return
    fi

    echo "Desmontando $DISK_DEVICE..."
    if diskutil unmount "$DISK_DEVICE"; then
        echo "Desmontado correctamente: $DISK_DEVICE"
        notify "Desmontado correctamente: $DISK_DEVICE"  # Notificación de desmontaje
        echo "Montando $DISK_DEVICE en $MOUNT_POINT..."
        
        # Solicitar la contraseña del usuario
        PASSWORD=$(osascript -e 'Tell application "System Events" to display dialog "Introduce tu contraseña para continuar:" default answer "" with hidden answer' -e 'text returned of result')
        
        # Usar la contraseña para ejecutar el comando ntfs-3g
        echo "$PASSWORD" | sudo -S /opt/local/bin/ntfs-3g -o auto_xattr,big_writes,local,allow_other "$DISK_DEVICE" "$MOUNT_POINT"
        
        if [ $? -eq 0 ]; then
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