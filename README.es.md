# Escritura Libre en NTFS en Mac 🚀

Este proyecto tiene como objetivo habilitar la escritura en discos NTFS en macOS utilizando NTFS-3G y MacPorts.

## Descripción

Este repositorio contiene un tutorial sobre cómo instalar NTFS-3G y automatizar el montaje de discos NTFS en macOS.

### Pasos Rápidos

1. **Instalar MacPorts**: Visita [MacPorts](https://www.macports.org/) y sigue las instrucciones de instalación.
2. **Instalar NTFS-3G**: Ejecuta el siguiente comando en la terminal:
   ```bash
   sudo port install ntfs-3g
   ```
3. **Montar el Disco NTFS**: Usa el siguiente comando para montar el disco:
   ```bash
   sudo /opt/local/bin/ntfs-3g -o auto_xattr /dev/diskXsY /Volumes/NOMBRE -olocal -oallow_other
   ```
   Reemplaza `diskXsY` con el identificador correcto de tu disco y `NOMBRE` con el punto de montaje deseado.
4. **Automatizar el Montaje**: Crea una aplicación de Automator utilizando el script proporcionado en el tutorial.

### Tutorial Completo

Para instrucciones detalladas, consulta el tutorial completo [aquí](tutorial.es.md). Este tutorial también incluye un script para automatizar el montaje de tu disco NTFS.

### Apoya el Proyecto

Si deseas apoyar este pequeño proyecto, puedes hacerlo aquí:
- [Buy Me a Coffee](http://buymeacoffee.com/chugeno)
- [Mercado Pago](http://link.mercadopago.com.ar/eugenioazurmendi)

### Versión en Inglés

To read the README in English, click [here](README.md).

¡Gracias por revisar este proyecto! Si tienes alguna pregunta o comentario, no dudes en comunicarte. 😊