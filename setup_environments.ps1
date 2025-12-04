# Script para configurar entornos virtuales de todos los servicios

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configurando Entornos Virtuales" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$services = @("clientes", "barberos", "citas")

foreach ($service in $services) {
    Write-Host "Configurando servicio: $service" -ForegroundColor Yellow
    Write-Host "-------------------------------------------"

    $servicePath = "services\$service"

    if (Test-Path $servicePath) {
        Push-Location $servicePath

        # Crear entorno virtual si no existe
        if (-not (Test-Path "venv")) {
            Write-Host "  Creando entorno virtual..." -ForegroundColor Gray
            python -m venv venv
            Write-Host "  Entorno virtual creado" -ForegroundColor Green
        } else {
            Write-Host "  Entorno virtual ya existe" -ForegroundColor Green
        }

        # Instalar dependencias
        Write-Host "  Instalando dependencias..." -ForegroundColor Gray
        & ".\venv\Scripts\python.exe" -m pip install --quiet -r requirements.txt
        Write-Host "  Dependencias instaladas" -ForegroundColor Green

        Pop-Location
    } else {
        Write-Host "  No se encontro el directorio $servicePath" -ForegroundColor Red
    }

    Write-Host ""
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Configuracion completada" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Ejecuta: .\start_services.ps1" -ForegroundColor White
Write-Host "  2. O inicia cada servicio manualmente" -ForegroundColor White
Write-Host ""
Write-Host "Para mas informacion, lee: EJECUCION_SIN_DOCKER.md" -ForegroundColor Cyan
Write-Host ""

