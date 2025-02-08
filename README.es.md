# VERSIÓN 2.1 - Instalación Automática y Montaje de Discos NTFS en macOS 🚀

¡Bienvenido a la versión 2.1 de este script! 🎉 Esta actualización automatiza el proceso de instalación de lo necesario para habilitar la escritura en discos NTFS en macOS.

## Pasos Rápidos para Comenzar

1. **Ejecutar el script de instalación:** 
   ```bash
   bash install_ntfs.sh
   ```
2. **Configurar Sudoers:** Permite que el script se ejecute sin solicitar contraseña. (Reemplaza `tu_usuario` con tu nombre de usuario.)
   ```bash
   sudo visudo -f /private/etc/sudoers.d/tu_usuario
   ```
   - Agrega la siguiente línea al archivo:
     ```
     tu_usuario ALL=(ALL) NOPASSWD: /opt/local/bin/ntfs-3g
     ```
   - Guarda y sal del editor.

   - Cambia los permisos del archivo:
     ```bash
     sudo chmod 0440 /private/etc/sudoers.d/tu_usuario
     ```

3. **Edita el script en `Automator`.**

## Tutorial Completo

Puedes ver instrucciones detalladas [aquí](./instalacion_automatica.es.md) 

O si prefieres una instalación manual, consulta [aquí](./instalacion_manual.es.md).

## ¡Colabora! ☕

Si este proyecto te ha sido útil, considera apoyarlo:
- [Buy Me a Coffee](http://buymeacoffee.com/chugeno)
- [Mercado Pago](http://link.mercadopago.com.ar/eugenioazurmendi)

### Versión en Inglés

To read the README in English, click [here](README.md).

¡Gracias por tu apoyo y disfruta de la escritura en tus discos NTFS! 😊