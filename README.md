# Proyecto PowerShell

Este proyecto implementa un **sistema administrativo modular en PowerShell** que permite gestionar servicios de Windows, monitorear el sistema y realizar copias de seguridad, todo desde un menú interactivo en consola.

---

## 📂 Estructura del Proyecto


---

## ⚙️ Funcionalidades

### 🔧 Gestión de Servicios
- Listar servicios del sistema
- Agregar, editar y eliminar servicios en seguimiento
- Buscar servicios
- Iniciar, detener o reiniciar servicios
- Registro de acciones en logs

### 📊 Monitoreo del Sistema
- Estado de servicios en seguimiento
- Uso de memoria, disco y CPU
- Procesos con mayor consumo de recursos
- - Registro de acciones en logs

### 💾 Copias de Seguridad
- Crear backups del archivo de servicios en seguimiento
- Restaurar backups
- Listar y eliminar backups
- Backups comprimidos en formato `.zip`
- - Registro de acciones en logs

---

## 📝 Configuración

La configuración se gestiona desde el archivo `Configuracion.csv`:

| Clave                  | Valor                         |
|------------------------|-------------------------------|
| RutaLogs               | logs                          |
| RutaBackups            | backups                       |
| NivelLog               | INFO                          |
| MaxBackups             | 10                            |
| DirectorioServicios    | Servicios-Seguimiento.csv     |

---

## ▶️ Ejecución

1. Asegúrate de ejecutar PowerShell con permisos adecuados.
2. Ejecuta el script principal:
   ```powershell
   .\Menu-.ps1
