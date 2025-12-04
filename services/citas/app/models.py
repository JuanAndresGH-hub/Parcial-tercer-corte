from sqlalchemy import Column, Integer, String, Date, Time, Enum
from .database import Base
import enum

class EstadoCita(str, enum.Enum):
    PENDIENTE = "pendiente"
    CONFIRMADA = "confirmada"
    COMPLETADA = "completada"
    CANCELADA = "cancelada"

class Cita(Base):
    __tablename__ = "citas"

    id = Column(Integer, primary_key=True, index=True)
    cliente_id = Column(Integer, nullable=False)
    barbero_id = Column(Integer, nullable=False)
    fecha = Column(Date, nullable=False)
    hora = Column(Time, nullable=False)
    servicio = Column(String, nullable=False)
    estado = Column(String, default=EstadoCita.PENDIENTE.value)

