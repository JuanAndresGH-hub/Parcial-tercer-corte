from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import os
import httpx
from datetime import date

from .database import engine, get_db, Base
from .models import Cita, EstadoCita
from .schemas import CitaCreate, CitaUpdate, CitaResponse

# Crear las tablas
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Servicio de Citas - Barbería",
    description="API para gestionar citas de la barbería",
    version="1.0.0"
)

# URLs de otros microservicios (pueden configurarse con variables de entorno)
CLIENTES_SERVICE_URL = os.getenv("CLIENTES_SERVICE_URL", "http://clientes:8001")
BARBEROS_SERVICE_URL = os.getenv("BARBEROS_SERVICE_URL", "http://barberos:8002")

@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "citas"}

async def verificar_cliente_existe(cliente_id: int):
    """Verificar si un cliente existe en el servicio de clientes"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{CLIENTES_SERVICE_URL}/clientes/{cliente_id}", timeout=5.0)
            return response.status_code == 200
    except:
        # Si el servicio no está disponible, permitir la operación
        return True

async def verificar_barbero_existe(barbero_id: int):
    """Verificar si un barbero existe en el servicio de barberos"""
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(f"{BARBEROS_SERVICE_URL}/barberos/{barbero_id}", timeout=5.0)
            return response.status_code == 200
    except:
        # Si el servicio no está disponible, permitir la operación
        return True

@app.get("/citas/", response_model=List[CitaResponse])
def listar_citas(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Obtener lista de todas las citas"""
    citas = db.query(Cita).offset(skip).limit(limit).all()
    return citas

@app.get("/citas/{cita_id}", response_model=CitaResponse)
def obtener_cita(cita_id: int, db: Session = Depends(get_db)):
    """Obtener una cita por su ID"""
    cita = db.query(Cita).filter(Cita.id == cita_id).first()
    if cita is None:
        raise HTTPException(status_code=404, detail="Cita no encontrada")
    return cita

@app.get("/citas/barbero/{barbero_id}", response_model=List[CitaResponse])
def listar_citas_por_barbero(barbero_id: int, db: Session = Depends(get_db)):
    """Obtener todas las citas de un barbero específico"""
    citas = db.query(Cita).filter(Cita.barbero_id == barbero_id).all()
    return citas

@app.get("/citas/cliente/{cliente_id}", response_model=List[CitaResponse])
def listar_citas_por_cliente(cliente_id: int, db: Session = Depends(get_db)):
    """Obtener todas las citas de un cliente específico"""
    citas = db.query(Cita).filter(Cita.cliente_id == cliente_id).all()
    return citas

@app.post("/citas/", response_model=CitaResponse, status_code=status.HTTP_201_CREATED)
async def crear_cita(cita: CitaCreate, db: Session = Depends(get_db)):
    """Crear una nueva cita"""
    # Verificar que el cliente exista
    if not await verificar_cliente_existe(cita.cliente_id):
        raise HTTPException(status_code=400, detail="El cliente especificado no existe")

    # Verificar que el barbero exista
    if not await verificar_barbero_existe(cita.barbero_id):
        raise HTTPException(status_code=400, detail="El barbero especificado no existe")

    # Verificar disponibilidad del barbero en esa fecha y hora
    cita_existente = db.query(Cita).filter(
        Cita.barbero_id == cita.barbero_id,
        Cita.fecha == cita.fecha,
        Cita.hora == cita.hora,
        Cita.estado.in_([EstadoCita.PENDIENTE.value, EstadoCita.CONFIRMADA.value])
    ).first()

    if cita_existente:
        raise HTTPException(
            status_code=400,
            detail="El barbero ya tiene una cita en ese horario"
        )

    nueva_cita = Cita(**cita.model_dump())
    db.add(nueva_cita)
    db.commit()
    db.refresh(nueva_cita)
    return nueva_cita

@app.put("/citas/{cita_id}", response_model=CitaResponse)
async def actualizar_cita(cita_id: int, cita: CitaUpdate, db: Session = Depends(get_db)):
    """Actualizar una cita existente"""
    db_cita = db.query(Cita).filter(Cita.id == cita_id).first()
    if db_cita is None:
        raise HTTPException(status_code=404, detail="Cita no encontrada")

    # Actualizar solo los campos proporcionados
    update_data = cita.model_dump(exclude_unset=True)

    # Si se actualiza el cliente, verificar que exista
    if "cliente_id" in update_data:
        if not await verificar_cliente_existe(update_data["cliente_id"]):
            raise HTTPException(status_code=400, detail="El cliente especificado no existe")

    # Si se actualiza el barbero, verificar que exista
    if "barbero_id" in update_data:
        if not await verificar_barbero_existe(update_data["barbero_id"]):
            raise HTTPException(status_code=400, detail="El barbero especificado no existe")

    # Verificar disponibilidad si se cambia fecha, hora o barbero
    if any(k in update_data for k in ["fecha", "hora", "barbero_id"]):
        nueva_fecha = update_data.get("fecha", db_cita.fecha)
        nueva_hora = update_data.get("hora", db_cita.hora)
        nuevo_barbero = update_data.get("barbero_id", db_cita.barbero_id)

        cita_conflicto = db.query(Cita).filter(
            Cita.barbero_id == nuevo_barbero,
            Cita.fecha == nueva_fecha,
            Cita.hora == nueva_hora,
            Cita.id != cita_id,
            Cita.estado.in_([EstadoCita.PENDIENTE.value, EstadoCita.CONFIRMADA.value])
        ).first()

        if cita_conflicto:
            raise HTTPException(
                status_code=400,
                detail="El barbero ya tiene una cita en ese horario"
            )

    for field, value in update_data.items():
        setattr(db_cita, field, value)

    db.commit()
    db.refresh(db_cita)
    return db_cita

@app.delete("/citas/{cita_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_cita(cita_id: int, db: Session = Depends(get_db)):
    """Cancelar una cita (cambiar estado a cancelada)"""
    db_cita = db.query(Cita).filter(Cita.id == cita_id).first()
    if db_cita is None:
        raise HTTPException(status_code=404, detail="Cita no encontrada")

    # Marcar como cancelada en lugar de eliminar
    db_cita.estado = EstadoCita.CANCELADA.value
    db.commit()
    return None

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8003))
    uvicorn.run(app, host="0.0.0.0", port=port)

