#!/bin/bash

# --- Configuración Inicial ---
set -e

# --- Colores para la Salida ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# --- Funciones de Ayuda ---
print_header() {
    echo -e "\n${GREEN}====================================================${NC}"
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
    echo -e "\n${YELLOW}*** ACCIÓN REQUERIDA ***${NC}"
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
    echo -e "\n${YELLOW}*** ACCIÓN REQUERIDA ***${NC}"
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
print_header "Paso 3: Instalando NTFS-3G y configurando macFUSE"
if ! port -q installed ntfs-3g | grep -q 'ntfs-3g.*@.*active'; then
    echo -e "${YELLOW}Instalando NTFS-3G vía MacPorts...${NC}"
    sudo port -N install ntfs-3g
else
    echo -e "${GREEN}NTFS-3G ya está instalado.${NC}"
fi
echo "Creando el enlace simbólico para FUSE..."
sudo ln -fsn "/opt/local/Library/Filesystems/macfuse.fs" "/Library/Filesystems/macfuse.fs"
echo -e "${GREEN}Enlace simbólico para macFUSE creado.${NC}"

# --- Paso 4: Flujo de trabajo de Automator ---
print_header "Paso 4: Copiando el Flujo de Trabajo"
WORKFLOW_SOURCE="./auto_mount_ntfs.workflow"
DEST_DIR="$HOME/Library/Workflows/Applications/Folder Actions"
mkdir -p "$DEST_DIR"
cp -R "$WORKFLOW_SOURCE" "$DEST_DIR/"
echo "Flujo de trabajo copiado a $DEST_DIR"

# --- Paso 5: Activar el Flujo de Trabajo ---
print_header "Paso 5: Activando el Flujo de Trabajo para /Volumes"
WORKFLOW_PATH="$DEST_DIR/auto_mount_ntfs.workflow"
WORKFLOW_NAME="auto_mount_ntfs.workflow"
echo "Registrando el workflow con el sistema..."
RESULT=$(osascript -e '
on run argv
	set workflowPath to item 1 of argv
	set workflowName to item 2 of argv
	try
		tell application "System Events"
			if not (folder actions enabled) then set folder actions enabled to true
			try
				set theFolderAction to make new folder action with properties {path:"/Volumes"}
			on error
				set allFolderActions to every folder action
				repeat with anAction in allFolderActions
					if path of anAction is "/Volumes" then
						set theFolderAction to anAction
						exit repeat
					end if
				end repeat
			end try
			if theFolderAction is missing value then return "Error: No se pudo obtener la referencia."
			set isAttached to false
			try
				if (name of scripts of theFolderAction) contains workflowName then set isAttached to true
			end try
			if not isAttached then
				make new script at end of scripts of theFolderAction with properties {path:(POSIX file workflowPath)}
				return "ÉXITO: Workflow adjuntado."
			else
				return "ÉXITO: El workflow ya estaba adjunto."
			end if
		end tell
	on error errMsg number errNum
		return "Error fatal (" & errNum & "): " & errMsg
	end try
end run
' "$WORKFLOW_PATH" "$WORKFLOW_NAME")
if [[ "$RESULT" == ÉXITO* ]]; then
    echo -e "${GREEN}El flujo de trabajo está activo.${NC}"
else
    echo -e "${RED}Falló la activación del flujo de trabajo: $RESULT${NC}"
fi

# --- Paso 6: Configuración de Sudo sin Contraseña ---
print_header "Paso 6: Configurando sudo para montaje sin contraseña"
CURRENT_USER=$(whoami)
SUDOERS_RULE="$CURRENT_USER ALL=(ALL) NOPASSWD: /opt/local/bin/ntfs-3g"
SUDOERS_FILE="/etc/sudoers.d/ntfs-no-pass"
echo "Añadiendo regla a sudoers..."
echo "$SUDOERS_RULE" | sudo tee "$SUDOERS_FILE" > /dev/null
sudo chmod 0440 "$SUDOERS_FILE"
echo -e "${GREEN}Configuración de sudo completada.${NC}"

# --- Finalización ---
print_header "Instalación Completada"
echo -e "${GREEN}El proceso ha finalizado. Se recomienda reiniciar.${NC}"
echo -e "${YELLOW}Recuerda aprobar las extensiones de sistema de FUSE en 'Privacidad y seguridad' si el sistema lo solicita.${NC}"
echo -e "¡Listo! ✨"