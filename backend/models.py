import uuid
from datetime import datetime
from sqlalchemy import Column, String, Integer, Float, Boolean, JSON, ForeignKey, DateTime
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

def generate_uuid():
    return str(uuid.uuid4())

class RelayState(Base):
    __tablename__ = 'relay_states'
    id = Column(String(36), primary_key=True, default=generate_uuid)
    relay_id = Column(Integer, unique=True, index=True)
    name = Column(String)
    is_on = Column(Boolean, default=False)
    priority = Column(Integer, default=5)
    schedule_time = Column(String, nullable=True)
    last_updated = Column(DateTime, default=datetime.utcnow)

class TelemetryData(Base):
    __tablename__ = 'telemetry_data'
    id = Column(String(36), primary_key=True, default=generate_uuid)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)
    battery_voltage = Column(Float)
    battery_current = Column(Float)
    battery_soc = Column(Float)
    solar_voltage = Column(Float)
    solar_current = Column(Float)
    solar_power = Column(Float)
    grid_voltage = Column(Float)
    load_power = Column(Float)

class AILog(Base):
    __tablename__ = 'ai_logs'
    id = Column(String(36), primary_key=True, default=generate_uuid)
    timestamp = Column(DateTime, default=datetime.utcnow)
    action_type = Column(String) # e.g. "TURN_OFF_RELAY"
    description = Column(String)
    priority_level = Column(Integer)

class SystemSettings(Base):
    __tablename__ = 'system_settings'
    key = Column(String, primary_key=True, index=True)
    value = Column(String)

class User(Base):
    __tablename__ = 'users'
    id = Column(String(36), primary_key=True, default=generate_uuid)
    username = Column(String, unique=True, index=True)
    password = Column(String)
    full_name = Column(String)
    email = Column(String)
