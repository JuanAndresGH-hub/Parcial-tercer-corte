# Script para iniciar todos los servicios en ventanas separadas

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Iniciando Microservicios de Barbería" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que los entornos virtuales existan
$allEnvsExist = $true

foreach ($service in @("clientes", "barberos", "citas")) {
    if (-not (Test-Path "services\$service\venv")) {
        Write-Host "✗ No se encontró entorno virtual para $service" -ForegroundColor Red
        $allEnvsExist = $false
    }
}

if (-not $allEnvsExist) {
    Write-Host ""
    Write-Host "Por favor, ejecuta primero: .\setup_environments.ps1" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

Write-Host "Iniciando servicios en ventanas separadas..." -ForegroundColor Yellow
Write-Host ""

# Servicio de Clientes
Write-Host "  → Iniciando servicio de CLIENTES (puerto 8001)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$PWD\services\clientes'; Write-Host 'Servicio de Clientes' -ForegroundColor Green; .\venv\Scripts\Activate.ps1; python -m uvicorn app.main:app --reload --port 8001"
)

Start-Sleep -Seconds 2

# Servicio de Barberos
Write-Host "  → Iniciando servicio de BARBEROS (puerto 8002)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$PWD\services\barberos'; Write-Host 'Servicio de Barberos' -ForegroundColor Green; .\venv\Scripts\Activate.ps1; python -m uvicorn app.main:app --reload --port 8002"
)

Start-Sleep -Seconds 2

# Servicio de Citas
Write-Host "  → Iniciando servicio de CITAS (puerto 8003)..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$PWD\services\citas'; Write-Host 'Servicio de Citas' -ForegroundColor Green; `$env:CLIENTES_SERVICE_URL='http://localhost:8001'; `$env:BARBEROS_SERVICE_URL='http://localhost:8002'; .\venv\Scripts\Activate.ps1; python -m uvicorn app.main:app --reload --port 8003"
)

Start-Sleep -Seconds 3

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "✓ Servicios iniciados correctamente" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Los servicios están corriendo en ventanas separadas:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  📡 Documentación API (Swagger UI):" -ForegroundColor Cyan
Write-Host "     • Clientes: http://localhost:8001/docs" -ForegroundColor White
Write-Host "     • Barberos: http://localhost:8002/docs" -ForegroundColor White
Write-Host "     • Citas:    http://localhost:8003/docs" -ForegroundColor White
Write-Host ""
Write-Host "  🏥 Health Checks:" -ForegroundColor Cyan
Write-Host "     • curl http://localhost:8001/health" -ForegroundColor White
Write-Host "     • curl http://localhost:8002/health" -ForegroundColor White
Write-Host "     • curl http://localhost:8003/health" -ForegroundColor White
Write-Host ""
Write-Host "Para detener los servicios:" -ForegroundColor Yellow
Write-Host "  Presiona Ctrl+C en cada ventana" -ForegroundColor White
Write-Host ""
Write-Host "Para ver ejemplos de uso:" -ForegroundColor Yellow
Write-Host "  Lee el archivo EXAMPLES.md" -ForegroundColor White
Write-Host ""

