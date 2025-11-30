function Menu-Monitor {
    Clear-Host
    Write-Host "===== MONITOREO DEL SISTEMA ====="
    Write-Host "1. Estado de servicios en seguimiento"
    Write-Host "2. Uso de recursos del sistema"
    Write-Host "3. Procesos mas consumidores"
    Write-Host "4. Ver logs de eventos"
    Write-Host "0. Volver"

    $op = Read-Host "Seleccione una opcion"
    switch($op){
        "1" { Estado-Servicios; Pause; Menu-Monitor }
        "2" { Uso-Recursos; Pause; Menu-Monitor }
        "3" { Procesos-Altos; Pause; Menu-Monitor }
        "4" { Ver-Eventos; Pause; Menu-Monitor }
        "0" { Main-Menu }
        default { Menu-Monitor }
    }
}

function Estado-Servicios {
    Import-Csv "Servicios-Seguimiento.csv" | ForEach-Object {
        Get-Service -Name $_.Nombre | Format-Table
    }
}

function Uso-Recursos {
    Write-Host "Memoria:"
    Get-CimInstance Win32_OperatingSystem | Select FreePhysicalMemory, TotalVisibleMemorySize

    Write-Host "`nDiscos:"
    Get-CimInstance Win32_LogicalDisk | Select DeviceID, FreeSpace, Size

    Write-Host "`nCPU (procesos):"
    Get-Process | Select Name, CPU | Sort CPU -Descending | Select -First 10
}

function Procesos-Altos {
    Get-Process | Sort CPU -Descending | Select -First 20 | Format-Table
}

function Ver-Eventos {
    Get-EventLog -LogName System -Newest 50 | Format-Table
}
