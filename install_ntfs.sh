#!/bin/bash

# --- Configuración Inicial ---
# Detiene el script si un comando falla, lo que lo hace más seguro.
set -e

# --- Colores para la Salida ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # Sin color

# --- Funciones de Ayuda ---
# Función para imprimir encabezados y hacer el script más legible
print_header() {
    echo -e "\n${GREEN}====================================================${NC}"
    echo -e "${GREEN} $1 ${NC}"
    echo -e "${GREEN}====================================================${NC}"
}

# --- Advertencia y Confirmación ---
echo -e "${YELLOW}Este script instalará las herramientas necesarias para escribir en unidades NTFS.${NC}"
echo -e "${YELLOW}Se instalará: Xcode Command Line Tools, MacPorts, y NTFS-3G.${NC}"
echo -e "${YELLOW}Se requiere la contraseña de administrador para continuar.${NC}"
read -p "¿Deseas continuar con la instalación? (Y/n): " -n 1 -r
echo # Nueva línea
REPLY=${REPLY:-Y}
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Instalación cancelada.${NC}"
    exit 1
fi

# Solicitar contraseña de sudo al principio para que no interrumpa más tarde
sudo -v
# Mantener viva la sesión de sudo mientras el script se ejecuta
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --- Paso 1: Herramientas de Línea de Comandos de Xcode ---
print_header "Paso 1: Verificando Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
    echo -e "${YELLOW}Xcode Command Line Tools no encontradas. Iniciando instalación...${NC}"
    xcode-select --install

    echo -e "\n${YELLOW}*** ACCIÓN REQUERIDA ***${NC}"
    echo -e "${YELLOW}Se ha abierto el instalador de Xcode. El script se pausará.${NC}"
    echo -e "${YELLOW}Por favor, completa la instalación (puede tardar varios minutos) y luego presiona la tecla 'Enter' en esta terminal para continuar.${NC}"
    read -p ""
else
    echo -e "${GREEN}Xcode Command Line Tools ya están instaladas. Saltando este paso.${NC}"
fi

# --- Paso 2: MacPorts ---
print_header "Paso 2: Verificando e Instalando MacPorts"

# Comprobamos la existencia del ejecutable de MacPorts en su ruta absoluta.
if [ ! -x "/opt/local/bin/port" ]; then
    echo -e "${YELLOW}MacPorts no encontrado. Procediendo con la descarga e instalación...${NC}"
    
    # Detectar versión y nombre de macOS para construir la URL de descarga correcta
    MACOS_MAJOR_VERSION=$(sw_vers -productVersion | cut -d '.' -f 1)
    case "$MACOS_MAJOR_VERSION" in
      15) MACOS_NAME="Sequoia" ;;
      14) MACOS_NAME="Sonoma" ;;
      13) MACOS_NAME="Ventura" ;;
      12) MACOS_NAME="Monterey" ;;
      *) echo -e "${RED}Tu versión de macOS ($MACOS_MAJOR_VERSION) no es compatible. Saliendo.${NC}"; exit 1 ;;
    esac

    # Obtener la última versión de MacPorts dinámicamente desde la API de GitHub
    echo "Buscando la última versión de MacPorts..."
    LATEST_TAG=$(curl -s https://api.github.com/repos/macports/macports-base/releases/latest | grep '"tag_name":' | cut -d '"' -f4)

    # Comprobación de robustez: Asegurarse de que obtuvimos un tag
    if [ -z "$LATEST_TAG" ]; then
        echo -e "${RED}Error: No se pudo obtener la última versión de MacPorts desde la API de GitHub.${NC}"
        echo -e "${YELLOW}Intenta de nuevo más tarde.${NC}"
        exit 1
    fi

    # Construir la URL con la estructura de nombres verificada
    VERSION_NUMBER=${LATEST_TAG#v} # Quita la 'v' inicial (ej: v2.10.7 -> 2.10.7)
    PKG_FILENAME="MacPorts-${VERSION_NUMBER}-${MACOS_MAJOR_VERSION}-${MACOS_NAME}.pkg"
    MACPORTS_URL="https://github.com/macports/macports-base/releases/download/${LATEST_TAG}/${PKG_FILENAME}"

    echo "Descargando MacPorts desde: $MACPORTS_URL"
    curl -L -o "$PKG_FILENAME" "$MACPORTS_URL"

    # Comprobar si la descarga fue exitosa
    if [ ! -s "$PKG_FILENAME" ]; then
        echo -e "${RED}Error: La descarga de MacPorts falló o el archivo está vacío.${NC}"
        echo -e "${YELLOW}Por favor, verifica la URL en un navegador: $MACPORTS_URL${NC}"
        exit 1
    fi

    echo -e "\n${YELLOW}*** ACCIÓN REQUERIDA ***${NC}"
    echo -e "${YELLOW}Se abrirá el instalador de MacPorts. Por favor, sigue los pasos y completa la instalación.${NC}"
    echo -e "${YELLOW}El script se pausará. Cuando el instalador finalice, cierra la ventana y presiona 'Enter' aquí para continuar.${NC}"
    
    # Abrimos el instalador gráfico, que es más robusto y amigable
    open "$PKG_FILENAME"
    read -p ""
    
    echo "Limpiando el archivo de instalación..."
    rm -f "$PKG_FILENAME"
    
    # Añadir MacPorts al PATH de la sesión actual para que los siguientes comandos funcionen
    export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
    
    echo "Actualizando MacPorts por primera vez (esto puede tardar unos minutos)..."
    sudo port selfupdate
else
    echo -e "${GREEN}MacPorts ya está instalado. Actualizando...${NC}"
    export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
    sudo port selfupdate
fi

# --- Paso 3: NTFS-3G y enlace de macFUSE ---
print_header "Paso 3: Instalando NTFS-3G y configurando macFUSE"

# Comprobamos si el port ya está instalado y activo
if ! port -q installed ntfs-3g | grep -q 'ntfs-3g.*@.*active'; then
    echo -e "${YELLOW}NTFS-3G no encontrado. Instalando vía MacPorts...${NC}"
    # Usamos -N (non-interactive) para una instalación sin interrupciones.
    # Esto instalará ntfs-3g y su dependencia, macfuse.
    sudo port -N install ntfs-3g
else
    echo -e "${GREEN}NTFS-3G ya está instalado y activo. Saltando este paso.${NC}"
fi

# --- Creación del Enlace Simbólico para macFUSE ---
# Este paso es crucial y asume que el usuario ha desactivado SIP si es necesario.
FUSE_LINK_TARGET="/opt/local/Library/Filesystems/macfuse.fs"
FUSE_LINK_DEST="/Library/Filesystems/macfuse.fs"

echo "Creando el enlace simbólico para que el sistema reconozca a FUSE..."

# -f (fuerza): si el enlace ya existe, lo sobrescribe sin preguntar.
# -s (simbólico): crea un enlace simbólico.
# -n (no-dereference): trata el destino como un archivo normal si es un symlink a un dir.
sudo ln -fsn "$FUSE_LINK_TARGET" "$FUSE_LINK_DEST"

echo -e "${GREEN}Enlace simbólico para macFUSE creado correctamente.${NC}"


# --- Paso 4: Flujo de trabajo de Automator ---
print_header "Paso 4: Copiando el Flujo de Trabajo de Automator"
WORKFLOW_SOURCE="./auto_mount_ntfs.workflow"
WORKFLOW_DEST_DIR="$HOME/Library/Workflows/Applications/Folder Actions"

if [ -d "$WORKFLOW_SOURCE" ]; then
    echo "Copiando '$WORKFLOW_SOURCE' a '$WORKFLOW_DEST_DIR'..."
    mkdir -p "$WORKFLOW_DEST_DIR"
    cp -R "$WORKFLOW_SOURCE" "$WORKFLOW_DEST_DIR/"
else
    echo -e "${RED}Error: No se encontró el directorio 'auto_mount_ntfs.workflow' en la ubicación actual.${NC}"
    exit 1
fi

# --- Paso 5: Registrar y Activar el Flujo de Trabajo (El Hack Atómico) ---
print_header "Paso 5: Activando el Flujo de Trabajo para /Volumes"

WORKFLOW_PATH="$WORKFLOW_DEST_DIR/auto_mount_ntfs.workflow"
WORKFLOW_NAME="auto_mount_ntfs.workflow"

echo "Registrando el workflow con el sistema (puede solicitar permisos de Automatización)..."

RESULT=$(osascript -e '
on run argv
	set workflowPath to item 1 of argv
	set workflowName to item 2 of argv
	
	try
		tell application "System Events"
			local theFolderAction
			
			if not (folder actions enabled) then
				set folder actions enabled to true
			end if
			
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
			
			if theFolderAction is missing value then
				return "Error: No se pudo obtener la referencia a la acción de /Volumes."
			end if
			
			set isAlreadyAttached to false
			try
				if (name of scripts of theFolderAction) contains workflowName then
					set isAlreadyAttached to true
				end if
			on error
			end try
			
			if isAlreadyAttached is false then
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

# Verificamos si la operación fue exitosa
if [[ "$RESULT" == ÉXITO* ]]; then
    echo -e "${GREEN}¡Misión cumplida! El flujo de trabajo está activo para /Volumes.${NC}"
    echo -e "${GREEN}(Respuesta del sistema: $RESULT)${NC}"
else
    echo -e "${RED}Falló la activación del flujo de trabajo.${NC}"
    echo -e "${RED}Respuesta del sistema: $RESULT${NC}"
fi

# --- Finalización ---
print_header "Instalación Completada"
echo -e "${GREEN}El proceso ha finalizado. Se recomienda reiniciar tu Mac para asegurar que todos los cambios surtan efecto.${NC}"
echo -e "${YELLOW}Recuerda que durante la instalación de NTFS-3G (o al conectar un disco por primera vez), es posible que debas ir a 'Ajustes del Sistema > Privacidad y seguridad' para 'Permitir' la extensión de sistema de FUSE o 'Benjamin Fleischer'.${NC}"
echo -e "¡Listo! ✨"