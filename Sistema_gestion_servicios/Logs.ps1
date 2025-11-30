$cfg = Import-Csv "Configuracion.csv"
$RutaLogs = $cfg | Where-Object { $_.Clave -eq "RutaLogs" } | Select -Expand Valor

function Menu-Logs {
    Clear-Host
    Write-Host "===== GESTIÓN DE LOGS ====="
    Write-Host "1. Ver log del sistema"
    Write-Host "2. Ver log de errores"
    Write-Host "0. Volver"

    $op = Read-Host "Seleccione"
    switch($op){
        "1" { Get-Content "$RutaLogs\sistema.log" -ErrorAction SilentlyContinue; Pause; Menu-Logs }
        "2" { Get-Content "$RutaLogs\errores.log" -ErrorAction SilentlyContinue; Pause; Menu-Logs }
        "0" { Main-Menu }
        default { Menu-Logs }
    }
}

function Registrar-Log {
    param(
        [string]$tipo,
        [string]$mensaje
    )

    $fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if($tipo -eq "INFO"){
        Add-Content "$RutaLogs\sistema.log" "$fecha - $mensaje"
    }
    else {
        Add-Content "$RutaLogs\errores.log" "$fecha - $mensaje"
    }
}
