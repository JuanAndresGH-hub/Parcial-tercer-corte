from pydantic import BaseModel
from datetime import date, time
from typing import Optional
from enum import Enum

class EstadoCita(str, Enum):
    PENDIENTE = "pendiente"
    CONFIRMADA = "confirmada"
    COMPLETADA = "completada"
    CANCELADA = "cancelada"

class CitaBase(BaseModel):
    cliente_id: int
    barbero_id: int
    fecha: date
    hora: time
    servicio: str
    estado: EstadoCita = EstadoCita.PENDIENTE

class CitaCreate(CitaBase):
    pass

class CitaUpdate(BaseModel):
    cliente_id: Optional[int] = None
    barbero_id: Optional[int] = None
    fecha: Optional[date] = None
    hora: Optional[time] = None
    servicio: Optional[str] = None
    estado: Optional[EstadoCita] = None

class CitaResponse(CitaBase):
    id: int

    class Config:
        from_attributes = True

