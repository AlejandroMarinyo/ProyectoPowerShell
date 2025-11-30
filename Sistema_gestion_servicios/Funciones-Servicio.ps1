$ServiciosCSV = "Servicios-Seguimiento.csv"

function Menu-Servicios {
    Clear-Host
    Write-Host "====== GESTIÓN DE SERVICIOS ======"
    Write-Host "1. Listar servicios del sistema"
    Write-Host "2. Agregar servicio a seguimiento"
    Write-Host "3. Editar servicio"
    Write-Host "4. Eliminar servicio de seguimiento"
    Write-Host "5. Buscar servicio"
    Write-Host "6. Controlar servicio (iniciar/detener)"
    Write-Host "0. Volver"

    $op = Read-Host "Seleccione una opción"
    switch($op){
        "1" { Listar-Servicios; Pause; Menu-Servicios }
        "2" { Agregar-Servicio-Seguimiento; Pause; Menu-Servicios }
        "3" { Editar-Servicio; Pause; Menu-Servicios }
        "4" { Eliminar-Servicio; Pause; Menu-Servicios }
        "5" { Buscar-Servicio; Pause; Menu-Servicios }
        "6" { Controlar-Servicio; Pause; Menu-Servicios }
        "0" { Main-Menu }
        default { Menu-Servicios }
    }
}

function Listar-Servicios {
    Get-Service | Select Name, DisplayName, Status, StartType | Format-Table
}

function Agregar-Servicio-Seguimiento {
    $nombre = Read-Host "Nombre del servicio"
    $srv = Get-Service -Name $nombre -ErrorAction SilentlyContinue
    if(!$srv){ Write-Host "Servicio no encontrado."; return }

    $obj = [PSCustomObject]@{
        Nombre = $srv.Name
        DisplayName = $srv.DisplayName
        Estado = $srv.Status
        TipoInicio = $srv.StartType
        Descripcion = (Get-Service $srv.Name).Name
        PID = (Get-Process -Name $srv.Name -ErrorAction SilentlyContinue).Id
    }
    $obj | Export-Csv $ServiciosCSV -Append -NoTypeInformation
    Write-Host "Servicio añadido a seguimiento."
}

function Editar-Servicio {
    $nombre = Read-Host "Nombre del servicio a editar"

    $data = Import-Csv $ServiciosCSV
    $item = $data | Where-Object { $_.Nombre -eq $nombre }

    if(!$item){ Write-Host "No existe en seguimiento."; return }

    $nuevoDisplay = Read-Host "Nuevo DisplayName ($($item.DisplayName))"
    if($nuevoDisplay){ $item.DisplayName = $nuevoDisplay }

    $data | Where-Object { $_.Nombre -ne $nombre } |
        Export-Csv $ServiciosCSV -NoTypeInformation

    $item | Export-Csv $ServiciosCSV -Append -NoTypeInformation

    Write-Host "Servicio actualizado."
}

function Eliminar-Servicio {
    $nombre = Read-Host "Nombre del servicio a eliminar"
    Import-Csv $ServiciosCSV |
        Where-Object { $_.Nombre -ne $nombre } |
        Export-Csv $ServiciosCSV -NoTypeInformation
    Write-Host "Servicio eliminado."
}

function Buscar-Servicio {
    $texto = Read-Host "Buscar por texto"
    Get-Service | Where-Object {
        $_.Name -like "*$texto*" -or
        $_.DisplayName -like "*$texto*"
    } | Format-Table
}

function Controlar-Servicio {
    $nombre = Read-Host "Nombre del servicio"
    $srv = Get-Service -Name $nombre -ErrorAction SilentlyContinue
    if(!$srv){ Write-Host "No existe"; return }

    Write-Host "Estado actual: $($srv.Status)"
    Write-Host "1. Iniciar"
    Write-Host "2. Detener"
    Write-Host "3. Reiniciar"

    $op = Read-Host "Seleccione"

    switch($op){
        "1" { Start-Service $nombre; Write-Host "Iniciado." }
        "2" { Stop-Service $nombre; Write-Host "Detenido." }
        "3" { Restart-Service $nombre; Write-Host "Reiniciado." }
    }
}
