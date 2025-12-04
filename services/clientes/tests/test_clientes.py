import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.main import app
from app.database import Base, get_db
from app.models import Cliente

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
    assert response.json() == {"status": "healthy", "service": "clientes"}

def test_crear_cliente(client):
    """Probar la creación de un cliente"""
    cliente_data = {
        "nombre": "Juan Pérez",
        "telefono": "3001234567",
        "email": "juan@example.com"
    }
    response = client.post("/clientes/", json=cliente_data)
    assert response.status_code == 201
    data = response.json()
    assert data["nombre"] == cliente_data["nombre"]
    assert data["telefono"] == cliente_data["telefono"]
    assert data["email"] == cliente_data["email"]
    assert "id" in data

def test_crear_cliente_email_duplicado(client):
    """Probar que no se puede crear un cliente con email duplicado"""
    cliente_data = {
        "nombre": "Juan Pérez",
        "telefono": "3001234567",
        "email": "juan@example.com"
    }
    client.post("/clientes/", json=cliente_data)
    response = client.post("/clientes/", json=cliente_data)
    assert response.status_code == 400
    assert "email ya está registrado" in response.json()["detail"]

def test_listar_clientes(client):
    """Probar el listado de clientes"""
    # Crear algunos clientes
    clientes = [
        {"nombre": "Juan Pérez", "telefono": "3001234567", "email": "juan@example.com"},
        {"nombre": "María García", "telefono": "3007654321", "email": "maria@example.com"}
    ]
    for cliente in clientes:
        client.post("/clientes/", json=cliente)

    response = client.get("/clientes/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 2

def test_obtener_cliente(client):
    """Probar obtener un cliente por ID"""
    cliente_data = {
        "nombre": "Juan Pérez",
        "telefono": "3001234567",
        "email": "juan@example.com"
    }
    create_response = client.post("/clientes/", json=cliente_data)
    cliente_id = create_response.json()["id"]

    response = client.get(f"/clientes/{cliente_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == cliente_id
    assert data["nombre"] == cliente_data["nombre"]

def test_obtener_cliente_no_existente(client):
    """Probar obtener un cliente que no existe"""
    response = client.get("/clientes/999")
    assert response.status_code == 404
    assert "Cliente no encontrado" in response.json()["detail"]

def test_actualizar_cliente(client):
    """Probar actualizar un cliente"""
    cliente_data = {
        "nombre": "Juan Pérez",
        "telefono": "3001234567",
        "email": "juan@example.com"
    }
    create_response = client.post("/clientes/", json=cliente_data)
    cliente_id = create_response.json()["id"]

    update_data = {"nombre": "Juan Actualizado"}
    response = client.put(f"/clientes/{cliente_id}", json=update_data)
    assert response.status_code == 200
    data = response.json()
    assert data["nombre"] == "Juan Actualizado"
    assert data["telefono"] == cliente_data["telefono"]

def test_actualizar_cliente_no_existente(client):
    """Probar actualizar un cliente que no existe"""
    update_data = {"nombre": "Nuevo Nombre"}
    response = client.put("/clientes/999", json=update_data)
    assert response.status_code == 404

def test_eliminar_cliente(client):
    """Probar eliminar un cliente"""
    cliente_data = {
        "nombre": "Juan Pérez",
        "telefono": "3001234567",
        "email": "juan@example.com"
    }
    create_response = client.post("/clientes/", json=cliente_data)
    cliente_id = create_response.json()["id"]

    response = client.delete(f"/clientes/{cliente_id}")
    assert response.status_code == 204

    # Verificar que el cliente fue eliminado
    get_response = client.get(f"/clientes/{cliente_id}")
    assert get_response.status_code == 404

def test_eliminar_cliente_no_existente(client):
    """Probar eliminar un cliente que no existe"""
    response = client.delete("/clientes/999")
    assert response.status_code == 404

