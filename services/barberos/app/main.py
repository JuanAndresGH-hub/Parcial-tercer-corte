from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
import os

from .database import engine, get_db, Base
from .models import Barbero
from .schemas import BarberoCreate, BarberoUpdate, BarberoResponse

# Crear las tablas
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Servicio de Barberos - Barbería",
    description="API para gestionar barberos de la barbería",
    version="1.0.0"
)

@app.get("/health")
def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "barberos"}

@app.get("/barberos/", response_model=List[BarberoResponse])
def listar_barberos(skip: int = 0, limit: int = 100, activos_solo: bool = False, db: Session = Depends(get_db)):
    """Obtener lista de todos los barberos"""
    query = db.query(Barbero)
    if activos_solo:
        query = query.filter(Barbero.activo == True)
    barberos = query.offset(skip).limit(limit).all()
    return barberos

@app.get("/barberos/{barbero_id}", response_model=BarberoResponse)
def obtener_barbero(barbero_id: int, db: Session = Depends(get_db)):
    """Obtener un barbero por su ID"""
    barbero = db.query(Barbero).filter(Barbero.id == barbero_id).first()
    if barbero is None:
        raise HTTPException(status_code=404, detail="Barbero no encontrado")
    return barbero

@app.post("/barberos/", response_model=BarberoResponse, status_code=status.HTTP_201_CREATED)
def crear_barbero(barbero: BarberoCreate, db: Session = Depends(get_db)):
    """Crear un nuevo barbero"""
    nuevo_barbero = Barbero(**barbero.model_dump())
    db.add(nuevo_barbero)
    db.commit()
    db.refresh(nuevo_barbero)
    return nuevo_barbero

@app.put("/barberos/{barbero_id}", response_model=BarberoResponse)
def actualizar_barbero(barbero_id: int, barbero: BarberoUpdate, db: Session = Depends(get_db)):
    """Actualizar un barbero existente"""
    db_barbero = db.query(Barbero).filter(Barbero.id == barbero_id).first()
    if db_barbero is None:
        raise HTTPException(status_code=404, detail="Barbero no encontrado")

    # Actualizar solo los campos proporcionados
    update_data = barbero.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_barbero, field, value)

    db.commit()
    db.refresh(db_barbero)
    return db_barbero

@app.delete("/barberos/{barbero_id}", status_code=status.HTTP_204_NO_CONTENT)
def eliminar_barbero(barbero_id: int, db: Session = Depends(get_db)):
    """Eliminar un barbero (soft delete - marcarlo como inactivo)"""
    db_barbero = db.query(Barbero).filter(Barbero.id == barbero_id).first()
    if db_barbero is None:
        raise HTTPException(status_code=404, detail="Barbero no encontrado")

    # Soft delete: marcar como inactivo en lugar de eliminar
    db_barbero.activo = False
    db.commit()
    return None

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8002))
    uvicorn.run(app, host="0.0.0.0", port=port)

