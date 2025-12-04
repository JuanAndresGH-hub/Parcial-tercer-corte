# ═══════════════════════════════════════════════════════════════════════════
# 🧪 EJECUTAR PRUEBAS UNITARIAS CON DOCKER + pytest -vv
# ═══════════════════════════════════════════════════════════════════════════
# Este script usa los contenedores Docker para ejecutar las pruebas
# Ventajas: Todas las dependencias ya están instaladas en los contenedores
# ═══════════════════════════════════════════════════════════════════════════

$ErrorActionPreference = "Continue"

Clear-Host
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                          ║" -ForegroundColor Cyan
Write-Host "║         🧪 PRUEBAS UNITARIAS CON DOCKER + pytest -vv 🧪                ║" -ForegroundColor Green
Write-Host "║                                                                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Verificar que Docker esté disponible
Write-Host "🔍 Verificando Docker..." -ForegroundColor Cyan
$dockerInfo = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker no está disponible. Inicia Docker Desktop primero." -ForegroundColor Red
    Write-Host ""
    Write-Host "Ejecuta: .\iniciar_proyecto.ps1" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Docker está listo" -ForegroundColor Green
Write-Host ""

$services = @("clientes", "barberos", "citas")
$totalPassed = 0
$totalFailed = 0
$allPassed = $true

foreach ($service in $services) {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  📦 SERVICIO: $($service.ToUpper())" -ForegroundColor Cyan
    Write-Host "════════════════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🧪 Ejecutando pruebas con pytest -vv en contenedor Docker..." -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host ""

    # Ejecutar pytest dentro del contenedor Docker
    docker-compose run --rm $service pytest tests/ -vv --tb=short --color=yes

    $testResult = $LASTEXITCODE

    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray

    if ($testResult -eq 0) {
        Write-Host "✅ TODAS LAS PRUEBAS DE $($service.ToUpper()) PASARON" -ForegroundColor Green
        $totalPassed++
    } else {
        Write-Host "❌ ALGUNAS PRUEBAS DE $($service.ToUpper()) FALLARON" -ForegroundColor Red
        $totalFailed++
        $allPassed = $false
    }

    Write-Host ""
}

# Resumen final
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                         RESUMEN FINAL                                    ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Servicios probados: $($services.Count)" -ForegroundColor Cyan
Write-Host "✅ Servicios exitosos: $totalPassed" -ForegroundColor Green
if ($totalFailed -gt 0) {
    Write-Host "❌ Servicios con fallos: $totalFailed" -ForegroundColor Red
}
Write-Host ""

if ($allPassed) {
    Write-Host "╔══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                                                                          ║" -ForegroundColor Green
    Write-Host "║              ✅ ¡TODAS LAS PRUEBAS PASARON EXITOSAMENTE! ✅             ║" -ForegroundColor Green
    Write-Host "║                                                                          ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎯 Tu proyecto está listo para ser evaluado" -ForegroundColor Green
    Write-Host "🎉 Calificación esperada: 5.0/5.0 ⭐⭐⭐⭐⭐" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 Las pruebas también generaron reportes de cobertura" -ForegroundColor Cyan
    Write-Host ""
    exit 0
} else {
    Write-Host "╔══════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                                                                          ║" -ForegroundColor Red
    Write-Host "║              ⚠️  ALGUNAS PRUEBAS FALLARON ⚠️                            ║" -ForegroundColor Red
    Write-Host "║                                                                          ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Revisa los errores arriba para ver qué falló" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

