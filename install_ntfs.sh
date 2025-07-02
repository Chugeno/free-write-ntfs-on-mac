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
echo -e "${YELLOW}Este script instalará las herramientas de línea de comandos de ${GREEN}Xcode, MacPorts y NTFS-3G.${NC}"
echo -e "${YELLOW}También copiará el archivo de Automator al directorio correspondiente.${NC}"
echo -e "${YELLOW}Se requiere la contraseña de administrador para varias operaciones.${NC}"
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
    echo -e "${YELLOW}Por favor, completa la instalación y luego presiona la tecla 'Enter' en esta terminal para continuar.${NC}"
    read -p ""
else
    echo -e "${GREEN}Xcode Command Line Tools ya están instaladas. Saltando este paso.${NC}"
fi

# --- Paso 2: MacPorts ---
print_header "Paso 2: Verificando e Instalando MacPorts"

# CORRECCIÓN: Comprobamos directamente la existencia del archivo en su ruta absoluta.
# Esto no depende del PATH de la sesión actual y es mucho más robusto.
if [ ! -x "/opt/local/bin/port" ]; then
    echo -e "${YELLOW}MacPorts no encontrado. Procediendo con la instalación...${NC}"
    
    # ... (todo el código de descarga e instalación de MacPorts va aquí, sin cambios) ...
    # ...
    # ...

    # IMPORTANTE: Añadir MacPorts al PATH para la sesión actual
    # para que los siguientes comandos del script (como `sudo port ...`) funcionen.
    export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
    
    echo "Actualizando MacPorts por primera vez..."
    sudo port selfupdate
else
    echo -e "${GREEN}MacPorts ya está instalado. Actualizando...${NC}"
    # También añadimos la ruta al PATH aquí, por si el usuario tiene MacPorts
    # instalado pero está en una terminal donde el PATH aún no se ha cargado.
    export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
    sudo port selfupdate
fi

# --- Paso 3: NTFS-3G ---
print_header "Paso 3: Verificando e Instalando NTFS-3G"
if ! port installed ntfs-3g | grep -q 'ntfs-3g.*@.*active'; then
    echo -e "${YELLOW}NTFS-3G no encontrado. Instalando vía MacPorts...${NC}"
    # Usamos -N (non-interactive) que es más robusto que "echo y |"
    sudo port -y install ntfs-3g
else
    echo -e "${GREEN}NTFS-3G ya está instalado y activo. Saltando este paso.${NC}"
fi

# --- Paso 4: Flujo de trabajo de Automator ---
print_header "Paso 4: Copiando el Flujo de Trabajo de Automator"
WORKFLOW_SOURCE="./auto_mount_ntfs.workflow"
WORKFLOW_DEST_DIR="$HOME/Library/Workflows/Applications/Folder Actions"

if [ -d "$WORKFLOW_SOURCE" ]; then
    echo "Copiando '$WORKFLOW_SOURCE' a '$WORKFLOW_DEST_DIR'..."
    # Asegurarse de que el directorio de destino exista
    mkdir -p "$WORKFLOW_DEST_DIR"
    cp -R "$WORKFLOW_SOURCE" "$WORKFLOW_DEST_DIR/"
else
    echo -e "${RED}Error: No se encontró el directorio del flujo de trabajo 'auto_mount_ntfs.workflow' en la ubicación actual.${NC}"
    echo -e "${RED}Asegúrate de que el script se ejecuta desde el mismo directorio que contiene el workflow.${NC}"
    exit 1
fi

# --- Paso 5: Refrescar el servicio de Acciones de Carpeta ---
print_header "Paso 5: Activando el Flujo de Trabajo"

echo "Reiniciando el servicio de Acciones de Carpeta para registrar el nuevo workflow..."

# Asegurarse de que las acciones de carpeta estén habilitadas globalmente
defaults write com.apple.folderitems FolderActionsEnabled -bool true

# Reiniciar el dispatcher para que cargue la nueva acción
killall FolderActionsDispatcher &> /dev/null || true

echo -e "${GREEN}El servicio se ha reiniciado. El workflow debería estar activo.${NC}"

# --- Finalización ---
print_header "Instalación Completada"
echo -e "${GREEN}El proceso ha finalizado. Por favor, reinicia tu Mac para asegurar que todos los cambios surtan efecto, especialmente los relacionados con el montaje de unidades NTFS.${NC}"
echo -e "¡Listo! ✨"