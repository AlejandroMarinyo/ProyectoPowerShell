# ================== CONFIGURACION LOG ==================
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogDir = Join-Path $ScriptPath "logs"
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

$LogFile = Join-Path $LogDir "Backup.log"

function Write-Log {
    param(
        [string]$Mensaje,
        [string]$Nivel = "INFO"
    )
    $fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$fecha [$Nivel] $Mensaje"
}

Write-Log "Modulo Backup cargado"

# ================== CONFIGURACION ==================
$cfg = Import-Csv "Configuracion.csv"
$RutaBackups = $cfg | Where-Object { $_.Clave -eq "RutaBackups" } | Select-Object -ExpandProperty Valor

# ================== MENU ==================
function Menu-Backup {
    Write-Log "Acceso al menu Backup"
    Clear-Host
    Write-Host "===== SISTEMA DE BACKUPS ====="
    Write-Host "1. Crear backup"
    Write-Host "2. Restaurar backup"
    Write-Host "3. Listar backups"
    Write-Host "4. Eliminar backup"
    Write-Host "0. Volver"

    $op = Read-Host "Seleccione"
    Write-Log "Opcion seleccionada: $op"

    switch ($op) {
        "1" { Crear-Backup; Pause; Menu-Backup }
        "2" { Restaurar-Backup; Pause; Menu-Backup }
        "3" { Listar-Backups; Pause; Menu-Backup }
        "4" { Eliminar-Backup; Pause; Menu-Backup }
        "0" { Write-Log "Salida a menu principal"; Main-Menu }
        default { Menu-Backup }
    }
}

function Crear-Backup {
    try {
        $fecha = Get-Date -Format "yyyyMMdd"
        $nombre = "backup_servicios_$fecha.zip"
        Write-Log "Creando backup: $nombre"
        Compress-Archive -Path "Servicios-Seguimiento.csv" -DestinationPath "$RutaBackups\$nombre" -Force
        Write-Host "Backup creado: $nombre"
        Write-Log "Backup creado correctamente"
    } catch {
        Write-Log "Error al crear backup: $_" "ERROR"
    }
}

function Restaurar-Backup {
    Listar-Backups
    $nombre = Read-Host "Introduce nombre del backup"
    Write-Log "Intento de restaurar backup: $nombre"

    try {
        Expand-Archive "$RutaBackups\$nombre" -DestinationPath "." -Force
        Write-Host "Backup restaurado."
        Write-Log "Backup restaurado correctamente"
    } catch {
        Write-Log "Error al restaurar backup: $_" "ERROR"
    }
}

function Listar-Backups {
    Write-Log "Listado de backups"
    Get-ChildItem $RutaBackups | Select Name, Length, LastWriteTime
}

function Eliminar-Backup {
    Listar-Backups
    $nombre = Read-Host "Eliminar backup"
    Write-Log "Eliminando backup: $nombre"

    try {
        Remove-Item "$RutaBackups\$nombre" -Force
        Write-Host "Backup eliminado."
        Write-Log "Backup eliminado correctamente"
    } catch {
        Write-Log "Error al eliminar backup: $_" "ERROR"
    }
}
