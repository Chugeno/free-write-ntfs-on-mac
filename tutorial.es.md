# Tutorial: VERSIÓN 2 - Habilitar Escritura en Discos NTFS en macOS

Este tutorial detalla cómo instalar y configurar NTFS-3G en macOS para habilitar la escritura en discos con formato NTFS. Esta es la versión 2 del script, que automatiza el proceso de montaje de discos NTFS.

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

## Paso 3: Configurar Sudoers

Para permitir que el script se ejecute sin solicitar una contraseña, necesitas crear o editar el archivo de configuración de sudoers. Sigue estos pasos:

1. Abre la terminal y ejecuta el siguiente comando:
```bash
sudo nano /etc/sudoers.d/ntfs
```

2. Agrega la siguiente línea para permitir que tu usuario ejecute `ntfs-3g` sin necesidad de ingresar la contraseña:
```bash
tu_usuario ALL=(ALL) NOPASSWD: /opt/local/bin/ntfs-3g
```

3. Guarda y cierra el editor (en nano, presiona `Ctrl + X`, luego `Y` y `Enter`).

## Paso 4: Configurar Automator

1. Abre **Automator** en tu Mac.
2. Selecciona **Nueva Acción de Carpeta**.
3. Elige la carpeta `/Volumes/` que se encuentra en el disco principal.
4. Busca **Ejecutar el script Shell** en la biblioteca de acciones y arrástralo al área de trabajo.
5. Pega el siguiente script en el cuadro de texto del script shell:

   [Descargar el script `auto_mount_ntfs.sh`](./auto_mount_ntfs.sh)

6. Guarda la acción de carpeta con un nombre descriptivo, como "Montaje Automático NTFS".

## Paso 5: Disfrutar de la Escritura en tu Disco NTFS

Ahora puedes disfrutar de la escritura en tu disco NTFS en macOS. Cada vez que conectes un disco NTFS, el script se ejecutará automáticamente y montará el disco con soporte de escritura.

## Extra: Montar un Disco NTFS en Particular

Si deseas montar solo un disco NTFS para escribirlo, puedes usar el siguiente comando:

1. Conecta tu disco NTFS al Mac.
2. Verifica el identificador del disco con:
```bash
diskutil list
```
Busca en la lista tu disco NTFS (por ejemplo, /dev/disk4s1).

3. Monta el disco con el siguiente comando:
```bash
sudo /opt/local/bin/ntfs-3g -o auto_xattr /dev/diskXsY /Volumes/NAME -olocal -oallow_other
```
Reemplaza `diskXsY` con el identificador correcto de tu disco y `NAME` con el nombre del disco.

### Explicación del comando:

- `sudo`: Ejecuta el comando con privilegios de administrador.
- `/opt/local/bin/ntfs-3g`: Ruta al ejecutable de NTFS-3G.
- `-o auto_xattr`: Habilita el manejo automático de atributos extendidos (necesario para macOS).
- `/dev/diskXsY`: Reemplaza `diskXsY` con el identificador de tu disco NTFS.
- `/Volumes/NOMBRE`: Reemplaza `NOMBRE` con el nombre que deseas asignar al disco montado.
- `-olocal`: Indica que el disco es un sistema de archivos local.
- `-oallow_other`: Permite que otros usuarios accedan al sistema de archivos.

---

Si necesitas más ajustes o tienes alguna otra solicitud, ¡házmelo saber! Estoy aquí para ayudarte.