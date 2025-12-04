#!/bin/bash

# Script para ejecutar todas las pruebas de los microservicios

echo "========================================="
echo "Ejecutando pruebas del proyecto Barbería"
echo "========================================="
echo ""

# Colores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para ejecutar pruebas de un servicio
run_service_tests() {
    service_name=$1
    service_path="services/$service_name"

    echo -e "${YELLOW}Probando servicio: $service_name${NC}"
    echo "-------------------------------------------"

    cd "$service_path" || exit

    # Instalar dependencias si es necesario
    if [ ! -d "venv" ]; then
        echo "Creando entorno virtual..."
        python -m venv venv
    fi

    # Activar entorno virtual
    source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null

    # Instalar dependencias
    pip install -q -r requirements.txt

    # Ejecutar pruebas
    pytest tests/ -v --cov=app --cov-report=term-missing --cov-report=html

    test_result=$?

    # Desactivar entorno virtual
    deactivate

    cd ../..

    if [ $test_result -eq 0 ]; then
        echo -e "${GREEN}✓ Pruebas de $service_name completadas exitosamente${NC}"
    else
        echo -e "${RED}✗ Pruebas de $service_name fallaron${NC}"
        return 1
    fi

    echo ""
    return 0
}

# Ejecutar pruebas para cada servicio
all_passed=true

run_service_tests "clientes" || all_passed=false
run_service_tests "barberos" || all_passed=false
run_service_tests "citas" || all_passed=false

echo "========================================="
if [ "$all_passed" = true ]; then
    echo -e "${GREEN}✓ Todas las pruebas pasaron correctamente${NC}"
    exit 0
else
    echo -e "${RED}✗ Algunas pruebas fallaron${NC}"
    exit 1
fi

