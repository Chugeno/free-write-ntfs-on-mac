#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # Sin color

# Advertencia al usuario
echo -e "${YELLOW}Este script instalará las herramientas de línea de comandos de ${GREEN}Xcode, MacPorts y NTFS-3G.${NC}"
echo -e "${YELLOW}También copiará el archivo de Automator al directorio correspondiente.${NC}"
echo -e "${YELLOW}Se requiere la contraseña de administrador para continuar.${NC}"

# Confirmación del usuario
read -p "¿Deseas continuar con la instalación? (Y/n): " -n 1 -r
echo    # Nueva línea
REPLY=${REPLY:-Y}  # Predeterminado a 'Y'
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}Instalación cancelada.${NC}"
    exit 1
fi

# Instalar Xcode Command Line Tools
echo -e "${GREEN}Instalando herramientas de línea de comandos de Xcode...${NC}"
xcode-select --install

# Esperar a que el usuario instale las herramientas de línea de comandos
echo -e "${YELLOW}Por favor, instala las herramientas de línea de comandos de Xcode cuando se te solicite.${NC}"

# Detectar la versión de macOS
OS_VERSION=$(sw_vers -productVersion)
MAJOR_VERSION=$(echo $OS_VERSION | cut -d '.' -f 1)
MINOR_VERSION=$(echo $OS_VERSION | cut -d '.' -f 2)

# Determinar el enlace de MacPorts según la versión de macOS
if [[ "$MAJOR_VERSION" -eq 15 ]]; then
    MACPORTS_URL="https://github.com/macports/macports-base/releases/download/v2.10.5/MacPorts-2.10.5-15-Sequoia.pkg"
elif [[ "$MAJOR_VERSION" -eq 14 ]]; then
    MACPORTS_URL="https://github.com/macports/macports-base/releases/download/v2.10.5/MacPorts-2.10.5-14-Sonoma.pkg"
elif [[ "$MAJOR_VERSION" -eq 13 ]]; then
    MACPORTS_URL="https://github.com/macports/macports-base/releases/download/v2.10.5/MacPorts-2.10.5-13-Ventura.pkg"
elif [[ "$MAJOR_VERSION" -eq 12 ]]; then
    MACPORTS_URL="https://github.com/macports/macports-base/releases/download/v2.10.5/MacPorts-2.10.5-12-Monterey.pkg"
else
    echo -e "${RED}Versión de macOS no soportada. Salida.${NC}"
    exit 1
fi

# Instalar MacPorts
echo -e "${GREEN}Instalando MacPorts desde $MACPORTS_URL...${NC}"
curl -O $MACPORTS_URL
sudo installer -pkg $(basename $MACPORTS_URL) -target /

# Actualizar MacPorts
echo -e "${GREEN}Actualizando MacPorts...${NC}"
sudo port selfupdate

# Instalar NTFS-3G sin interacción
echo -e "${GREEN}Instalando NTFS-3G...${NC}"
echo "y" | sudo port install ntfs-3g

# Copiar el archivo de Automator
echo -e "${GREEN}Copiando el archivo de Automator...${NC}"
cp ./auto_mount_ntfs.workflow ~/Library/Workflows/Applications/Folder\ Actions/

echo -e "${GREEN}Instalación completada. Por favor, verifica que todo esté funcionando correctamente.${NC}"