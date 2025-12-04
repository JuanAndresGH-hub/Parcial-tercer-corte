# ═══════════════════════════════════════════════════════════════════════════
# 🚀 SCRIPT DE INICIO - Sistema de Gestión de Barbería
# ═══════════════════════════════════════════════════════════════════════════

# Evitar mensajes de advertencia
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"

Clear-Host
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  💈 SISTEMA DE GESTIÓN DE BARBERÍA - INICIANDO... 💈" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# ═══════════════════════════════════════════════════════════════════════════
# PASO 1: Verificar Docker Desktop
# ═══════════════════════════════════════════════════════════════════════════

Write-Host "🔍 Paso 1: Verificando Docker Desktop..." -ForegroundColor Yellow
Write-Host ""

$dockerPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"

if (-not (Test-Path $dockerPath)) {
    Write-Host "❌ ERROR: Docker Desktop no está instalado" -ForegroundColor Red
    Write-Host ""
    Write-Host "📥 SOLUCIÓN:" -ForegroundColor Yellow
    Write-Host "   1. Descarga Docker Desktop desde:" -ForegroundColor White
    Write-Host "      https://www.docker.com/products/docker-desktop" -ForegroundColor Cyan
    Write-Host "   2. Instálalo y reinicia tu computadora" -ForegroundColor White
    Write-Host "   3. Vuelve a ejecutar este script" -ForegroundColor White
    Write-Host ""
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host "   ✅ Docker Desktop está instalado" -ForegroundColor Green
Write-Host ""

# ═══════════════════════════════════════════════════════════════════════════
# PASO 2: Verificar si Docker está corriendo
# ═══════════════════════════════════════════════════════════════════════════

Write-Host "🔍 Paso 2: Verificando si Docker está corriendo..." -ForegroundColor Yellow
Write-Host ""

# Probar conexión con Docker
$dockerRunning = $false
try {
    $null = docker info 2>&1
    if ($LASTEXITCODE -eq 0) {
        $dockerRunning = $true
    }
} catch {
    $dockerRunning = $false
}

if ($dockerRunning) {
    Write-Host "   ✅ Docker Desktop ya está corriendo" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "   ⚠️  Docker Desktop no está corriendo" -ForegroundColor Yellow
    Write-Host "   🚀 Iniciando Docker Desktop..." -ForegroundColor Cyan
    Write-Host ""

    try {
        Start-Process $dockerPath
        Write-Host "   ⏳ Esperando a que Docker Desktop inicie..." -ForegroundColor Yellow
        Write-Host "      (Esto puede tomar 30-60 segundos)" -ForegroundColor Gray
        Write-Host ""

        # Esperar a que Docker esté listo
        $maxWait = 60
        $waited = 0
        $ready = $false

        while ($waited -lt $maxWait -and -not $ready) {
            Start-Sleep -Seconds 2
            $waited += 2

            # Mostrar progreso
            $dots = "." * ($waited / 2)
            Write-Host "`r   Esperando$dots" -NoNewline -ForegroundColor Gray

            try {
                $null = docker info 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $ready = $true
                }
            } catch {
                # Continuar esperando
            }
        }

        Write-Host "`r                                                      " -NoNewline
        Write-Host "`r" -NoNewline

        if ($ready) {
            Write-Host "   ✅ Docker Desktop está listo" -ForegroundColor Green
            Write-Host ""
        } else {
            Write-Host "   ⚠️  Docker Desktop está tardando más de lo esperado" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "📋 ACCIÓN MANUAL REQUERIDA:" -ForegroundColor Yellow
            Write-Host "   1. Verifica que Docker Desktop se haya abierto" -ForegroundColor White
            Write-Host "   2. Mira el ícono de Docker en la bandeja del sistema" -ForegroundColor White
            Write-Host "      (esquina inferior derecha)" -ForegroundColor Gray
            Write-Host "   3. Espera a que el ícono esté VERDE y deje de parpadear" -ForegroundColor White
            Write-Host "   4. Luego presiona Enter para continuar" -ForegroundColor White
            Write-Host ""
            Read-Host "Presiona Enter cuando Docker esté listo"

            # Verificar nuevamente
            try {
                $null = docker info 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-Host ""
                    Write-Host "❌ Docker aún no está listo" -ForegroundColor Red
                    Write-Host ""
                    Write-Host "💡 RECOMENDACIÓN:" -ForegroundColor Yellow
                    Write-Host "   - Abre Docker Desktop manualmente" -ForegroundColor White
                    Write-Host "   - Espera a que termine de iniciar completamente" -ForegroundColor White
                    Write-Host "   - Vuelve a ejecutar este script: .\iniciar_proyecto.ps1" -ForegroundColor Cyan
                    Write-Host ""
                    Read-Host "Presiona Enter para salir"
                    exit 1
                }
            } catch {
                Write-Host ""
                Write-Host "❌ Docker aún no está listo" -ForegroundColor Red
                exit 1
            }
        }
    } catch {
        Write-Host "   ❌ Error al iniciar Docker Desktop" -ForegroundColor Red
        Write-Host "   Error: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "📋 SOLUCIÓN MANUAL:" -ForegroundColor Yellow
        Write-Host "   1. Abre Docker Desktop manualmente desde el menú inicio" -ForegroundColor White
        Write-Host "   2. Espera a que esté completamente iniciado (ícono verde)" -ForegroundColor White
        Write-Host "   3. Vuelve a ejecutar: .\iniciar_proyecto.ps1" -ForegroundColor Cyan
        Write-Host ""
        Read-Host "Presiona Enter para salir"
        exit 1
    }
}

# ═══════════════════════════════════════════════════════════════════════════
# PASO 3: Mostrar información de Docker
# ═══════════════════════════════════════════════════════════════════════════

Write-Host "📦 Paso 3: Información de Docker:" -ForegroundColor Yellow
Write-Host ""

try {
    $dockerVersion = docker --version 2>&1
    Write-Host "   Docker: $dockerVersion" -ForegroundColor Green

    $composeVersion = docker-compose --version 2>&1
    Write-Host "   Docker Compose: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  No se pudo obtener la versión" -ForegroundColor Yellow
}

Write-Host ""

# ═══════════════════════════════════════════════════════════════════════════
# PASO 4: Ejecutar docker-compose
# ═══════════════════════════════════════════════════════════════════════════

Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🚀 CONSTRUYENDO Y EJECUTANDO CONTENEDORES..." -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "⏱️  Primera vez: 3-5 minutos" -ForegroundColor Gray
Write-Host "⏱️  Siguiente vez: 30 segundos" -ForegroundColor Gray
Write-Host ""
Write-Host "📝 Cuando veas 'Application startup complete', accede a:" -ForegroundColor Yellow
Write-Host "   🌐 Clientes: http://localhost:8001/docs" -ForegroundColor Cyan
Write-Host "   🌐 Barberos: http://localhost:8002/docs" -ForegroundColor Cyan
Write-Host "   🌐 Citas:    http://localhost:8003/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Presiona Ctrl+C para detener los servicios" -ForegroundColor Gray
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Dar un segundo para que el usuario lea
Start-Sleep -Seconds 2

# Ejecutar docker-compose
try {
    docker-compose up --build
} catch {
    Write-Host ""
    Write-Host "❌ Error al ejecutar docker-compose" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "📋 POSIBLES SOLUCIONES:" -ForegroundColor Yellow
    Write-Host "   1. Verifica que docker-compose.yml existe" -ForegroundColor White
    Write-Host "   2. Intenta ejecutar manualmente:" -ForegroundColor White
    Write-Host "      docker-compose up --build" -ForegroundColor Cyan
    Write-Host "   3. Consulta TROUBLESHOOTING.md para más ayuda" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  👋 Hasta luego!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

