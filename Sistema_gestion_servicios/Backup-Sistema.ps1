$cfg = Import-Csv "Configuracion.csv"
$RutaBackups = $cfg | Where-Object { $_.Clave -eq "RutaBackups" } | Select -Expand Valor

function Menu-Backup {
    Clear-Host
    Write-Host "===== SISTEMA DE BACKUPS ====="
    Write-Host "1. Crear backup"
    Write-Host "2. Restaurar backup"
    Write-Host "3. Listar backups"
    Write-Host "4. Eliminar backup"
    Write-Host "0. Volver"

    $op = Read-Host "Seleccione"
    switch($op){
        "1" { Crear-Backup; Pause; Menu-Backup }
        "2" { Restaurar-Backup; Pause; Menu-Backup }
        "3" { Listar-Backups; Pause; Menu-Backup }
        "4" { Eliminar-Backup; Pause; Menu-Backup }
        "0" { Main-Menu }
        default { Menu-Backup }
    }
}

function Crear-Backup {
    $fecha = Get-Date -Format "yyyyMMdd"
    $nombre = "backup_servicios_$fecha.zip"
    Compress-Archive -Path "Servicios-Seguimiento.csv" -DestinationPath "$RutaBackups\$nombre" -Force
    Write-Host "Backup creado: $nombre"
}

function Restaurar-Backup {
    Listar-Backups
    $nombre = Read-Host "Introduce nombre del backup"
    Expand-Archive "$RutaBackups\$nombre" -DestinationPath "." -Force
    Write-Host "Restaurado."
}

function Listar-Backups {
    Get-ChildItem $RutaBackups | Select Name, Length, LastWriteTime
}

function Eliminar-Backup {
    Listar-Backups
    $nombre = Read-Host "Eliminar backup"
    Remove-Item "$RutaBackups\$nombre"
    Write-Host "Backup eliminado."
}
