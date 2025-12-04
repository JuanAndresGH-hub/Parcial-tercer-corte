# Script para ejecutar todas las pruebas de los microservicios en Windows

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Ejecutando pruebas del proyecto Barbería" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$services = @("clientes", "barberos", "citas")
$allPassed = $true

foreach ($service in $services) {
    Write-Host "Probando servicio: $service" -ForegroundColor Yellow
    Write-Host "-------------------------------------------"

    $servicePath = "services\$service"

    Push-Location $servicePath

    # Crear entorno virtual si no existe
    if (-not (Test-Path "venv")) {
        Write-Host "Creando entorno virtual..." -ForegroundColor Gray
        python -m venv venv
    }

    # Activar entorno virtual
    & ".\venv\Scripts\Activate.ps1"

    # Instalar dependencias
    Write-Host "Instalando dependencias..." -ForegroundColor Gray
    pip install -q -r requirements.txt

    # Ejecutar pruebas
    Write-Host "Ejecutando pruebas..." -ForegroundColor Gray
    pytest tests/ -v --cov=app --cov-report=term-missing --cov-report=html

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Pruebas de $service completadas exitosamente" -ForegroundColor Green
    } else {
        Write-Host "✗ Pruebas de $service fallaron" -ForegroundColor Red
        $allPassed = $false
    }

    # Desactivar entorno virtual
    deactivate

    Pop-Location
    Write-Host ""
}

Write-Host "=========================================" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "✓ Todas las pruebas pasaron correctamente" -ForegroundColor Green
    exit 0
} else {
    Write-Host "✗ Algunas pruebas fallaron" -ForegroundColor Red
    exit 1
}

