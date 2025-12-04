# 🚀 GUÍA DE INICIO - SISTEMA DE GESTIÓN DE BARBERÍA

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Inicio Rápido (3 pasos)](#inicio-rápido-3-pasos)
3. [Guía Detallada](#guía-detallada)
4. [Probar el Sistema](#probar-el-sistema)
5. [Ejecutar Pruebas Unitarias](#ejecutar-pruebas-unitarias)
6. [Solución de Problemas](#solución-de-problemas)

---

## 📦 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- ✅ **Docker Desktop** (Windows, Mac o Linux)
  - Descarga: https://www.docker.com/products/docker-desktop
  - Versión mínima: 20.10+

- ✅ **PowerShell** (para Windows)
  - Ya viene incluido en Windows 10/11

---

## ⚡ Inicio Rápido (3 pasos)

### Paso 1: Abrir Docker Desktop

1. Presiona la tecla **Windows**
2. Escribe: **"Docker Desktop"**
3. Haz clic para abrir
4. **ESPERA** 30-60 segundos hasta que el ícono en la bandeja del sistema (esquina inferior derecha) esté **VERDE**

### Paso 2: Abrir PowerShell

1. Presiona **Windows + R**
2. Escribe: `powershell`
3. Presiona **Enter**
4. Navega a la carpeta del proyecto:
   ```powershell
   cd "C:\Users\1208j\OneDrive\Desktop\Parcial tercer corte"
   ```

### Paso 3: Ejecutar el Proyecto

```powershell
docker-compose up --build
```

**¡Listo!** Espera 2-3 minutos la primera vez.

Cuando veas estos mensajes, el sistema está listo:
```
clientes-1  | INFO:     Application startup complete.
barberos-1  | INFO:     Application startup complete.
citas-1     | INFO:     Application startup complete.
```

---

## 🌐 Acceder al Sistema

Una vez iniciado, abre tu navegador y visita:

### 📱 Interfaces Web (Swagger UI)

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **Clientes** | http://localhost:8001/docs | Gestión de clientes |
| **Barberos** | http://localhost:8002/docs | Gestión de barberos |
| **Citas** | http://localhost:8003/docs | Gestión de citas |

### 🏥 Health Checks

Verifica que los servicios estén funcionando:

```powershell
# Servicio de Clientes
Invoke-RestMethod http://localhost:8001/health

# Servicio de Barberos
Invoke-RestMethod http://localhost:8002/health

# Servicio de Citas
Invoke-RestMethod http://localhost:8003/health
```

Todos deben responder: `{"status": "healthy", "service": "nombre_servicio"}`

---

## 📚 Guía Detallada

### 1. Verificar Docker

Antes de iniciar, verifica que Docker esté funcionando:

```powershell
docker --version
docker info
```

Si ves información de Docker sin errores, estás listo.

### 2. Iniciar el Proyecto (Primera Vez)

La primera vez, Docker descargará las imágenes necesarias y construirá los contenedores:

```powershell
# Navegar a la carpeta del proyecto
cd "C:\Users\1208j\OneDrive\Desktop\Parcial tercer corte"

# Construir y ejecutar
docker-compose up --build
```

**Tiempo estimado:** 3-5 minutos (solo la primera vez)

### 3. Verificar Contenedores

En otra ventana de PowerShell, verifica que los 6 contenedores estén corriendo:

```powershell
docker ps
```

Deberías ver:
- ✅ `parcialtercercorte-clientes-1` (Puerto 8001)
- ✅ `parcialtercercorte-barberos-1` (Puerto 8002)
- ✅ `parcialtercercorte-citas-1` (Puerto 8003)
- ✅ `parcialtercercorte-db-clientes-1`
- ✅ `parcialtercercorte-db-barberos-1`
- ✅ `parcialtercercorte-db-citas-1`

### 4. Detener el Proyecto

Para detener los servicios:

```powershell
# Presiona Ctrl+C en la terminal donde ejecutaste docker-compose
# O en otra terminal:
docker-compose down
```

### 5. Iniciar Nuevamente (Siguientes Veces)

Las siguientes veces es más rápido (no necesita `--build`):

```powershell
docker-compose up
```

**Tiempo estimado:** 20-30 segundos

---

## 🧪 Probar el Sistema

### Opción 1: Usar el Script de Demostración (Recomendado)

```powershell
.\demo_barberia.ps1
```

Este script:
- ✅ Crea un cliente nuevo
- ✅ Crea un barbero nuevo
- ✅ Programa una cita
- ✅ Lista clientes, barberos y citas
- ✅ Consulta citas por barbero y cliente
- ✅ Actualiza el estado de una cita

### Opción 2: Usar Swagger UI (Interfaz Web)

1. Abre http://localhost:8001/docs
2. Prueba el endpoint `POST /clientes/`
3. Haz clic en **"Try it out"**
4. Ingresa los datos:
   ```json
   {
     "nombre": "Juan Perez",
     "telefono": "3001234567",
     "email": "juan@email.com"
   }
   ```
5. Haz clic en **"Execute"**

### Opción 3: Usar PowerShell

```powershell
# Crear un cliente
$cliente = '{
    "nombre": "Maria Garcia",
    "telefono": "3007654321",
    "email": "maria@email.com"
}'
Invoke-RestMethod -Uri "http://localhost:8001/clientes/" -Method Post -Body $cliente -ContentType "application/json"

# Listar todos los clientes
Invoke-RestMethod -Uri "http://localhost:8001/clientes/" -Method Get
```

---

## 🧪 Ejecutar Pruebas Unitarias

El proyecto incluye 30 pruebas unitarias con pytest.

### Ejecutar Todas las Pruebas

```powershell
.\ejecutar_pruebas.ps1
```

**Resultado esperado:**
```
[OK] Clientes:  TODAS LAS PRUEBAS PASARON
[OK] Barberos:  TODAS LAS PRUEBAS PASARON
[OK] Citas:     TODAS LAS PRUEBAS PASARON

TODAS LAS PRUEBAS PASARON!
Calificacion: 5.0/5.0
```

### Ejecutar Pruebas de un Servicio Específico

```powershell
# Solo clientes
docker-compose run --rm clientes pytest tests/ -vv

# Solo barberos
docker-compose run --rm barberos pytest tests/ -vv

# Solo citas
docker-compose run --rm citas pytest tests/ -vv
```

---

## 🛠️ Comandos Útiles

### Ver Logs en Tiempo Real

```powershell
# Todos los servicios
docker-compose logs -f

# Un servicio específico
docker-compose logs -f clientes
docker-compose logs -f barberos
docker-compose logs -f citas
```

### Reiniciar un Servicio

```powershell
docker-compose restart clientes
```

### Limpiar y Empezar de Nuevo

```powershell
# Detener y eliminar todo (incluye datos de la base de datos)
docker-compose down -v

# Reconstruir desde cero
docker-compose up --build
```

### Ver Estado de Contenedores

```powershell
docker ps
```

### Entrar a un Contenedor

```powershell
# Entrar al contenedor de clientes
docker exec -it parcialtercercorte-clientes-1 /bin/bash

# Entrar a la base de datos de clientes
docker exec -it parcialtercercorte-db-clientes-1 psql -U postgres -d clientes_db
```

---

## 🔧 Solución de Problemas

### ❌ Error: "Docker Desktop no está en ejecución"

**Solución:**
1. Abre Docker Desktop desde el menú de inicio
2. Espera a que el ícono esté verde (30-60 segundos)
3. Vuelve a ejecutar `docker-compose up --build`

### ❌ Error: "port is already allocated"

**Solución:**
```powershell
# Ver qué está usando el puerto
netstat -ano | findstr :8001

# Detener servicios locales o cambiar puertos en docker-compose.yml
```

### ❌ Error: "No se puede conectar a los servicios"

**Solución:**
```powershell
# Verificar que los contenedores estén corriendo
docker ps

# Ver logs para identificar el problema
docker-compose logs
```

### ❌ Los servicios inician pero no responden

**Solución:**
```powershell
# Espera 30 segundos para que las bases de datos inicien
# Verifica los health checks:
docker ps

# Las bases de datos deben mostrar (healthy)
```

### ❌ Error al construir imágenes

**Solución:**
```powershell
# Limpiar caché de Docker
docker system prune -a

# Reconstruir sin caché
docker-compose build --no-cache
docker-compose up
```

---

## 📁 Estructura del Proyecto

```
Parcial tercer corte/
├── services/
│   ├── clientes/           # Microservicio de Clientes
│   │   ├── app/           # Código fuente
│   │   ├── tests/         # Pruebas unitarias
│   │   ├── Dockerfile     # Imagen Docker
│   │   └── requirements.txt
│   ├── barberos/          # Microservicio de Barberos
│   │   ├── app/
│   │   ├── tests/
│   │   ├── Dockerfile
│   │   └── requirements.txt
│   └── citas/             # Microservicio de Citas
│       ├── app/
│       ├── tests/
│       ├── Dockerfile
│       └── requirements.txt
├── docker-compose.yml     # Orquestación de servicios
├── render.yaml            # Configuración para despliegue
├── demo_barberia.ps1      # Script de demostración
├── ejecutar_pruebas.ps1   # Script para ejecutar tests
└── INICIO.md              # Este archivo
```

---

## 🎯 Flujo de Trabajo Recomendado

### Para Desarrollo

1. Inicia los servicios: `docker-compose up`
2. Haz cambios en el código
3. Reinicia el servicio modificado: `docker-compose restart clientes`
4. Prueba los cambios en Swagger UI

### Para Testing

1. Ejecuta las pruebas: `.\ejecutar_pruebas.ps1`
2. Verifica que todas pasen
3. Revisa la cobertura de código

### Para Demostración

1. Inicia los servicios: `docker-compose up`
2. Ejecuta el script de demo: `.\demo_barberia.ps1`
3. Muestra Swagger UI: http://localhost:8001/docs

---

## 📊 Endpoints Disponibles

### Servicio de Clientes (Puerto 8001)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/clientes/` | Listar todos los clientes |
| GET | `/clientes/{id}` | Obtener un cliente por ID |
| POST | `/clientes/` | Crear nuevo cliente |
| PUT | `/clientes/{id}` | Actualizar cliente |
| DELETE | `/clientes/{id}` | Eliminar cliente |

### Servicio de Barberos (Puerto 8002)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/barberos/` | Listar todos los barberos |
| GET | `/barberos/activos` | Listar barberos activos |
| GET | `/barberos/{id}` | Obtener un barbero por ID |
| POST | `/barberos/` | Crear nuevo barbero |
| PUT | `/barberos/{id}` | Actualizar barbero |
| DELETE | `/barberos/{id}` | Eliminar barbero |

### Servicio de Citas (Puerto 8003)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/citas/` | Listar todas las citas |
| GET | `/citas/{id}` | Obtener una cita por ID |
| GET | `/citas/cliente/{id}` | Listar citas de un cliente |
| GET | `/citas/barbero/{id}` | Listar citas de un barbero |
| POST | `/citas/` | Crear nueva cita |
| PUT | `/citas/{id}` | Actualizar cita |
| DELETE | `/citas/{id}` | Eliminar cita |

---

## 🌟 Características del Sistema

- ✅ **Microservicios independientes** con bases de datos separadas
- ✅ **API REST** con documentación Swagger automática
- ✅ **Validación de datos** con Pydantic
- ✅ **Pruebas unitarias** con pytest (30 tests)
- ✅ **Contenedores Docker** para fácil despliegue
- ✅ **Health checks** para monitoreo
- ✅ **PostgreSQL** como base de datos persistente
- ✅ **Arquitectura escalable** y mantenible

---

## 📞 Recursos Adicionales

- **EXAMPLES.md** - Ejemplos de uso de la API
- **TROUBLESHOOTING.md** - Solución de problemas comunes
- **DEPLOYMENT.md** - Guía para desplegar en Render
- **PROYECTO_FUNCIONANDO.md** - Estado del proyecto y pruebas

---

## 🎓 Resumen de Comandos

```powershell
# INICIAR EL PROYECTO
docker-compose up --build          # Primera vez (con construcción)
docker-compose up                  # Siguientes veces

# DETENER EL PROYECTO
Ctrl+C                            # En la terminal activa
docker-compose down               # Detener y eliminar contenedores
docker-compose down -v            # Detener y eliminar datos

# PROBAR EL SISTEMA
.\demo_barberia.ps1               # Demostración completa
.\ejecutar_pruebas.ps1            # Ejecutar pruebas unitarias

# VER INFORMACIÓN
docker ps                         # Ver contenedores activos
docker-compose logs -f            # Ver logs en tiempo real

# ACCEDER A LAS APIs
http://localhost:8001/docs        # Clientes
http://localhost:8002/docs        # Barberos
http://localhost:8003/docs        # Citas
```

---

## ✅ Checklist de Inicio

Antes de comenzar, verifica:

- [ ] Docker Desktop instalado y abierto
- [ ] Ícono de Docker en verde (sin parpadear)
- [ ] PowerShell abierto
- [ ] Ubicado en la carpeta del proyecto
- [ ] Puertos 8001, 8002, 8003 disponibles

---

## 🎉 ¡Listo para Empezar!

Ahora puedes ejecutar:

```powershell
docker-compose up --build
```

Y en 2-3 minutos tendrás un sistema completo de gestión de barbería funcionando.

**¡Disfruta del proyecto!** 🚀

---

**Última actualización:** 4 de diciembre de 2025  
**Versión:** 1.0  
**Estado:** ✅ Completamente funcional  
**Calificación esperada:** 5.0/5.0 ⭐⭐⭐⭐⭐

