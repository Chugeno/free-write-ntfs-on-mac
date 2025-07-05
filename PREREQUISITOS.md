# Pre-requisitos de Instalación

> ⚠️ **Importante:** Se recomienda abrir esta guía en un dispositivo secundario (como tu celular) para poder seguir los pasos cómodamente mientras reinicias tu Mac.

Estos pasos son **esenciales** para permitir que el sistema instale y ejecute los drivers necesarios para la escritura en discos NTFS. Solo necesitas realizarlos una vez.

---

### 1. Desactivar la Protección de Integridad del Sistema (SIP)

1.  Apaga completamente tu Mac.
2.  Enciende tu Mac manteniendo presionado el **botón de encendido** hasta que aparezca el menú de opciones de arranque.
3.  Haz clic en **Opciones** y luego en **Continuar**.
4.  Selecciona tu usuario administrador e ingresa tu contraseña si se solicita.
5.  En la barra de menú superior, ve a **Utilidades > Terminal**.
6.  En la ventana de la terminal, ejecuta el siguiente comando:
    ```bash
    csrutil disable
    ```
7.  El sistema te pedirá que escribas el **usuario administrador** y luego ingreses su contraseña para autorizar el cambio.
8.  Una vez confirmado, cierra la ventana de la Terminal.

### 2. Ajustar la Política de Seguridad de Arranque

1.  En el mismo modo de recuperación, ve a **Utilidades > Utilidad de Seguridad de Arranque**.
2.  Selecciona el disco de arranque de tu sistema (normalmente "Macintosh HD").
3.  **Si el disco está protegido con FileVault**, es posible que debas hacer clic en **Desbloquear** e introducir tu contraseña antes de continuar.
4.  Haz clic en el botón **Política de seguridad...**.
5.  Selecciona la opción **Seguridad Reducida**.
6.  Dentro de esta opción, asegúrate de que la casilla **"Permitir la administración remota de extensiones de kernel de desarrolladores identificados"** esté marcada.
7.  Haz clic en **Aceptar** e ingresa tu contraseña si se te solicita.

### 3. Reiniciar el Sistema

1.  Ve al menú de Apple () en la esquina superior izquierda y selecciona **Reiniciar**.

---

Una vez que tu Mac se haya reiniciado, el sistema estará listo. Ahora puedes proceder con la [instalación del script](README.md#instalación).
