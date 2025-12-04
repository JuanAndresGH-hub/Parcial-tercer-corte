import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.main import app
from app.database import Base, get_db
from app.models import Barbero

# Configurar base de datos de prueba en memoria
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture
def db_session():
    """Crear una sesión de base de datos de prueba"""
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)

@pytest.fixture
def client(db_session):
    """Cliente de prueba para FastAPI"""
    def override_get_db():
        try:
            yield db_session
        finally:
            pass

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()

def test_health_check(client):
    """Probar el endpoint de health check"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy", "service": "barberos"}

def test_crear_barbero(client):
    """Probar la creación de un barbero"""
    barbero_data = {
        "nombre": "Carlos Rodríguez",
        "especialidad": "Cortes clásicos",
        "telefono": "3007654321",
        "activo": True
    }
    response = client.post("/barberos/", json=barbero_data)
    assert response.status_code == 201
    data = response.json()
    assert data["nombre"] == barbero_data["nombre"]
    assert data["especialidad"] == barbero_data["especialidad"]
    assert data["telefono"] == barbero_data["telefono"]
    assert "id" in data

def test_listar_barberos(client):
    """Probar el listado de barberos"""
    barberos = [
        {"nombre": "Carlos Rodríguez", "especialidad": "Cortes clásicos", "telefono": "3007654321"},
        {"nombre": "Pedro Martínez", "especialidad": "Barba y bigote", "telefono": "3009876543"}
    ]
    for barbero in barberos:
        client.post("/barberos/", json=barbero)

    response = client.get("/barberos/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 2

def test_listar_barberos_activos(client):
    """Probar el listado de barberos activos solamente"""
    barberos = [
        {"nombre": "Carlos Rodríguez", "especialidad": "Cortes clásicos", "telefono": "3007654321", "activo": True},
        {"nombre": "Pedro Martínez", "especialidad": "Barba y bigote", "telefono": "3009876543", "activo": False}
    ]
    for barbero in barberos:
        client.post("/barberos/", json=barbero)

    response = client.get("/barberos/?activos_solo=true")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["activo"] == True

def test_obtener_barbero(client):
    """Probar obtener un barbero por ID"""
    barbero_data = {
        "nombre": "Carlos Rodríguez",
        "especialidad": "Cortes clásicos",
        "telefono": "3007654321"
    }
    create_response = client.post("/barberos/", json=barbero_data)
    barbero_id = create_response.json()["id"]

    response = client.get(f"/barberos/{barbero_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == barbero_id
    assert data["nombre"] == barbero_data["nombre"]

def test_obtener_barbero_no_existente(client):
    """Probar obtener un barbero que no existe"""
    response = client.get("/barberos/999")
    assert response.status_code == 404
    assert "Barbero no encontrado" in response.json()["detail"]

def test_actualizar_barbero(client):
    """Probar actualizar un barbero"""
    barbero_data = {
        "nombre": "Carlos Rodríguez",
        "especialidad": "Cortes clásicos",
        "telefono": "3007654321"
    }
    create_response = client.post("/barberos/", json=barbero_data)
    barbero_id = create_response.json()["id"]

    update_data = {"especialidad": "Cortes modernos"}
    response = client.put(f"/barberos/{barbero_id}", json=update_data)
    assert response.status_code == 200
    data = response.json()
    assert data["especialidad"] == "Cortes modernos"
    assert data["nombre"] == barbero_data["nombre"]

def test_actualizar_barbero_no_existente(client):
    """Probar actualizar un barbero que no existe"""
    update_data = {"nombre": "Nuevo Nombre"}
    response = client.put("/barberos/999", json=update_data)
    assert response.status_code == 404

def test_eliminar_barbero(client):
    """Probar eliminar un barbero (soft delete)"""
    barbero_data = {
        "nombre": "Carlos Rodríguez",
        "especialidad": "Cortes clásicos",
        "telefono": "3007654321"
    }
    create_response = client.post("/barberos/", json=barbero_data)
    barbero_id = create_response.json()["id"]

    response = client.delete(f"/barberos/{barbero_id}")
    assert response.status_code == 204

    # Verificar que el barbero fue marcado como inactivo
    get_response = client.get(f"/barberos/{barbero_id}")
    assert get_response.status_code == 200
    assert get_response.json()["activo"] == False

def test_eliminar_barbero_no_existente(client):
    """Probar eliminar un barbero que no existe"""
    response = client.delete("/barberos/999")
    assert response.status_code == 404

