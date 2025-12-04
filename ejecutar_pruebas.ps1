# Script para ejecutar pruebas unitarias con Docker
# Ejecuta: .\ejecutar_pruebas.ps1

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   EJECUTANDO PRUEBAS UNITARIAS CON PYTEST -VV" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Servicio de Clientes
Write-Host "1/3 - SERVICIO DE CLIENTES" -ForegroundColor Yellow
Write-Host "--------------------------------------------------------" -ForegroundColor Gray
docker-compose run --rm clientes pytest tests/ -vv --tb=short
$result1 = $LASTEXITCODE
Write-Host ""

# Test 2: Servicio de Barberos
Write-Host "2/3 - SERVICIO DE BARBEROS" -ForegroundColor Yellow
Write-Host "--------------------------------------------------------" -ForegroundColor Gray
docker-compose run --rm barberos pytest tests/ -vv --tb=short
$result2 = $LASTEXITCODE
Write-Host ""

# Test 3: Servicio de Citas
Write-Host "3/3 - SERVICIO DE CITAS" -ForegroundColor Yellow
Write-Host "--------------------------------------------------------" -ForegroundColor Gray
docker-compose run --rm citas pytest tests/ -vv --tb=short
$result3 = $LASTEXITCODE
Write-Host ""

# Resumen
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "   RESUMEN DE PRUEBAS" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

if ($result1 -eq 0) {
    Write-Host "[OK] Clientes:  TODAS LAS PRUEBAS PASARON" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Clientes:  ALGUNAS PRUEBAS FALLARON" -ForegroundColor Red
}

if ($result2 -eq 0) {
    Write-Host "[OK] Barberos:  TODAS LAS PRUEBAS PASARON" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Barberos:  ALGUNAS PRUEBAS FALLARON" -ForegroundColor Red
}

if ($result3 -eq 0) {
    Write-Host "[OK] Citas:     TODAS LAS PRUEBAS PASARON" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Citas:     ALGUNAS PRUEBAS FALLARON" -ForegroundColor Red
}

Write-Host ""

if (($result1 -eq 0) -and ($result2 -eq 0) -and ($result3 -eq 0)) {
    Write-Host "TODAS LAS PRUEBAS PASARON!" -ForegroundColor Green
    Write-Host "Calificacion: 5.0/5.0" -ForegroundColor Green
} else {
    Write-Host "Revisa los errores arriba" -ForegroundColor Yellow
}

Write-Host ""

