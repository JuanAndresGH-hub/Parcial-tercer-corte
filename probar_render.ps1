# ========================================================================
# SCRIPT DE PRUEBA PARA SERVICIOS DESPLEGADOS EN RENDER
# ========================================================================
# INSTRUCCIONES:
# 1. Reemplaza las URLs abajo con las URLs reales de tus servicios en Render
# 2. Ejecuta: .\probar_render.ps1
# ========================================================================

# REEMPLAZA ESTAS URLs CON LAS TUYAS
$baseClientes = "https://barberia-clientes.onrender.com"
$baseBarberos = "https://barberia-barberos.onrender.com"
$baseCitas = "https://barberia-citas.onrender.com"

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "   PROBANDO SERVICIOS EN RENDER" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "URLs configuradas:" -ForegroundColor Yellow
Write-Host "  Clientes: $baseClientes" -ForegroundColor White
Write-Host "  Barberos: $baseBarberos" -ForegroundColor White
Write-Host "  Citas: $baseCitas" -ForegroundColor White
Write-Host ""
Write-Host "NOTA: Los servicios gratuitos de Render se 'duermen' despues de 15 min" -ForegroundColor Gray
Write-Host "      La primera peticion puede tardar 30-60 segundos." -ForegroundColor Gray
Write-Host ""

# ========================================================================
# PASO 1: HEALTH CHECKS
# ========================================================================
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "[1] HEALTH CHECKS - Verificando servicios..." -ForegroundColor Yellow
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Servicio de Clientes..." -ForegroundColor Cyan
try {
    $healthClientes = Invoke-RestMethod "$baseClientes/health" -TimeoutSec 60
    Write-Host "  [OK] Estado: $($healthClientes.status)" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] No responde (puede estar dormido, esperando 40s...)" -ForegroundColor Yellow
    Start-Sleep -Seconds 40
    try {
        $healthClientes = Invoke-RestMethod "$baseClientes/health"
        Write-Host "  [OK] Estado: $($healthClientes.status)" -ForegroundColor Green
    } catch {
        Write-Host "  [ERROR] Servicio no disponible" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Servicio de Barberos..." -ForegroundColor Cyan
try {
    $healthBarberos = Invoke-RestMethod "$baseBarberos/health" -TimeoutSec 60
    Write-Host "  [OK] Estado: $($healthBarberos.status)" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] No responde (esperando 40s...)" -ForegroundColor Yellow
    Start-Sleep -Seconds 40
    try {
        $healthBarberos = Invoke-RestMethod "$baseBarberos/health"
        Write-Host "  [OK] Estado: $($healthBarberos.status)" -ForegroundColor Green
    } catch {
        Write-Host "  [ERROR] Servicio no disponible" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Servicio de Citas..." -ForegroundColor Cyan
try {
    $healthCitas = Invoke-RestMethod "$baseCitas/health" -TimeoutSec 60
    Write-Host "  [OK] Estado: $($healthCitas.status)" -ForegroundColor Green
} catch {
    Write-Host "  [ERROR] No responde (esperando 40s...)" -ForegroundColor Yellow
    Start-Sleep -Seconds 40
    try {
        $healthCitas = Invoke-RestMethod "$baseCitas/health"
        Write-Host "  [OK] Estado: $($healthCitas.status)" -ForegroundColor Green
    } catch {
        Write-Host "  [ERROR] Servicio no disponible" -ForegroundColor Red
    }
}

# ========================================================================
# PASO 2: CREAR CLIENTE
# ========================================================================
Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "[2] CREANDO CLIENTE DE PRUEBA..." -ForegroundColor Yellow
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

$cliente = @{
    nombre = "Cliente Render Test"
    telefono = "3001234567"
    email = "cliente.render@test.com"
} | ConvertTo-Json

try {
    $clienteCreado = Invoke-RestMethod -Uri "$baseClientes/clientes/" -Method Post -Body $cliente -ContentType "application/json"
    Write-Host "[OK] Cliente creado exitosamente:" -ForegroundColor Green
    Write-Host "    ID: $($clienteCreado.id)" -ForegroundColor Cyan
    Write-Host "    Nombre: $($clienteCreado.nombre)" -ForegroundColor White
    Write-Host "    Email: $($clienteCreado.email)" -ForegroundColor White
    $clienteId = $clienteCreado.id
} catch {
    Write-Host "[ERROR] No se pudo crear el cliente" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
}

# ========================================================================
# PASO 3: CREAR BARBERO
# ========================================================================
Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "[3] CREANDO BARBERO DE PRUEBA..." -ForegroundColor Yellow
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

$barbero = @{
    nombre = "Barbero Render Test"
    especialidad = "Cortes modernos"
    telefono = "3109876543"
    activo = $true
} | ConvertTo-Json

try {
    $barberoCreado = Invoke-RestMethod -Uri "$baseBarberos/barberos/" -Method Post -Body $barbero -ContentType "application/json"
    Write-Host "[OK] Barbero creado exitosamente:" -ForegroundColor Green
    Write-Host "    ID: $($barberoCreado.id)" -ForegroundColor Cyan
    Write-Host "    Nombre: $($barberoCreado.nombre)" -ForegroundColor White
    Write-Host "    Especialidad: $($barberoCreado.especialidad)" -ForegroundColor White
    $barberoId = $barberoCreado.id
} catch {
    Write-Host "[ERROR] No se pudo crear el barbero" -ForegroundColor Red
    Write-Host "Error: $_" -ForegroundColor Red
}

# ========================================================================
# PASO 4: CREAR CITA
# ========================================================================
Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "[4] CREANDO CITA DE PRUEBA..." -ForegroundColor Yellow
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

if ($clienteId -and $barberoId) {
    $cita = @"
{
    "cliente_id": $clienteId,
    "barbero_id": $barberoId,
    "fecha": "2025-12-20",
    "hora": "15:00:00",
    "servicio": "Corte de cabello",
    "estado": "confirmada"
}
"@

    try {
        $citaCreada = Invoke-RestMethod -Uri "$baseCitas/citas/" -Method Post -Body $cita -ContentType "application/json"
        Write-Host "[OK] Cita creada exitosamente:" -ForegroundColor Green
        Write-Host "    ID: $($citaCreada.id)" -ForegroundColor Cyan
        Write-Host "    Cliente ID: $($citaCreada.cliente_id)" -ForegroundColor White
        Write-Host "    Barbero ID: $($citaCreada.barbero_id)" -ForegroundColor White
        Write-Host "    Fecha: $($citaCreada.fecha)" -ForegroundColor White
        Write-Host "    Hora: $($citaCreada.hora)" -ForegroundColor White
        Write-Host "    Estado: $($citaCreada.estado)" -ForegroundColor White
    } catch {
        Write-Host "[ERROR] No se pudo crear la cita" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
    }
} else {
    Write-Host "[SKIP] No se pudo crear cita (falta cliente o barbero)" -ForegroundColor Yellow
}

# ========================================================================
# PASO 5: LISTAR DATOS
# ========================================================================
Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "[5] LISTANDO DATOS..." -ForegroundColor Yellow
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Listando clientes..." -ForegroundColor Cyan
try {
    $clientes = Invoke-RestMethod -Uri "$baseClientes/clientes/" -Method Get
    Write-Host "[OK] Total de clientes: $($clientes.Count)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] No se pudo listar clientes" -ForegroundColor Red
}

Write-Host ""
Write-Host "Listando barberos..." -ForegroundColor Cyan
try {
    $barberos = Invoke-RestMethod -Uri "$baseBarberos/barberos/" -Method Get
    Write-Host "[OK] Total de barberos: $($barberos.Count)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] No se pudo listar barberos" -ForegroundColor Red
}

Write-Host ""
Write-Host "Listando citas..." -ForegroundColor Cyan
try {
    $citas = Invoke-RestMethod -Uri "$baseCitas/citas/" -Method Get
    Write-Host "[OK] Total de citas: $($citas.Count)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] No se pudo listar citas" -ForegroundColor Red
}

# ========================================================================
# RESUMEN
# ========================================================================
Write-Host ""
Write-Host "========================================================================" -ForegroundColor Green
Write-Host "   PRUEBA COMPLETADA" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "URLs de documentacion Swagger:" -ForegroundColor Yellow
Write-Host "  Clientes: $baseClientes/docs" -ForegroundColor Cyan
Write-Host "  Barberos: $baseBarberos/docs" -ForegroundColor Cyan
Write-Host "  Citas: $baseCitas/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "TIP: Abre estas URLs en tu navegador para probar interactivamente" -ForegroundColor Gray
Write-Host ""

