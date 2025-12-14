# Carga de modulos
. ./Funciones_Servicio.ps1
. ./Monitoreo_Sistema.ps1
. ./Backup.ps1

function Main-Menu {
    Clear-Host
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host "     SISTEMA ADMINISTRATIVO    " -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host "1. Gestion de Servicios"
    Write-Host "2. Monitoreo del Sistema"
    Write-Host "3. Copias de Seguridad"
    Write-Host "4. Ver la Configuracion"
    Write-Host "0. Salir"

    $op = Read-Host "Seleccione una opcion"

    switch ($op) {
        "1" { Menu-Servicios }
        "2" { Menu-Monitor }
        "3" { Menu-Backup }
        "4" { Ver-Configuracion }
        "0" { exit }
        default { Main-Menu }
    }
}

function Ver-Configuracion {
    Clear-Host
    Write-Host "===== CONFIGURACION DEL SISTEMA =====`n"

    if(Test-Path "Configuracion.csv"){
        Get-Content "Configuracion.csv"
    } else {
        Write-Host "El archivo Configuracion.csv no existe."
    }

    Pause
    Main-Menu
}

Main-Menu
