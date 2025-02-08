# Guía: Habilitar Escritura en Discos NTFS en macOS 
`instalación manual`

Este tutorial detalla cómo instalar y configurar NTFS-3G en macOS para habilitar la escritura en discos con formato NTFS.

## Paso 1: Instalar MacPorts

1. Visita el sitio oficial de MacPorts: [MacPorts](https://www.macports.org/).
2. Descarga el instalador correspondiente a tu versión de macOS.
3. Sigue las instrucciones de instalación en pantalla.

## Paso 2: Instalar NTFS-3G

Una vez que tengas MacPorts instalado, abre una terminal y ejecuta el siguiente comando:
```bash
sudo port install ntfs-3g
```
Este comando instalará NTFS-3G junto con todas sus dependencias.

## Paso 3: Configurar Automator

1. Abre **Automator** en tu Mac.
2. Selecciona **Nueva Acción de Carpeta**.
3. Elige la carpeta `/Volumes/` que se encuentra en el disco principal.
4. Busca **Ejecutar el script Shell** en la biblioteca de acciones y arrástralo al área de trabajo.
5. Pega el siguiente script en el cuadro de texto del script shell:

   Descargar el script [`auto_mount_ntfs.sh`](./auto_mount_ntfs.sh)

6. Guarda la acción de carpeta con un nombre descriptivo, como "auto_mount_ntfs".

## Paso 4: Disfrutar de la Escritura en tu Disco NTFS

Ahora puedes disfrutar de la escritura en tu disco NTFS en macOS. Cada vez que conectes un disco NTFS, el script se ejecutará automáticamente, te pedirá tu contraseña y montará el disco con soporte de escritura.

## Extra: Para No Pedir Contraseña Cada Vez

Revisa el `Paso 2` de [`instalacion_automatica`](./instalacion_automatica.es.md) para que no te pida la contraseña de administrador cada vez que conectas un disco.

## Extra 2: Montar un Disco NTFS en Particular

Si deseas montar solo un disco NTFS para escribirlo, puedes usar el siguiente comando:

1. Conecta tu disco NTFS al Mac.
2. Verifica el identificador del disco con:
```bash
diskutil list
```
Busca en la lista tu disco NTFS (por ejemplo, /dev/disk4s1).

3. Monta el disco con el siguiente comando:
```bash
sudo /opt/local/bin/ntfs-3g -o auto_xattr,big_writes,local,allow_other /dev/diskXsY /Volumes/NAME
```
Reemplaza `diskXsY` con el identificador correcto de tu disco y `NAME` con el nombre del disco.

### Explicación del Comando:

- `sudo`: Ejecuta el comando con privilegios de administrador.
- `/opt/local/bin/ntfs-3g`: Ruta al ejecutable de NTFS-3G.
- `-o auto_xattr`: Habilita el manejo automático de atributos extendidos (necesario para macOS).
- `-local`: Indica que el disco es un sistema de archivos local.
- `-allow_other`: Permite que otros usuarios accedan al sistema de archivos.
- `/dev/diskXsY`: Reemplaza `diskXsY` con el identificador de tu disco NTFS.
- `/Volumes/NOMBRE`: Reemplaza `NOMBRE` con el nombre que deseas asignar al disco montado.


---

Si necesitas más ajustes o tienes alguna otra solicitud, ¡házmelo saber! Estoy aquí para ayudarte.