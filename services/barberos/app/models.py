from sqlalchemy import Column, Integer, String, Boolean
from .database import Base

class Barbero(Base):
    __tablename__ = "barberos"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    especialidad = Column(String, nullable=False)
    telefono = Column(String, nullable=False)
    activo = Column(Boolean, default=True)

