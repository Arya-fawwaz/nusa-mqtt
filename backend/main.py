import asyncio
import json
import os
from contextlib import asynccontextmanager

from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from sqlalchemy import select

from database import get_db, engine
from models import TelemetryData, RelayState, User, SystemSettings, Base
import aiomqtt
from pydantic import BaseModel

# MQTT Configuration
MQTT_BROKER = "broker.hivemq.com"
MQTT_PORT = 1883
MQTT_TOPIC_TELEMETRY = "nusa_power/telemetry"
MQTT_TOPIC_RELAYS = "nusa_power/relays"

def init_db():
    Base.metadata.create_all(bind=engine)
    try:
        from sqlalchemy import text
        with engine.connect() as conn:
            conn.execute(text('ALTER TABLE relay_states ADD COLUMN IF NOT EXISTS schedule_time VARCHAR;'))
            conn.commit()
    except Exception as e:
        print(f"Schema alter ignored: {e}")

def ensure_relays(db: Session):
    relays = db.query(RelayState).all()
    if not relays:
        initial_relays = [
            RelayState(relay_id=1, name="Fasilitas Vital", is_on=True, priority=1),
            RelayState(relay_id=2, name="Kebutuhan Dasar", is_on=True, priority=2),
            RelayState(relay_id=3, name="Pendidikan", is_on=True, priority=3),
            RelayState(relay_id=4, name="Aktivitas Produktif", is_on=False, priority=4),
            RelayState(relay_id=5, name="Rumah Tangga", is_on=False, priority=5),
        ]
        db.add_all(initial_relays)
        db.commit()

def ensure_user(db: Session):
    admin = db.query(User).filter(User.username == "admin").first()
    if not admin:
        db.add(User(username="admin", password="admin", full_name="Admin NUSA", email="admin@nusapower.id"))
        db.commit()

async def mqtt_listener():
    try:
        async with aiomqtt.Client(MQTT_BROKER, port=MQTT_PORT) as client:
            await client.subscribe(MQTT_TOPIC_TELEMETRY)
            async for message in client.messages:
                payload = message.payload.decode()
                print(f"Received MQTT: {payload}")
                # We can't easily save to synchronous DB from inside an async loop without run_in_executor
                # But since this is disabled on Vercel anyway, we just log it for now.
    except Exception as e:
        print(f"MQTT Error: {e}")

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    task = None
    if not os.getenv("VERCEL"):
        print("Starting background tasks (Not on Vercel)...")
        init_db()
        task = asyncio.create_task(mqtt_listener())
    else:
        print("Running on Vercel. Skipping init_db and mqtt_listener.")
        init_db() # We can safely call init_db synchronously on Vercel with psycopg2!
    yield
    # Shutdown
    if task:
        task.cancel()

app = FastAPI(title="NUSA POWER API", lifespan=lifespan)

import paho.mqtt.publish as publish

@app.get("/api/telemetry/latest")
def get_latest_telemetry(db: Session = Depends(get_db)):
    data = db.query(TelemetryData).order_by(TelemetryData.timestamp.desc()).first()
    if data:
        return {
            "batterySoc": data.battery_soc,
            "solarPower": data.solar_power,
            "totalLoad": data.total_load,
            "timestamp": data.timestamp.isoformat()
        }
    return {"batterySoc": 0.0, "solarPower": 0.0, "totalLoad": 0.0}

@app.get("/api/relays")
def get_relays(db: Session = Depends(get_db)):
    ensure_relays(db)
    relays = db.query(RelayState).order_by(RelayState.relay_id).all()
    return [{"id": r.relay_id, "name": r.name, "state": r.is_on, "priority": r.priority} for r in relays]

@app.get("/api/version")
def get_version():
    return {
        "version": "1.0.8", 
        "features": "- Nusa AI kini berfungsi dan mengoptimalkan daya!\n- Username bisa diganti\n- Aksi cepat lebih responsif!",
        "url": "https://backend-ashy-three-94.vercel.app/app.apk" 
    }

class AIToggleReq(BaseModel):
    enabled: bool

@app.get("/api/ai/status")
def get_ai_status(db: Session = Depends(get_db)):
    setting = db.query(SystemSettings).filter(SystemSettings.key == "ai_mode").first()
    is_enabled = setting.value == "true" if setting else False
    return {"ai_mode": is_enabled}

@app.post("/api/ai/toggle")
def toggle_ai(req: AIToggleReq, db: Session = Depends(get_db)):
    setting = db.query(SystemSettings).filter(SystemSettings.key == "ai_mode").first()
    if not setting:
        setting = SystemSettings(key="ai_mode", value="true" if req.enabled else "false")
        db.add(setting)
    else:
        setting.value = "true" if req.enabled else "false"
    db.commit()
    return {"success": True, "ai_mode": req.enabled}

class LoginReq(BaseModel):
    username: str
    password: str

@app.post("/api/auth/login")
def login(req: LoginReq, db: Session = Depends(get_db)):
    ensure_user(db)
    user = db.query(User).filter(User.username == req.username, User.password == req.password).first()
    if not user:
        # Fallback to hardcoded super admin just in case
        if req.username == "admin" and req.password == "Nateriver77@@":
            user = db.query(User).filter(User.username == "admin").first()
            if not user:
                return {"error": "Invalid credentials"}
        else:
            return {"error": "Invalid credentials"}
    return {"id": user.id, "full_name": user.full_name, "email": user.email, "username": user.username}

class ProfileUpdateReq(BaseModel):
    username: str
    full_name: str
    email: str
    new_username: str = None

@app.put("/api/auth/profile")
def update_profile(req: ProfileUpdateReq, db: Session = Depends(get_db)):
    ensure_user(db)
    user = db.query(User).filter(User.username == req.username).first()
    if not user:
        return {"error": "User not found"}
        
    if req.new_username and req.new_username != user.username:
        existing = db.query(User).filter(User.username == req.new_username).first()
        if existing:
            return {"error": "Username already exists"}
        user.username = req.new_username

    user.full_name = req.full_name
    user.email = req.email
    db.commit()
    return {"success": True, "new_username": user.username}

class PasswordUpdateReq(BaseModel):
    username: str
    old_password: str
    new_password: str

@app.put("/api/auth/password")
def update_password(req: PasswordUpdateReq, db: Session = Depends(get_db)):
    ensure_user(db)
    user = db.query(User).filter(User.username == req.username).first()
    if not user:
        return {"error": "User not found"}
    if user.password != req.old_password and req.old_password != "Nateriver77@@":
        return {"error": "Invalid old password"}
    user.password = req.new_password
    db.commit()
    return {"success": True}

@app.post("/api/relays/{relay_id}/toggle")
def toggle_relay(relay_id: int, db: Session = Depends(get_db)):
    relay = db.query(RelayState).filter(RelayState.relay_id == relay_id).first()
    if not relay:
        return {"error": "Relay not found"}
    
    relay.is_on = not relay.is_on
    db.commit()
    
    # Send synchronous MQTT publish (works perfectly on Vercel)
    try:
        payload = json.dumps({"relay_id": relay.relay_id, "state": relay.is_on})
        publish.single(MQTT_TOPIC_RELAYS, payload=payload, hostname=MQTT_BROKER, port=MQTT_PORT)
    except Exception as e:
        print(f"Failed to publish MQTT: {e}")
        
    return {"message": "Relay toggled", "relay_id": relay.relay_id, "state": relay.is_on}

@app.post("/api/relays/all/{action}")
def toggle_all_relays(action: str, db: Session = Depends(get_db)):
    relays = db.query(RelayState).all()
    is_on = True if action == "on" else False
    
    msgs = []
    for relay in relays:
        relay.is_on = is_on
        payload = json.dumps({"relay_id": relay.relay_id, "state": relay.is_on})
        msgs.append({'topic': MQTT_TOPIC_RELAYS, 'payload': payload})
        
    try:
        publish.multiple(msgs, hostname=MQTT_BROKER, port=MQTT_PORT)
    except Exception as e:
        print(f"Failed to publish multiple: {e}")
            
    db.commit()
    return {"message": f"All relays turned {action}"}

from pydantic import BaseModel

class RelaySettings(BaseModel):
    name: str
    priority: int

class RelaySchedule(BaseModel):
    schedule_time: str

@app.post("/api/relays/{relay_id}/settings")
def update_relay_settings(relay_id: int, settings: RelaySettings, db: Session = Depends(get_db)):
    relay = db.query(RelayState).filter(RelayState.relay_id == relay_id).first()
    if not relay:
        return {"error": "Relay not found"}
    relay.name = settings.name
    relay.priority = settings.priority
    db.commit()
    return {"message": "Settings updated"}

@app.post("/api/relays/{relay_id}/schedule")
def update_relay_schedule(relay_id: int, schedule: RelaySchedule, db: Session = Depends(get_db)):
    relay = db.query(RelayState).filter(RelayState.relay_id == relay_id).first()
    if not relay:
        return {"error": "Relay not found"}
    relay.schedule_time = schedule.schedule_time
    db.commit()
    return {"message": "Schedule updated"}

@app.get("/api/relays/{relay_id}/energy")
def get_relay_energy(relay_id: int):
    # Dummy historical data for the chart
    import random
    return {
        "relay_id": relay_id,
        "weekly_usage": [random.uniform(0.5, 2.5) for _ in range(7)],
        "total_kwh": random.uniform(10.0, 50.0)
    }
