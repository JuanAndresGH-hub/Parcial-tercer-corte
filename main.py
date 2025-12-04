# Sistema de Gestión de Barbería - API REST con Microservicios
#
# Este proyecto implementa una arquitectura de microservicios para gestionar
# una barbería, incluyendo clientes, barberos y citas.
#
# Para ejecutar el proyecto:
#   1. Con Docker: docker-compose up --build
#   2. Sin Docker: Ver README.md para instrucciones detalladas
#
# Para ejecutar las pruebas:
#   - Windows: .\run_tests.ps1
#   - Linux/Mac: ./run_tests.sh
#
# Para desplegar en Render:
#   - Ver DEPLOYMENT.md para guía completa
#
# Estructura del proyecto:
#   - services/clientes: Microservicio de gestión de clientes
#   - services/barberos: Microservicio de gestión de barberos
#   - services/citas: Microservicio de gestión de citas
#
# Documentación API:
#   - Clientes: http://localhost:8001/docs
#   - Barberos: http://localhost:8002/docs
#   - Citas: http://localhost:8003/docs

if __name__ == '__main__':
    print("=" * 60)
    print("API REST - Sistema de Gestión de Barbería")
    print("=" * 60)
    print("\n🏗️  Arquitectura de Microservicios\n")
    print("Para ejecutar el proyecto, usa uno de estos comandos:\n")
    print("  Con Docker (Recomendado):")
    print("    docker-compose up --build\n")
    print("  Sin Docker:")
    print("    Ver README.md para instrucciones\n")
    print("📡 Los servicios estarán disponibles en:")
    print("  - Clientes: http://localhost:8001")
    print("  - Barberos: http://localhost:8002")
    print("  - Citas: http://localhost:8003\n")
    print("📚 Documentación Swagger:")
    print("  - http://localhost:8001/docs")
    print("  - http://localhost:8002/docs")
    print("  - http://localhost:8003/docs\n")
    print("🧪 Para ejecutar las pruebas:")
    print("  - Windows: .\\run_tests.ps1")
    print("  - Linux/Mac: ./run_tests.sh\n")
    print("=" * 60)

