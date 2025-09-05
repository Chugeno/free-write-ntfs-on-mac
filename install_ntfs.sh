#!/bin/bash
echo "--- SCRIPT VERSION 2.0 ---"

# --- Configuración Inicial ---
set -e

# --- Colores para la Salida ---
RED='[0;31m'
GREEN='[0;32m'
YELLOW='[0;33m'
NC='[0m'

# --- Funciones de Ayuda ---
print_header() {
    echo -e "
${GREEN}====================================================${NC}"
    echo -e "${GREEN} $1 ${NC}"
    echo -e "${GREEN}====================================================${NC}"
}

# --- Advertencia y Confirmación ---
echo -e "${YELLOW}Este script instalará las herramientas necesarias para escribir en unidades NTFS.${NC}"
echo -e "${YELLOW}Se instalará: Xcode Command Line Tools, MacPorts, y NTFS-3G.${NC}"
echo -e "${YELLOW}Se requiere la contraseña de administrador para continuar.${NC}"
read -p "¿Deseas continuar? (Y/n): " -n 1 -r
echo
REPLY=${REPLY:-Y}
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Instalación cancelada.${NC}"
    exit 1
fi

# --- Autenticación Sudo ---
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --- Paso 1: Xcode Command Line Tools ---
print_header "Paso 1: Verificando Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
    echo -e "${YELLOW}Xcode Tools no encontradas. Iniciando instalación...${NC}"
    xcode-select --install
    echo -e "
${YELLOW}*** ACCIÓN REQUERIDA ***${NC}"
    echo -e "Completa la instalación de Xcode y luego presiona 'Enter' para continuar."
    read -p ""
else
    echo -e "${GREEN}Xcode Command Line Tools ya están instaladas.${NC}"
fi

# --- Paso 2: MacPorts ---
print_header "Paso 2: Verificando e Instalando MacPorts"
if [ ! -x "/opt/local/bin/port" ]; then
    echo -e "${YELLOW}MacPorts no encontrado. Descargando e instalando...${NC}"
    MACOS_MAJOR_VERSION=$(sw_vers -productVersion | cut -d '.' -f 1)
    case "$MACOS_MAJOR_VERSION" in
      15) MACOS_NAME="Sequoia" ;;
      14) MACOS_NAME="Sonoma" ;;
      13) MACOS_NAME="Ventura" ;;
      12) MACOS_NAME="Monterey" ;;
      *) echo -e "${RED}Versión de macOS no soportada.${NC}"; exit 1 ;;
    esac
    echo "Buscando la última versión de MacPorts..."
    LATEST_TAG=$(curl -s https://api.github.com/repos/macports/macports-base/releases/latest | grep '"tag_name":' | cut -d '"' -f4)
    if [ -z "$LATEST_TAG" ]; then
        echo -e "${RED}Error al obtener la versión de MacPorts.${NC}"; exit 1
    fi
    VERSION_NUMBER=${LATEST_TAG#v}
    PKG_FILENAME="MacPorts-${VERSION_NUMBER}-${MACOS_MAJOR_VERSION}-${MACOS_NAME}.pkg"
    MACPORTS_URL="https://github.com/macports/macports-base/releases/download/${LATEST_TAG}/${PKG_FILENAME}"
    echo "Descargando desde: $MACPORTS_URL"
    curl -L -o "$PKG_FILENAME" "$MACPORTS_URL"
    if [ ! -s "$PKG_FILENAME" ]; then
        echo -e "${RED}La descarga de MacPorts falló.${NC}"; exit 1
    fi
    echo -e "
${YELLOW}*** ACCIÓN REQUERIDA ***${NC}"
    echo -e "Se abrirá el instalador de MacPorts. Complétalo y presiona 'Enter' para continuar."
    open "$PKG_FILENAME"
    read -p ""
    rm -f "$PKG_FILENAME"
    export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
    echo "Actualizando MacPorts por primera vez..."
    sudo port selfupdate
else
    echo -e "${GREEN}MacPorts ya está instalado. Actualizando...${NC}"
    export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
    sudo port selfupdate
fi

# --- Paso 3: NTFS-3G y enlace de macFUSE ---
print_header "Paso 3: Instalando Herramientas de Montaje"
if ! port -q installed ntfs-3g | grep -q 'ntfs-3g.*@.*active'; then
    echo -e "${YELLOW}Instalando NTFS-3G vía MacPorts...${NC}"
    sudo port -N install ntfs-3g
else
    echo -e "${GREEN}NTFS-3G ya está instalado.${NC}"
fi

if ! port -q installed terminal-notifier | grep -q 'terminal-notifier.*@.*active'; then
    echo -e "${YELLOW}Instalando terminal-notifier para las notificaciones...${NC}"
    sudo port -N install terminal-notifier
else
    echo -e "${GREEN}terminal-notifier ya está instalado.${NC}"
fi

echo "Creando el enlace simbólico para FUSE..."
sudo ln -fsn "/opt/local/Library/Filesystems/macfuse.fs" "/Library/Filesystems/macfuse.fs"
echo -e "${GREEN}Enlace simbólico para macFUSE creado.${NC}"

# --- Paso 4: Creación del Script de Montaje Automático ---
print_header "Paso 4: Configurando el script de montaje automático"

INSTALL_DIR="$HOME/.ntfs-automount"
SCRIPT_DEST="$INSTALL_DIR/auto_mount_ntfs.sh"

echo "Creando directorio de instalación en: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

echo "Creando script de montaje en: $SCRIPT_DEST"

# Usar un "here document" para crear el script de montaje
cat > "$SCRIPT_DEST" << 'EOF'
#!/bin/bash

# --- Script de Montaje Automático de NTFS con Escritura ---
# Versión para LaunchAgent de Usuario

# --- Función de Notificación ---
# Muestra una notificación usando terminal-notifier.
# Se ejecuta como el usuario actual, por lo que la lógica es simple.
# Argumento 1: Título de la notificación.
# Argumento 2: Mensaje de la notificación.
notify() {
    local title="$1"
    local message="$2"
    
    # La ruta absoluta sigue siendo una buena práctica
    local notifier_path="/opt/local/bin/terminal-notifier"

    if [ -x "$notifier_path" ]; then
        "$notifier_path" -title "$title" -message "$message" -sender "com.apple.DiskUtility"
    fi
}

# --- Lógica de Montaje ---

# Función para verificar si el disco es NTFS
is_ntfs() {
    # Usamos la ruta absoluta para mayor robustez
    if /usr/sbin/diskutil info "$1" | /usr/bin/grep -q "Type (Bundle): *ntfs"; then
        return 0  # Es NTFS
    else
        return 1  # No es NTFS
    fi
}

# Función para desmontar y montar el disco
mount_ntfs() {
    local DEVICE_PATH="$1"
    
    # Obtener el nombre del volumen (disco)
    local DISK_NAME
    DISK_NAME=$(/usr/sbin/diskutil info "$DEVICE_PATH" | /usr/bin/grep "Volume Name:" | sed 's/.*Volume Name: *//')

    # Si el nombre está vacío, es un error, no continuar
    if [ -z "$DISK_NAME" ]; then
        echo "No se pudo obtener el nombre del volumen para $DEVICE_PATH. Ignorando."
        return
    fi

    # Construir el nuevo punto de montaje con el formato "NOMBRE macFUSE"
    local MOUNT_POINT="/Volumes/${DISK_NAME} macFUSE"

    # Verificar si ya está montado por nosotros para evitar bucles
    local CURRENT_MOUNT_POINT
    CURRENT_MOUNT_POINT=$(/usr/sbin/diskutil info "$DEVICE_PATH" | /usr/bin/grep "Mount Point:" | sed 's/.*Mount Point: *//')
    
    if [[ "$CURRENT_MOUNT_POINT" == *macFUSE* ]]; then
        echo "El disco '$DISK_NAME' ya está montado con macFUSE. No se hará nada."
        return
    fi

    echo "Disco NTFS detectado: '$DISK_NAME' en $DEVICE_PATH"
    notify "Disco NTFS Detectado" "Iniciando proceso para '$DISK_NAME'."

    echo "Desmontando $DEVICE_PATH..."
    if /usr/sbin/diskutil unmount "$DEVICE_PATH"; then
        echo "Desmontado correctamente: $DEVICE_PATH"
        
        # Crear el directorio para el nuevo punto de montaje (si no existe)
        # sudo es necesario porque /Volumes es propiedad de root y el script corre como usuario
        sudo mkdir -p "$MOUNT_POINT"

        echo "Montando $DEVICE_PATH en '$MOUNT_POINT' con permisos de escritura..."
        
        # Montar con ntfs-3g. Sudo es necesario y la regla en sudoers evita la contraseña.
        if sudo /opt/local/bin/ntfs-3g -o auto_xattr,big_writes,local,allow_other,volname="${DISK_NAME} macFUSE" "$DEVICE_PATH" "$MOUNT_POINT"; then
            echo "Éxito: Disco '$DISK_NAME' montado en '$MOUNT_POINT'."
            notify "Montaje Exitoso" "'$DISK_NAME' ahora tiene permisos de escritura."
        else
            echo "Error al montar el disco '$DISK_NAME' con ntfs-3g."
            notify "Error de Montaje" "Falló el comando ntfs-3g para '$DISK_NAME'."
        fi
    else
        echo "Error al desmontar el disco: $DEVICE_PATH. Puede que esté en uso."
        notify "Error de Montaje" "No se pudo desmontar '$DISK_NAME'."
    fi
}

# --- Bucle Principal ---
# Este script es llamado por launchd cuando hay cambios en /Volumes.
echo "--- Iniciando script de montaje NTFS ---"
# Esperar un segundo para asegurar que el sistema haya registrado el nuevo volumen
sleep 1 

# Obtener una lista de todos los identificadores de dispositivo (ej: disk2s1)
/usr/sbin/diskutil list | while read -r LINE; do
    # Si la línea contiene la palabra "Windows_NTFS" (un indicador común)
    if echo "$LINE" | /usr/bin/grep -q "Windows_NTFS"; then
        # Extraer el identificador del disco (ej: disk4s1)
        DISK_IDENTIFIER=$(echo "$LINE" | /usr/bin/awk '{print $NF}')
        
        DEVICE_PATH="/dev/$DISK_IDENTIFIER"
        
        # Verificar si realmente es NTFS antes de proceder
        if is_ntfs "$DEVICE_PATH"; then
            # Llamar a la función principal de montaje
            mount_ntfs "$DEVICE_PATH"
        fi
    fi
done

echo "--- Proceso de montaje finalizado ---"
EOF

# Asegurarse de que el nuevo script sea ejecutable
chmod +x "$SCRIPT_DEST"

# --- Paso 5: Creación y Activación del Agente de Usuario (launchd) ---
print_header "Paso 5: Activando el servicio de montaje automático"

# Usaremos un LaunchAgent para que se ejecute como el usuario actual.
AGENT_LABEL="com.user.automountntfs"
PLIST_DEST="$HOME/Library/LaunchAgents/${AGENT_LABEL}.plist"

echo "Creando el archivo de configuración del servicio en: $PLIST_DEST"
mkdir -pv "$HOME/Library/LaunchAgents"

# Crear el archivo plist directamente usando un here-document.
# Esto evita la asignación de variables multilínea que estaba causando errores.
cat > "$PLIST_DEST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${AGENT_LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${SCRIPT_DEST}</string>
    </array>
    <key>WatchPaths</key>
    <array>
        <string>/Volumes</string>
    </array>
</dict>
</plist>
EOF

echo "Activando servicio..."
# Descargar primero si ya existe, para asegurar una recarga limpia.
# No usamos 'sudo' porque es un LaunchAgent del usuario.
if launchctl list | grep -q "$AGENT_LABEL"; then
    echo "El servicio ya existía. Recargando..."
    launchctl unload "$PLIST_DEST"
    sleep 1
fi
launchctl load "$PLIST_DEST"

# Verificar que el servicio (agente) esté cargado
if launchctl list | grep -q "$AGENT_LABEL"; then
    echo -e "${GREEN}El servicio de montaje automático se activó correctamente.${NC}"
else
    echo -e "${RED}Error: No se pudo activar el servicio de montaje automático.${NC}"
    exit 1
fi

# --- Paso 6: Configuración de Sudo sin Contraseña ---
print_header "Paso 6: Configurando sudo para montaje sin contraseña"
CURRENT_USER=$(whoami)
SUDOERS_NTFS3G_RULE="$CURRENT_USER ALL=(ALL) NOPASSWD: /opt/local/bin/ntfs-3g"
SUDOERS_MKDIR_RULE="$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/mkdir -p /Volumes/*"
SUDOERS_FILE="/etc/sudoers.d/ntfs-automount-rules"

echo "Añadiendo reglas a sudoers para ntfs-3g y mkdir..."
# Usamos un solo archivo para ambas reglas para mantenerlo organizado.
(echo "$SUDOERS_NTFS3G_RULE"; echo "$SUDOERS_MKDIR_RULE") | sudo tee "$SUDOERS_FILE" > /dev/null
sudo chmod 0440 "$SUDOERS_FILE"
echo -e "${GREEN}Configuración de sudo completada.${NC}"

# --- Finalización ---
print_header "Instalación Completada"
echo -e "${GREEN}El proceso ha finalizado. Se recomienda reiniciar.${NC}"
echo -e "${YELLOW}Recuerda aprobar las extensiones de sistema de FUSE en 'Privacidad y seguridad' si el sistema lo solicita.${NC}"
echo -e "¡Listo! ✨"
