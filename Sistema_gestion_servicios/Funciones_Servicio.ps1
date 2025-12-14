# ================== CONFIGURACION LOG ==================
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFile = Join-Path $ScriptPath "/logs/Funciones_Servicio.log"

function Write-Log {
    param(
        [string]$Mensaje,
        [string]$Nivel = "INFO"
    )
    $fecha = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$fecha [$Nivel] $Mensaje"
}

Write-Log "Script iniciado"

# ================== VARIABLES ==================
$ServiciosCSV = "Servicios-Seguimiento.csv"

# ================== FUNCIONES ==================
function Menu-Servicios {
    Write-Log "Acceso al menu de servicios"
    Clear-Host
    Write-Host "====== GESTION DE SERVICIOS ======"
    Write-Host "1. Listar servicios del sistema"
    Write-Host "2. Agregar servicio a seguimiento"
    Write-Host "3. Editar servicio"
    Write-Host "4. Eliminar servicio de seguimiento"
    Write-Host "5. Buscar servicio"
    Write-Host "6. Controlar servicio (iniciar/detener)"
    Write-Host "0. Volver"

    $op = Read-Host "Seleccione una opcion"
    Write-Log "Opcion seleccionada: $op"

    switch($op){
        "1" { Listar-Servicios; Pause; Menu-Servicios }
        "2" { Agregar-Servicio-Seguimiento; Pause; Menu-Servicios }
        "3" { Editar-Servicio; Pause; Menu-Servicios }
        "4" { Eliminar-Servicio; Pause; Menu-Servicios }
        "5" { Buscar-Servicio; Pause; Menu-Servicios }
        "6" { Controlar-Servicio; Pause; Menu-Servicios }
        "0" { Write-Log "Salida al menu principal"; Main-Menu }
        default { Menu-Servicios }
    }
}

function Listar-Servicios {
    Write-Log "Listado de servicios"
    Get-Service | Select Name, DisplayName, Status, StartType | Format-Table
}

function Agregar-Servicio-Seguimiento {
    $nombre = Read-Host "Nombre del servicio"
    Write-Log "Intento de agregar servicio: $nombre"

    $srv = Get-Service -Name $nombre -ErrorAction SilentlyContinue
    if(!$srv){
        Write-Host "Servicio no encontrado."
        Write-Log "Servicio no encontrado: $nombre" "ERROR"
        return
    }

    $obj = [PSCustomObject]@{
        Nombre = $srv.Name
        DisplayName = $srv.DisplayName
        Estado = $srv.Status
        TipoInicio = $srv.StartType
        Descripcion = $srv.Name
        PID = (Get-Process -Name $srv.Name -ErrorAction SilentlyContinue).Id
    }

    $obj | Export-Csv $ServiciosCSV -Append -NoTypeInformation
    Write-Log "Servicio agregado a seguimiento: $nombre"
    Write-Host "Servicio agregado a seguimiento."
}

function Editar-Servicio {
    $nombre = Read-Host "Nombre del servicio a editar"
    Write-Log "Edicion de servicio: $nombre"

    $data = Import-Csv $ServiciosCSV
    $item = $data | Where-Object { $_.Nombre -eq $nombre }

    if(!$item){
        Write-Host "No existe en seguimiento."
        Write-Log "Servicio no encontrado para edicion: $nombre" "ERROR"
        return
    }

    $nuevoDisplay = Read-Host "Nuevo DisplayName ($($item.DisplayName))"
    if($nuevoDisplay){
        $item.DisplayName = $nuevoDisplay
        Write-Log "DisplayName modificado para $nombre"
    }

    $data | Where-Object { $_.Nombre -ne $nombre } |
        Export-Csv $ServiciosCSV -NoTypeInformation

    $item | Export-Csv $ServiciosCSV -Append -NoTypeInformation
    Write-Host "Servicio actualizado."
}

function Eliminar-Servicio {
    $nombre = Read-Host "Nombre del servicio a eliminar"
    Write-Log "Eliminacion de servicio: $nombre"

    Import-Csv $ServiciosCSV |
        Where-Object { $_.Nombre -ne $nombre } |
        Export-Csv $ServiciosCSV -NoTypeInformation

    Write-Host "Servicio eliminado."
}

function Buscar-Servicio {
    $texto = Read-Host "Buscar por texto"
    Write-Log "Busqueda de servicios con texto: $texto"

    Get-Service | Where-Object {
        $_.Status -like "*$texto*" -or
        $_.Name -like "*$texto*" -or
        $_.DisplayName -like "*$texto*"
    } | Format-Table
}

function Controlar-Servicio {
    $nombre = Read-Host "Nombre del servicio"
    Write-Log "Control de servicio: $nombre"

    $srv = Get-Service -Name $nombre -ErrorAction SilentlyContinue
    if(!$srv){
        Write-Host "No existe"
        Write-Log "Servicio no encontrado para control: $nombre" "ERROR"
        return
    }

    Write-Host "Estado actual: $($srv.Status)"
    Write-Host "1. Iniciar"
    Write-Host "2. Detener"
    Write-Host "3. Reiniciar"

    $op = Read-Host "Seleccione"
    Write-Log "Accion seleccionada ($op) para servicio $nombre"

    switch($op){
        "1" { Start-Service $nombre; Write-Log "Servicio iniciado: $nombre"; Write-Host "Iniciado." }
        "2" { Stop-Service $nombre; Write-Log "Servicio detenido: $nombre"; Write-Host "Detenido." }
        "3" { Restart-Service $nombre; Write-Log "Servicio reiniciado: $nombre"; Write-Host "Reiniciado." }
    }
}

