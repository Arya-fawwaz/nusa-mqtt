import os
import json
import time
import paho.mqtt.client as mqtt
import paho.mqtt.publish as publish
from database import SessionLocal
from models import TelemetryData, RelayState, AILog
from datetime import datetime

MQTT_BROKER = "broker.hivemq.com"
MQTT_PORT = 1883
TOPIC = "nusapower/telemetry/#"
RELAY_TOPIC = "nusa_power/relays"

os.environ['DATABASE_URL'] = 'postgresql+psycopg2://postgres.yuprnlvnjbbjlahshvrc:Nateriver77%40%40@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres?sslmode=require'

def on_connect(client, userdata, flags, rc):
    print(f"Connected to MQTT, result code {rc}", flush=True)
    client.subscribe(TOPIC)


def handle_ai_logic(session, solar_power, battery_soc):
    # Cek apakah AI Mode aktif
    from models import SystemSettings
    setting = session.query(SystemSettings).filter(SystemSettings.key == "ai_mode").first()
    is_ai_enabled = setting.value == "true" if setting else False
    if not is_ai_enabled:
        return # Jangan bajak kalau AI dimatikan user
        
    ai_autoCutoff = session.query(SystemSettings).filter(SystemSettings.key == "ai_autoCutoff").first()
    is_autoCutoff = ai_autoCutoff.value == "true" if ai_autoCutoff else True
    
    ai_priorityActive = session.query(SystemSettings).filter(SystemSettings.key == "ai_priorityActive").first()
    is_priorityActive = ai_priorityActive.value == "true" if ai_priorityActive else True
    
    ai_energyHarvestActive = session.query(SystemSettings).filter(SystemSettings.key == "ai_energyHarvestActive").first()
    is_energyHarvestActive = ai_energyHarvestActive.value == "true" if ai_energyHarvestActive else True

    # Skenario Baterai Kritis
    if battery_soc < 30.0 and is_priorityActive:
        # Matikan prioritas >= 3 (Pendidikan, Produktif, Rumah Tangga)
        # Pastikan prioritas 1 (Fasilitas Vital) TETAP NYALA!
        relays = session.query(RelayState).filter(RelayState.priority >= 3, RelayState.is_on == True).all()
        for r in relays:
            r.is_on = False
            session.add(AILog(
                action_type="LOAD_SHEDDING", 
                description=f"Darurat AI: Mematikan '{r.name}' karena baterai kritis ({battery_soc}%).", 
                priority_level=r.priority
            ))
            payload = json.dumps({"relay_id": r.relay_id, "state": False})
            try:
                publish.single(RELAY_TOPIC, payload=payload, hostname=MQTT_BROKER, port=MQTT_PORT)
            except Exception:
                pass
                
        # Nyalakan paksa prioritas 1 jika kebetulan mati
        vital_relays = session.query(RelayState).filter(RelayState.priority == 1, RelayState.is_on == False).all()
        for r in vital_relays:
            r.is_on = True
            session.add(AILog(
                action_type="CRITICAL_RESTORE", 
                description=f"Darurat AI: Memaksa nyala '{r.name}' (Prioritas 1) meski baterai kritis.", 
                priority_level=r.priority
            ))
            payload = json.dumps({"relay_id": r.relay_id, "state": True})
            try:
                publish.single(RELAY_TOPIC, payload=payload, hostname=MQTT_BROKER, port=MQTT_PORT)
            except Exception:
                pass

    # Skenario Cuaca Buruk
    elif solar_power < 10.0 and is_autoCutoff and battery_soc >= 30.0:
        # Matikan prioritas >= 4
        relays = session.query(RelayState).filter(RelayState.priority >= 4, RelayState.is_on == True).all()
        for r in relays:
            r.is_on = False
            session.add(AILog(
                action_type="WEATHER_CUTOFF", 
                description=f"AI: Mematikan '{r.name}' karena mode cuaca buruk aktif.", 
                priority_level=r.priority
            ))
            payload = json.dumps({"relay_id": r.relay_id, "state": False})
            try:
                publish.single(RELAY_TOPIC, payload=payload, hostname=MQTT_BROKER, port=MQTT_PORT)
            except Exception:
                pass

    # Skenario Aman (Surplus / Matahari Terang)
    elif solar_power > 100.0 and battery_soc > 50.0 and is_energyHarvestActive:
        # Nyalakan kembali semua relai yang mati
        relays = session.query(RelayState).filter(RelayState.is_on == False).all()
        for r in relays:
            r.is_on = True
            session.add(AILog(
                action_type="AUTO_RESTORE", 
                description=f"AI: Menghidupkan kembali '{r.name}' karena suplai matahari melimpah.", 
                priority_level=r.priority
            ))
            payload = json.dumps({"relay_id": r.relay_id, "state": True})
            try:
                publish.single(RELAY_TOPIC, payload=payload, hostname=MQTT_BROKER, port=MQTT_PORT)
            except Exception:
                pass


def on_message(client, userdata, msg):
    print(f"Received message on {msg.topic}: {msg.payload.decode()}", flush=True)
    try:
        payload = json.loads(msg.payload.decode())
        with SessionLocal() as session:
            solar_power = payload.get("solar_power", 0)
            battery_soc = payload.get("battery_soc", 0)

            telemetry = TelemetryData(
                battery_voltage=payload.get("battery_voltage", 0),
                battery_current=payload.get("battery_current", 0),
                battery_soc=battery_soc,
                solar_voltage=payload.get("solar_voltage", 0),
                solar_current=payload.get("solar_current", 0),
                solar_power=solar_power,
                grid_voltage=payload.get("grid_voltage", 0),
                load_power=payload.get("total_load", 0),
                timestamp=datetime.utcnow()
            )
            session.add(telemetry)
            
            # Panggil Otak AI
            handle_ai_logic(session, solar_power, battery_soc)
            
            session.commit()
            print("Data saved to database!", flush=True)
    except Exception as e:
        print(f"Error saving data: {e}", flush=True)

client = mqtt.Client(client_id="NusaPower_DB_Writer_123")
client.on_connect = on_connect
client.on_message = on_message

print("Starting DB writer with AI Core...", flush=True)
client.connect(MQTT_BROKER, MQTT_PORT, 60)
client.loop_forever()
