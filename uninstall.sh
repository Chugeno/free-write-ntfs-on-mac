#!/bin/bash

# --- Script de Desinstalación Flexible ---

# --- Configuración y Colores ---
set -e
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

# --- Definición de las Funciones de Desinstalación ---

uninstall_config() {
    print_header "Paso 1: Eliminando Configuración de Montaje Automático"

    # --- Definir ambas ubicaciones posibles para el servicio ---
    USER_AGENT_LABEL="com.user.automountntfs"
    USER_PLIST_DEST="$HOME/Library/LaunchAgents/${USER_AGENT_LABEL}.plist"
    
    SYSTEM_AGENT_LABEL="com.system.automountntfs"
    SYSTEM_PLIST_DEST="/Library/LaunchDaemons/${SYSTEM_AGENT_LABEL}.plist"

    INSTALL_DIR="$HOME/.ntfs-automount"

    # --- Intentar descargar y eliminar el servicio de usuario ---
    if [ -f "$USER_PLIST_DEST" ]; then
        if launchctl list | grep -q "$USER_AGENT_LABEL"; then
            echo "Deteniendo el servicio de usuario..."
            launchctl unload "$USER_PLIST_DEST"
        fi
        echo "Eliminando archivo de servicio de usuario (.plist)..."
        rm -f "$USER_PLIST_DEST"
    fi

    # --- Intentar descargar y eliminar el servicio de sistema (con sudo) ---
    if [ -f "$SYSTEM_PLIST_DEST" ]; then
        if sudo launchctl list | grep -q "$SYSTEM_AGENT_LABEL"; then
            echo "Deteniendo el servicio de sistema..."
            sudo launchctl unload "$SYSTEM_PLIST_DEST"
        fi
        echo "Eliminando archivo de servicio de sistema (.plist)..."
        sudo rm -f "$SYSTEM_PLIST_DEST"
    fi

    # --- Eliminar el directorio de instalación ---
    if [ -d "$INSTALL_DIR" ]; then
        echo "Eliminando directorio de instalación ($INSTALL_DIR)..."
        rm -rf "$INSTALL_DIR"
    fi
    echo -e "${GREEN}Configuración de montaje eliminada.${NC}"
}

uninstall_sudo_rule() {
    print_header "Paso 2: Eliminando la regla de sudoers"
    SUDOERS_FILE="/etc/sudoers.d/ntfs-no-pass"
    if [ -f "$SUDOERS_FILE" ]; then
        echo "Eliminando regla de sudo para ntfs-3g..."
        sudo rm -f "$SUDOERS_FILE"
        echo -e "${GREEN}Regla de sudoers eliminada.${NC}"
    else
        echo -e "${YELLOW}El archivo de sudoers no fue encontrado.${NC}"
    fi
}

uninstall_packages() {
    print_header "Paso 3: Desinstalando paquetes de MacPorts"
    if command -v port >/dev/null 2>&1; then
        echo "Desinstalando ntfs-3g..."
        sudo port -N uninstall ntfs-3g || echo -e "${YELLOW}ntfs-3g no estaba instalado.${NC}"
        echo "Desinstalando terminal-notifier..."
        sudo port -N uninstall terminal-notifier || echo -e "${YELLOW}terminal-notifier no estaba instalado.${NC}"
        echo -e "${GREEN}Paquetes desinstalados.${NC}"
    else
        echo -e "${YELLOW}MacPorts no está instalado, saltando desinstalación de paquetes.${NC}"
    fi
}

uninstall_macports() {
    print_header "Paso 4: Desinstalando MacPorts por completo"
    if command -v port >/dev/null 2>&1; then
        echo -e "${YELLOW}Desinstalando todos los paquetes restantes...${NC}"
        sudo port -fp uninstall --follow-dependents installed || true
        echo -e "${YELLOW}Eliminando usuarios y grupos de MacPorts...${NC}"
        sudo dscl . -delete /Users/macports 2>/dev/null || true
        sudo dscl . -delete /Groups/macports 2>/dev/null || true
        echo -e "${YELLOW}Eliminando archivos de MacPorts...${NC}"
        sudo rm -rf /opt/local /Applications/DarwinPorts /Applications/MacPorts /Library/LaunchDaemons/org.macports.* /Library/Receipts/DarwinPorts*.pkg /Library/StartupItems/DarwinPortsStartup /Library/Tcl/darwinports1.0 /Library/Tcl/macports1.0 ~/.macports
        echo -e "${GREEN}MacPorts desinstalado.${NC}"
    else
        echo -e "${YELLOW}MacPorts no parece estar instalado.${NC}"
    fi
}

uninstall_fuse_symlink() {
    print_header "Paso 5: Eliminando enlace simbólico de macFUSE"
    FUSE_SYMLINK="/Library/Filesystems/macfuse.fs"
    if [ -L "$FUSE_SYMLINK" ]; then
        sudo rm -f "$FUSE_SYMLINK"
        echo -e "${GREEN}Enlace simbólico de macFUSE eliminado.${NC}"
    else
        echo -e "${YELLOW}El enlace simbólico de macFUSE no fue encontrado.${NC}"
    fi
}

uninstall_xcode_tools() {
    print_header "Paso 6: Desinstalando Xcode Command Line Tools"
    if [ -d "/Library/Developer/CommandLineTools" ]; then
        echo -e "${YELLOW}Eliminando Xcode Command Line Tools...${NC}"
        sudo rm -rf /Library/Developer/CommandLineTools
        echo -e "${GREEN}Xcode Command Line Tools desinstaladas.${NC}"
    else
        echo -e "${YELLOW}Xcode Command Line Tools no están instaladas.${NC}"
    fi
}

show_manual_steps() {
    print_header "Paso 7: Acción Manual Requerida"
    echo -e "${YELLOW}Este script no puede eliminar la extensión de sistema de macFUSE por seguridad.${NC}"
    echo -e "Sigue estos pasos para la desinstalación final:"
    echo -e "1. Descarga el último paquete de macFUSE desde: ${GREEN}https://macfuse.io${NC}"
    echo -e "2. Abre el .dmg y busca la carpeta ${YELLOW}'Extras'${NC}."
    echo -e "3. Ejecuta ${YELLOW}'Uninstall macFUSE'${NC} y sigue las instrucciones."
    echo -e "\nSe recomienda reiniciar el sistema después de este paso."
}

# --- Lógica Principal del Script ---
clear
print_header "Asistente de Desinstalación"
echo -e "Este script puede eliminar la configuración de montaje automático y/o las herramientas instaladas."
echo ""
echo -e "${YELLOW}Por favor, elige una opción:${NC}"
echo "  [1] Desinstalación Parcial: Elimina solamente la configuración de montaje automático. Es la opción más segura y recomendada."
echo "  [2] Desinstalación Completa: Elimina la configuración Y TODAS las herramientas (ntfs-3g, MacPorts, Xcode Tools). Esta acción es destructiva."
echo ""
read -p "Introduce tu elección (1 o 2): " choice

# --- Autenticación Sudo ---
if [[ "$choice" == "1" || "$choice" == "2" ]]; then
    echo -e "\nSe requerirá contraseña de administrador para continuar."
    sudo -v
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
else
    echo -e "${RED}Opción no válida. Saliendo.${NC}"
    exit 1
fi

case "$choice" in
    1)
        print_header "Iniciando Desinstalación Parcial"
        uninstall_config
        uninstall_sudo_rule
        print_header "Desinstalación Parcial Completada"
        echo -e "${GREEN}Se ha eliminado la configuración de montaje automático.${NC}"
        echo -e "Las herramientas como MacPorts y ntfs-3g no han sido modificadas."
        ;;
    2)
        print_header "Iniciando Desinstalación COMPLETA"
        read -p "$(echo -e ${RED}"ADVERTENCIA: Esta acción es irreversible y eliminará MacPorts y Xcode Tools de tu sistema. ¿Estás seguro? (s/N): "${NC})" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Ss]$ ]]; then
            echo "Desinstalación completa cancelada."
            exit 0
        fi
        uninstall_config
        uninstall_sudo_rule
        uninstall_packages
        uninstall_macports
        uninstall_fuse_symlink
        uninstall_xcode_tools
        show_manual_steps
        print_header "Desinstalación Completa Finalizada"
        echo -e "${GREEN}Todas las configuraciones y herramientas han sido eliminadas.${NC}"
        ;;
    *)
        # Este caso ya está cubierto arriba, pero es buena práctica tenerlo.
        echo -e "${RED}Opción no válida. Saliendo.${NC}"
        exit 1
        ;;
esac

echo -e "\n¡Listo! ✨"