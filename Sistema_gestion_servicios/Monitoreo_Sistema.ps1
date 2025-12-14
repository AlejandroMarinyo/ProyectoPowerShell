# ================== CONFIGURACION LOG ==================
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogDir = Join-Path $ScriptPath "logs"
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

$LogFile = Join-Path $LogDir "Monitoreo_Sistema.log"

function Write-Log {
    param(
        [string]$Mensaje,
        [string]$Nivel = "INFO"
    )
    $fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$fecha [$Nivel] $Mensaje"
}

Write-Log "Modulo Monitoreo cargado"

# ================== MENU ==================
function Menu-Monitor {
    Write-Log "Acceso al menu Monitoreo"
    Clear-Host
    Write-Host "===== MONITOREO DEL SISTEMA ====="
    Write-Host "1. Estado de servicios en seguimiento"
    Write-Host "2. Uso de recursos del sistema"
    Write-Host "3. Procesos mas consumidores"
    Write-Host "0. Volver"

    $op = Read-Host "Seleccione una opcion"
    Write-Log "Opcion seleccionada: $op"

    switch ($op) {
        "1" { Estado-Servicios; Pause; Menu-Monitor }
        "2" { Uso-Recursos; Pause; Menu-Monitor }
        "3" { Procesos-Altos; Pause; Menu-Monitor }
        "0" { Write-Log "Salida a menu principal"; Main-Menu }
        default { Menu-Monitor }
    }
}

function Estado-Servicios {
    Write-Log "Consulta estado de servicios en seguimiento"
    Import-Csv "Servicios-Seguimiento.csv" | ForEach-Object {
        Get-Service -Name $_.Nombre | Format-Table
    }
}

function Uso-Recursos {
    Write-Log "Consulta uso de recursos del sistema"

    Write-Host "=== MEMORIA ==="
    Get-CimInstance Win32_OperatingSystem |
        Select @{Name="Libre (GB)";Expression={[math]::Round($_.FreePhysicalMemory/1024/1024,2)}},
               @{Name="Total (GB)";Expression={[math]::Round($_.TotalVisibleMemorySize/1024/1024,2)}} |
        Format-Table | Out-Host

    Write-Host "`n=== DISCOS ==="
    Get-CimInstance Win32_LogicalDisk |
        Where-Object { $_.DriveType -eq 3 } |
        Select DeviceID,
               @{Name="Libre (GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
               @{Name="Total (GB)";Expression={[math]::Round($_.Size/1GB,2)}} |
        Format-Table | Out-Host

    Write-Host "`n=== CPU (TOP 10 PROCESOS) ==="
    Get-Process |
        Sort-Object CPU -Descending |
        Select -First 10 Name, CPU |
        Format-Table | Out-Host
}

function Procesos-Altos {
    Write-Log "Listado de procesos de alto consumo"
    Get-Process | Sort-Object CPU -Descending | Select -First 20 | Format-Table
}
