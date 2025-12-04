from pydantic import BaseModel
from typing import Optional

class BarberoBase(BaseModel):
    nombre: str
    especialidad: str
    telefono: str
    activo: bool = True

class BarberoCreate(BarberoBase):
    pass

class BarberoUpdate(BaseModel):
    nombre: Optional[str] = None
    especialidad: Optional[str] = None
    telefono: Optional[str] = None
    activo: Optional[bool] = None

class BarberoResponse(BarberoBase):
    id: int

    class Config:
        from_attributes = True

