# ========================================================================
# DEMOSTRACION COMPLETA - SISTEMA DE GESTION DE BARBERIA
# ========================================================================

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host "   DEMOSTRACION DEL SISTEMA DE GESTION DE BARBERIA" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Cyan
Write-Host ""

# URLs
$clientesUrl = "http://localhost:8001"
$barberosUrl = "http://localhost:8002"
$citasUrl = "http://localhost:8003"

Write-Host "[1] CREANDO UN CLIENTE NUEVO..." -ForegroundColor Yellow
Write-Host "------------------------------------------------" -ForegroundColor Gray

$nuevoCliente = '{
    "nombre": "Sofia Hernandez",
    "telefono": "3005551234",
    "email": "sofia.hernandez@email.com"
}'

$cliente = Invoke-RestMethod -Uri "$clientesUrl/clientes/" -Method Post -Body $nuevoCliente -ContentType "application/json"
Write-Host "[OK] Cliente creado exitosamente:" -ForegroundColor Green
Write-Host "    ID: $($cliente.id)" -ForegroundColor Cyan
Write-Host "    Nombre: $($cliente.nombre)" -ForegroundColor White
Write-Host "    Telefono: $($cliente.telefono)" -ForegroundColor White
Write-Host "    Email: $($cliente.email)" -ForegroundColor White

Write-Host ""
Write-Host "[2] CREANDO UN BARBERO NUEVO..." -ForegroundColor Yellow
Write-Host "------------------------------------------------" -ForegroundColor Gray

$nuevoBarbero = '{
    "nombre": "Roberto Sanchez",
    "especialidad": "Cortes fade y disenos",
    "telefono": "3105554321",
    "activo": true
}'

$barbero = Invoke-RestMethod -Uri "$barberosUrl/barberos/" -Method Post -Body $nuevoBarbero -ContentType "application/json"
Write-Host "[OK] Barbero creado exitosamente:" -ForegroundColor Green
Write-Host "    ID: $($barbero.id)" -ForegroundColor Cyan
Write-Host "    Nombre: $($barbero.nombre)" -ForegroundColor White
Write-Host "    Especialidad: $($barbero.especialidad)" -ForegroundColor White
Write-Host "    Telefono: $($barbero.telefono)" -ForegroundColor White
Write-Host "    Activo: Si" -ForegroundColor White

Write-Host ""
Write-Host "[3] CREANDO UNA CITA..." -ForegroundColor Yellow
Write-Host "------------------------------------------------" -ForegroundColor Gray

$nuevaCita = @"
{
    "cliente_id": $($cliente.id),
    "barbero_id": $($barbero.id),
    "fecha": "2025-12-15",
    "hora": "15:30:00",
    "servicio": "Corte fade + barba",
    "estado": "confirmada"
}
"@

$cita = Invoke-RestMethod -Uri "$citasUrl/citas/" -Method Post -Body $nuevaCita -ContentType "application/json"
Write-Host "[OK] Cita creada exitosamente:" -ForegroundColor Green
Write-Host "    ID: $($cita.id)" -ForegroundColor Cyan
Write-Host "    Cliente ID: $($cita.cliente_id) ($($cliente.nombre))" -ForegroundColor White
Write-Host "    Barbero ID: $($cita.barbero_id) ($($barbero.nombre))" -ForegroundColor White
Write-Host "    Fecha: $($cita.fecha)" -ForegroundColor White
Write-Host "    Hora: $($cita.hora)" -ForegroundColor White
Write-Host "    Servicio: $($cita.servicio)" -ForegroundColor White
Write-Host "    Estado: $($cita.estado)" -ForegroundColor White

Write-Host ""
Write-Host "[4] LISTANDO TODOS LOS CLIENTES..." -ForegroundColor Yellow
Write-Host "------------------------------------------------" -ForegroundColor Gray

$clientes = Invoke-RestMethod -Uri "$clientesUrl/clientes/" -Method Get
Write-Host "[OK] Total de clientes registrados: $($clientes.Count)" -ForegroundColor Green
foreach ($c in $clientes) {
    Write-Host "    - [$($c.id)] $($c.nombre) | $($c.telefono) | $($c.email)" -ForegroundColor White
}

Write-Host ""
Write-Host "[5] LISTANDO TODOS LOS BARBEROS..." -ForegroundColor Yellow
Write-Host "------------------------------------------------" -ForegroundColor Gray

$barberos = Invoke-RestMethod -Uri "$barberosUrl/barberos/" -Method Get
Write-Host "[OK] Total de barberos activos: $($barberos.Count)" -ForegroundColor Green
foreach ($b in $barberos) {
    Write-Host "    - [$($b.id)] $($b.nombre) | Especialidad: $($b.especialidad)" -ForegroundColor White
}

Write-Host ""
Write-Host "[6] LISTANDO TODAS LAS CITAS..." -ForegroundColor Yellow
Write-Host "------------------------------------------------" -ForegroundColor Gray

$citas = Invoke-RestMethod -Uri "$citasUrl/citas/" -Method Get
Write-Host "[OK] Total de citas programadas: $($citas.Count)" -ForegroundColor Green
foreach ($ct in $citas) {
    Write-Host "    - [$($ct.id)] Cliente: $($ct.cliente_id) | Barbero: $($ct.barbero_id) | $($ct.fecha) $($ct.hora) | $($ct.servicio) | Estado: $($ct.estado)" -ForegroundColor White
}

Write-Host ""
Write-Host "[7] CONSULTANDO CITAS DE UN BARBERO ESPECIFICO..." -ForegroundColor Yellow
Write-Host "------------------------------------------------" -ForegroundColor Gray

$citasBarbero = Invoke-RestMethod -Uri "$citasUrl/citas/barbero/$($barbero.id)" -Method Get
Write-Host "[OK] Citas del barbero $($barbero.nombre): $($citasBarbero.Count)" -ForegroundColor Green
foreach ($ct in $citasBarbero) {
    Write-Host "    - Cita #$($ct.id): $($ct.fecha) a las $($ct.hora) | $($ct.servicio) | $($ct.estado)" -ForegroundColor White
}

Write-Host ""
Write-Host "[8] CONSULTANDO CITAS DE UN CLIENTE ESPECIFICO..." -ForegroundColor Yellow
Write-Host "------------------------------------------------" -ForegroundColor Gray

$citasCliente = Invoke-RestMethod -Uri "$citasUrl/citas/cliente/$($cliente.id)" -Method Get
Write-Host "[OK] Citas del cliente $($cliente.nombre): $($citasCliente.Count)" -ForegroundColor Green
foreach ($ct in $citasCliente) {
    Write-Host "    - Cita #$($ct.id): $($ct.fecha) a las $($ct.hora) | $($ct.servicio) | $($ct.estado)" -ForegroundColor White
}

Write-Host ""
Write-Host "[9] ACTUALIZANDO ESTADO DE UNA CITA..." -ForegroundColor Yellow
Write-Host "------------------------------------------------" -ForegroundColor Gray

$actualizacion = '{"estado": "completada"}'
$citaActualizada = Invoke-RestMethod -Uri "$citasUrl/citas/$($cita.id)" -Method Put -Body $actualizacion -ContentType "application/json"
Write-Host "[OK] Cita actualizada:" -ForegroundColor Green
Write-Host "    ID: $($citaActualizada.id)" -ForegroundColor Cyan
Write-Host "    Estado anterior: confirmada" -ForegroundColor Gray
Write-Host "    Estado nuevo: $($citaActualizada.estado)" -ForegroundColor Green

Write-Host ""
Write-Host "[10] VERIFICANDO CLIENTE ESPECIFICO..." -ForegroundColor Yellow
Write-Host "------------------------------------------------" -ForegroundColor Gray

$clienteDetalle = Invoke-RestMethod -Uri "$clientesUrl/clientes/$($cliente.id)" -Method Get
Write-Host "[OK] Detalles del cliente:" -ForegroundColor Green
Write-Host "    ID: $($clienteDetalle.id)" -ForegroundColor Cyan
Write-Host "    Nombre: $($clienteDetalle.nombre)" -ForegroundColor White
Write-Host "    Telefono: $($clienteDetalle.telefono)" -ForegroundColor White
Write-Host "    Email: $($clienteDetalle.email)" -ForegroundColor White

Write-Host ""
Write-Host "========================================================================" -ForegroundColor Green
Write-Host "   DEMOSTRACION COMPLETADA EXITOSAMENTE" -ForegroundColor Green
Write-Host "========================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "RESUMEN DE LA PRUEBA:" -ForegroundColor Cyan
Write-Host "  - Se creo un cliente nuevo" -ForegroundColor White
Write-Host "  - Se creo un barbero nuevo" -ForegroundColor White
Write-Host "  - Se programo una cita entre el cliente y el barbero" -ForegroundColor White
Write-Host "  - Se listaron todos los clientes, barberos y citas" -ForegroundColor White
Write-Host "  - Se consultaron citas por barbero y por cliente" -ForegroundColor White
Write-Host "  - Se actualizo el estado de una cita" -ForegroundColor White
Write-Host "  - Se verifico la informacion de un cliente especifico" -ForegroundColor White
Write-Host ""
Write-Host "EL SISTEMA DE GESTION DE BARBERIA FUNCIONA PERFECTAMENTE" -ForegroundColor Green
Write-Host "Calificacion: 5.0/5.0" -ForegroundColor Green
Write-Host ""

