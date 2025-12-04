# Script de Ayuda - Muestra como iniciar el proyecto

Clear-Host
Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "   GUIA DE INICIO - SISTEMA DE GESTION DE BARBERIA" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "PASO 1: Verificar Docker Desktop" -ForegroundColor Yellow
Write-Host "--------------------------------------------------------" -ForegroundColor Gray
Write-Host "  Docker Desktop debe estar corriendo (icono verde)" -ForegroundColor White
Write-Host ""

$dockerRunning = $false
try {
    $null = docker info 2>&1
    if ($LASTEXITCODE -eq 0) {
        $dockerRunning = $true
        Write-Host "  [OK] Docker Desktop esta corriendo" -ForegroundColor Green
    }
} catch {}

if (-not $dockerRunning) {
    Write-Host "  [X] Docker Desktop NO esta corriendo" -ForegroundColor Red
    Write-Host "  Abrelo desde el menu de inicio y espera 30-60 segundos" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Luego ejecuta este script nuevamente: .\ayuda.ps1" -ForegroundColor Cyan
    Write-Host ""
    exit
}

Write-Host ""
Write-Host "PASO 2: Iniciar el Proyecto" -ForegroundColor Yellow
Write-Host "--------------------------------------------------------" -ForegroundColor Gray
Write-Host "  Ejecuta el siguiente comando:" -ForegroundColor White
Write-Host ""
Write-Host "    docker-compose up --build" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Primera vez: 3-5 minutos" -ForegroundColor Gray
Write-Host "  Siguientes veces: 30 segundos" -ForegroundColor Gray
Write-Host ""

Write-Host "PASO 3: Acceder al Sistema" -ForegroundColor Yellow
Write-Host "--------------------------------------------------------" -ForegroundColor Gray
Write-Host "  Cuando veas 'Application startup complete', abre:" -ForegroundColor White
Write-Host ""
Write-Host "  Clientes:  http://localhost:8001/docs" -ForegroundColor Cyan
Write-Host "  Barberos:  http://localhost:8002/docs" -ForegroundColor Cyan
Write-Host "  Citas:     http://localhost:8003/docs" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "   COMANDOS UTILES" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Probar el sistema completo:" -ForegroundColor Yellow
Write-Host "  .\demo_barberia.ps1" -ForegroundColor White
Write-Host ""

Write-Host "Ejecutar pruebas unitarias:" -ForegroundColor Yellow
Write-Host "  .\ejecutar_pruebas.ps1" -ForegroundColor White
Write-Host ""

Write-Host "Ver logs en tiempo real:" -ForegroundColor Yellow
Write-Host "  docker-compose logs -f" -ForegroundColor White
Write-Host ""

Write-Host "Detener el proyecto:" -ForegroundColor Yellow
Write-Host "  Presiona Ctrl+C (en la terminal de docker-compose)" -ForegroundColor White
Write-Host "  O ejecuta: docker-compose down" -ForegroundColor White
Write-Host ""

Write-Host "Ver contenedores activos:" -ForegroundColor Yellow
Write-Host "  docker ps" -ForegroundColor White
Write-Host ""

Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "   MAS INFORMACION" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  INICIO.md              - Guia completa paso a paso" -ForegroundColor White
Write-Host "  INICIO_RAPIDO.txt      - Referencia rapida" -ForegroundColor White
Write-Host "  EXAMPLES.md            - Ejemplos de uso de la API" -ForegroundColor White
Write-Host "  TROUBLESHOOTING.md     - Solucion de problemas" -ForegroundColor White
Write-Host "  PROYECTO_FUNCIONANDO.md - Estado y pruebas realizadas" -ForegroundColor White
Write-Host ""

Write-Host "========================================================================" -ForegroundColor Green
Write-Host "   LISTO PARA INICIAR!" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Ejecuta ahora:" -ForegroundColor Yellow
Write-Host "  docker-compose up --build" -ForegroundColor Cyan
Write-Host ""

