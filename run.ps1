# ═══════════════════════════════════════════════════════════════════════════
# 🎯 SCRIPT MAESTRO - Sistema de Gestión de Barbería
# ═══════════════════════════════════════════════════════════════════════════

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("docker", "local", "tests", "help")]
    [string]$Mode = "help"
)

$ErrorActionPreference = "SilentlyContinue"

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                              ║" -ForegroundColor Cyan
    Write-Host "║      💈 SISTEMA DE GESTIÓN DE BARBERÍA - v1.0 💈            ║" -ForegroundColor Green
    Write-Host "║                                                              ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Help {
    Show-Banner
    Write-Host "📋 MODOS DE EJECUCIÓN DISPONIBLES:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1️⃣  DOCKER (Recomendado)" -ForegroundColor Green
    Write-Host "      .\run.ps1 docker" -ForegroundColor Cyan
    Write-Host "      → Inicia Docker Desktop y ejecuta todos los servicios en contenedores" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2️⃣  LOCAL (Sin Docker)" -ForegroundColor Green
    Write-Host "      .\run.ps1 local" -ForegroundColor Cyan
    Write-Host "      → Ejecuta los servicios localmente en entornos virtuales" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3️⃣  TESTS (Pruebas Unitarias)" -ForegroundColor Green
    Write-Host "      .\run.ps1 tests" -ForegroundColor Cyan
    Write-Host "      → Ejecuta los 33 tests unitarios con pytest" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  4️⃣  HELP (Esta ayuda)" -ForegroundColor Green
    Write-Host "      .\run.ps1 help" -ForegroundColor Cyan
    Write-Host "      → Muestra este mensaje de ayuda" -ForegroundColor Gray
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📚 DOCUMENTACIÓN:" -ForegroundColor Yellow
    Write-Host "   • LEEME_PRIMERO.txt - Inicio rápido visual" -ForegroundColor White
    Write-Host "   • SOLUCION_DOCKER.md - Problemas con Docker" -ForegroundColor White
    Write-Host "   • TROUBLESHOOTING.md - Solución de problemas" -ForegroundColor White
    Write-Host "   • EXAMPLES.md - Ejemplos de uso de la API" -ForegroundColor White
    Write-Host ""
}

function Start-DockerMode {
    Show-Banner
    Write-Host "🐳 MODO DOCKER - Iniciando..." -ForegroundColor Green
    Write-Host ""

    # Verificar Docker Desktop instalado
    $dockerPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    if (-not (Test-Path $dockerPath)) {
        Write-Host "❌ Docker Desktop no está instalado" -ForegroundColor Red
        Write-Host ""
        Write-Host "Descárgalo desde: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }

    # Verificar si Docker está corriendo
    Write-Host "🔍 Verificando Docker Desktop..." -ForegroundColor Cyan
    $dockerRunning = docker info 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⏳ Docker Desktop no está corriendo. Iniciando..." -ForegroundColor Yellow
        Start-Process $dockerPath
        Write-Host "   Esperando a que Docker Desktop inicie (30-60 segundos)..." -ForegroundColor Gray

        $maxAttempts = 30
        $attempt = 0
        $dockerReady = $false

        while ($attempt -lt $maxAttempts -and -not $dockerReady) {
            $attempt++
            Start-Sleep -Seconds 2
            $dockerInfo = docker info 2>&1
            if ($LASTEXITCODE -eq 0) {
                $dockerReady = $true
            }
        }

        if (-not $dockerReady) {
            Write-Host "❌ Docker Desktop no responde después de 60 segundos" -ForegroundColor Red
            Write-Host ""
            Write-Host "Por favor:" -ForegroundColor Yellow
            Write-Host "  1. Abre Docker Desktop manualmente" -ForegroundColor White
            Write-Host "  2. Espera a que el ícono esté verde" -ForegroundColor White
            Write-Host "  3. Vuelve a ejecutar: .\run.ps1 docker" -ForegroundColor White
            Write-Host ""
            exit 1
        }
    }

    Write-Host "✅ Docker Desktop está listo" -ForegroundColor Green
    Write-Host ""

    # Mostrar versiones
    Write-Host "📦 Versiones:" -ForegroundColor Cyan
    docker --version
    docker-compose --version
    Write-Host ""

    # Ejecutar docker-compose
    Write-Host "🚀 Construyendo y ejecutando contenedores..." -ForegroundColor Green
    Write-Host "   (Esto puede tomar 3-5 minutos la primera vez)" -ForegroundColor Gray
    Write-Host ""

    docker-compose up --build
}

function Start-LocalMode {
    Show-Banner
    Write-Host "💻 MODO LOCAL - Iniciando..." -ForegroundColor Green
    Write-Host ""

    # Verificar entornos virtuales
    $allEnvsExist = $true
    foreach ($service in @("clientes", "barberos", "citas")) {
        if (-not (Test-Path "services\$service\venv")) {
            Write-Host "⚠️  No se encontró entorno virtual para $service" -ForegroundColor Yellow
            $allEnvsExist = $false
        }
    }

    if (-not $allEnvsExist) {
        Write-Host ""
        Write-Host "🔧 Configurando entornos virtuales..." -ForegroundColor Cyan
        .\setup_environments.ps1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Error al configurar entornos virtuales" -ForegroundColor Red
            exit 1
        }
    }

    Write-Host "✅ Entornos virtuales listos" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Iniciando servicios en ventanas separadas..." -ForegroundColor Green
    Write-Host ""

    .\start_services.ps1
}

function Start-TestsMode {
    Show-Banner
    Write-Host "🧪 MODO TESTS - Ejecutando pruebas..." -ForegroundColor Green
    Write-Host ""

    # Verificar entornos virtuales
    $allEnvsExist = $true
    foreach ($service in @("clientes", "barberos", "citas")) {
        if (-not (Test-Path "services\$service\venv")) {
            Write-Host "⚠️  No se encontró entorno virtual para $service" -ForegroundColor Yellow
            $allEnvsExist = $false
        }
    }

    if (-not $allEnvsExist) {
        Write-Host ""
        Write-Host "🔧 Configurando entornos virtuales primero..." -ForegroundColor Cyan
        .\setup_environments.ps1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Error al configurar entornos virtuales" -ForegroundColor Red
            exit 1
        }
        Write-Host ""
    }

    Write-Host "✅ Ejecutando 33 tests unitarios..." -ForegroundColor Green
    Write-Host ""

    .\run_tests.ps1
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════

switch ($Mode) {
    "docker" {
        Start-DockerMode
    }
    "local" {
        Start-LocalMode
    }
    "tests" {
        Start-TestsMode
    }
    "help" {
        Show-Help
    }
    default {
        Show-Help
    }
}

