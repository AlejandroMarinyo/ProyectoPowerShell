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

    Write-Host "=== MEMORIA ==="
    Get-CimInstance Win32_OperatingSystem |
        Select @{Name="Libre (GB)";Expression={[math]::Round($_.FreePhysicalMemory/1024/1024,2)}},
               @{Name="Total (GB)";Expression={[math]::Round($_.TotalVisibleMemorySize/1024/1024,2)}} |
        Format-Table | Out-Host

    Write-Host "`n=== DISCOS ==="
    Get-CimInstance Win32_LogicalDisk |
        Where-Object { $_.DriveType -eq 3 } |  # Solo discos duros
        Select DeviceID,
               @{Name="Libre (GB)";Expression={[math]::Round($_.FreeSpace/1GB,2)}},
               @{Name="Total (GB)";Expression={[math]::Round($_.Size/1GB,2)}} |
        Format-Table | Out-Host

    Write-Host "`n=== CPU (TOP 10 procesos) ==="
    Get-Process |
        Sort-Object CPU -Descending |
        Select -First 10 Name, CPU |
        Format-Table | Out-Host
}




function Procesos-Altos {
    Get-Process | Sort CPU -Descending | Select -First 20 | Format-Table
}

function Ver-Eventos {
    Get-EventLog -LogName System -Newest 50 | Format-Table
}
