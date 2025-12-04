import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from datetime import date, time
from unittest.mock import patch, AsyncMock

from app.main import app
from app.database import Base, get_db
from app.models import Cita

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
    assert response.json() == {"status": "healthy", "service": "citas"}

@patch('app.main.verificar_cliente_existe', new_callable=AsyncMock)
@patch('app.main.verificar_barbero_existe', new_callable=AsyncMock)
def test_crear_cita(mock_barbero, mock_cliente, client):
    """Probar la creación de una cita"""
    mock_cliente.return_value = True
    mock_barbero.return_value = True

    cita_data = {
        "cliente_id": 1,
        "barbero_id": 1,
        "fecha": "2025-12-10",
        "hora": "14:00:00",
        "servicio": "Corte de cabello",
        "estado": "pendiente"
    }
    response = client.post("/citas/", json=cita_data)
    assert response.status_code == 201
    data = response.json()
    assert data["cliente_id"] == cita_data["cliente_id"]
    assert data["barbero_id"] == cita_data["barbero_id"]
    assert "id" in data

@patch('app.main.verificar_cliente_existe', new_callable=AsyncMock)
@patch('app.main.verificar_barbero_existe', new_callable=AsyncMock)
def test_crear_cita_conflicto_horario(mock_barbero, mock_cliente, client):
    """Probar que no se pueden crear dos citas en el mismo horario para el mismo barbero"""
    mock_cliente.return_value = True
    mock_barbero.return_value = True

    cita_data = {
        "cliente_id": 1,
        "barbero_id": 1,
        "fecha": "2025-12-10",
        "hora": "14:00:00",
        "servicio": "Corte de cabello"
    }
    client.post("/citas/", json=cita_data)

    # Intentar crear otra cita en el mismo horario
    cita_data2 = {
        "cliente_id": 2,
        "barbero_id": 1,
        "fecha": "2025-12-10",
        "hora": "14:00:00",
        "servicio": "Barba"
    }
    response = client.post("/citas/", json=cita_data2)
    assert response.status_code == 400
    assert "ya tiene una cita en ese horario" in response.json()["detail"]

@patch('app.main.verificar_cliente_existe', new_callable=AsyncMock)
@patch('app.main.verificar_barbero_existe', new_callable=AsyncMock)
def test_listar_citas(mock_barbero, mock_cliente, client):
    """Probar el listado de citas"""
    mock_cliente.return_value = True
    mock_barbero.return_value = True

    citas = [
        {"cliente_id": 1, "barbero_id": 1, "fecha": "2025-12-10", "hora": "14:00:00", "servicio": "Corte"},
        {"cliente_id": 2, "barbero_id": 1, "fecha": "2025-12-10", "hora": "15:00:00", "servicio": "Barba"}
    ]
    for cita in citas:
        client.post("/citas/", json=cita)

    response = client.get("/citas/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 2

@patch('app.main.verificar_cliente_existe', new_callable=AsyncMock)
@patch('app.main.verificar_barbero_existe', new_callable=AsyncMock)
def test_obtener_cita(mock_barbero, mock_cliente, client):
    """Probar obtener una cita por ID"""
    mock_cliente.return_value = True
    mock_barbero.return_value = True

    cita_data = {
        "cliente_id": 1,
        "barbero_id": 1,
        "fecha": "2025-12-10",
        "hora": "14:00:00",
        "servicio": "Corte de cabello"
    }
    create_response = client.post("/citas/", json=cita_data)
    cita_id = create_response.json()["id"]

    response = client.get(f"/citas/{cita_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == cita_id

def test_obtener_cita_no_existente(client):
    """Probar obtener una cita que no existe"""
    response = client.get("/citas/999")
    assert response.status_code == 404

@patch('app.main.verificar_cliente_existe', new_callable=AsyncMock)
@patch('app.main.verificar_barbero_existe', new_callable=AsyncMock)
def test_listar_citas_por_barbero(mock_barbero, mock_cliente, client):
    """Probar listar citas de un barbero específico"""
    mock_cliente.return_value = True
    mock_barbero.return_value = True

    citas = [
        {"cliente_id": 1, "barbero_id": 1, "fecha": "2025-12-10", "hora": "14:00:00", "servicio": "Corte"},
        {"cliente_id": 2, "barbero_id": 2, "fecha": "2025-12-10", "hora": "15:00:00", "servicio": "Barba"}
    ]
    for cita in citas:
        client.post("/citas/", json=cita)

    response = client.get("/citas/barbero/1")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["barbero_id"] == 1

@patch('app.main.verificar_cliente_existe', new_callable=AsyncMock)
@patch('app.main.verificar_barbero_existe', new_callable=AsyncMock)
def test_listar_citas_por_cliente(mock_barbero, mock_cliente, client):
    """Probar listar citas de un cliente específico"""
    mock_cliente.return_value = True
    mock_barbero.return_value = True

    citas = [
        {"cliente_id": 1, "barbero_id": 1, "fecha": "2025-12-10", "hora": "14:00:00", "servicio": "Corte"},
        {"cliente_id": 2, "barbero_id": 1, "fecha": "2025-12-10", "hora": "15:00:00", "servicio": "Barba"}
    ]
    for cita in citas:
        client.post("/citas/", json=cita)

    response = client.get("/citas/cliente/1")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["cliente_id"] == 1

@patch('app.main.verificar_cliente_existe', new_callable=AsyncMock)
@patch('app.main.verificar_barbero_existe', new_callable=AsyncMock)
def test_actualizar_cita(mock_barbero, mock_cliente, client):
    """Probar actualizar una cita"""
    mock_cliente.return_value = True
    mock_barbero.return_value = True

    cita_data = {
        "cliente_id": 1,
        "barbero_id": 1,
        "fecha": "2025-12-10",
        "hora": "14:00:00",
        "servicio": "Corte de cabello"
    }
    create_response = client.post("/citas/", json=cita_data)
    cita_id = create_response.json()["id"]

    update_data = {"estado": "confirmada"}
    response = client.put(f"/citas/{cita_id}", json=update_data)
    assert response.status_code == 200
    data = response.json()
    assert data["estado"] == "confirmada"

@patch('app.main.verificar_cliente_existe', new_callable=AsyncMock)
@patch('app.main.verificar_barbero_existe', new_callable=AsyncMock)
def test_eliminar_cita(mock_barbero, mock_cliente, client):
    """Probar cancelar una cita"""
    mock_cliente.return_value = True
    mock_barbero.return_value = True

    cita_data = {
        "cliente_id": 1,
        "barbero_id": 1,
        "fecha": "2025-12-10",
        "hora": "14:00:00",
        "servicio": "Corte de cabello"
    }
    create_response = client.post("/citas/", json=cita_data)
    cita_id = create_response.json()["id"]

    response = client.delete(f"/citas/{cita_id}")
    assert response.status_code == 204

    # Verificar que la cita fue cancelada
    get_response = client.get(f"/citas/{cita_id}")
    assert get_response.status_code == 200
    assert get_response.json()["estado"] == "cancelada"

