# Guía: Habilitar Escritura en Discos NTFS en macOS 
`instalación automática`

## Paso 1: Ejecuta el Script

1. **Ejecuta el script de instalación en la terminal**:
   ```bash
   bash install_ntfs.sh
   ```

2. **Confirma que deseas instalar todo.** El script te advertirá sobre lo que se instalará y te pedirá confirmación antes de proceder.

3. **Sigue las instrucciones en pantalla** para instalar las herramientas de línea de comandos de Xcode, MacPorts y NTFS-3G, además de copiar el script para que se ejecute automáticamente al conectar un disco NTFS.

4. **Verifica que la instalación se haya completado correctamente.** Cada vez que conectes un disco NTFS, el script lo detectará, se te pedirá la contraseña de administrador y montará el disco para su escritura con NTFS-3G.

## (Opcional) Paso 2: Configuración para No Pedir Contraseña

Si deseas que no se te pida la contraseña cada vez que conectas un disco NTFS, puedes modificar el archivo `sudoers` de la siguiente manera:

1. **Abre el terminal**.

2. **Ejecuta el siguiente comando para editar el archivo `sudoers`**:
   ```bash
   sudo visudo -f /private/etc/sudoers.d/tu_usuario
   ```
   Reemplaza `tu_usuario` con tu nombre de usuario.

3. **Se abrirá el editor vim.** Presiona la tecla "i" para entrar en modo de inserción.

4. **Agrega la siguiente línea** al archivo:
   ```
   tu_usuario ALL=(ALL) NOPASSWD: /opt/local/bin/ntfs-3g
   ```
   Reemplaza `tu_usuario` con tu nombre de usuario.

5. **Para guardar y salir,** presiona la tecla "esc" y escribe `:wq` (dos puntos, y las teclas `w` y `q`), luego presiona `Enter`.

6. **Cambia los permisos del archivo**:
   ```bash
   sudo chmod 0440 /private/etc/sudoers.d/tu_usuario
   ```

7. **Verifica que no haya errores en la configuración**:
   ```bash
   sudo visudo -c
   ```

## Configuración de Automator

Una vez hecho esto, abre Automator y sigue estos pasos:

1. **Abre el archivo `auto_mount_ntfs.workflow`** ubicado en `Users/tu_usuario/Library/Workflows/Applications/Folder Actions/`. (La carpeta está oculta; puedes presionar las teclas `cmd + shift + .` para mostrar los archivos ocultos).

2. **Comenta la línea** agregando el símbolo `#` al inicio de la línea:
   ```bash
   # PASSWORD=$(osascript -e 'Tell application "System Events" to display dialog "Introduce tu contraseña para continuar:" default answer "" with hidden answer' -e 'text returned of result')
   ```
   Esto evitará que se pida la contraseña al ejecutar el flujo de trabajo.

## Notas

- **Ten cuidado al modificar el archivo `sudoers`,** ya que una configuración incorrecta puede causar problemas de acceso.
- **Asegúrate de que el comando `ntfs-3g` esté correctamente instalado** antes de intentar usarlo sin contraseña.