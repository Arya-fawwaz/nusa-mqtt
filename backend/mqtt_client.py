import asyncio
import json
import os
from aiohttp import web
import aiomqtt
from database import SessionLocal
from models import TelemetryData, SystemSettings, RelayState, AILog
from datetime import datetime

MQTT_BROKER = os.getenv("MQTT_BROKER", "localhost")
MQTT_PORT = int(os.getenv("MQTT_PORT", 1883))

def db_operations(device_id, payload, client):
    # This runs synchronously in a separate thread
    with SessionLocal() as session:
        telemetry = TelemetryData(
            battery_voltage=payload.get("battery_voltage", 0),
            battery_current=payload.get("battery_current", 0),
            battery_soc=payload.get("battery_soc", 0),
            solar_voltage=payload.get("solar_voltage", 0),
            solar_current=payload.get("solar_current", 0),
            solar_power=payload.get("solar_power", 0),
            grid_voltage=payload.get("grid_voltage", 0),
            load_power=payload.get("total_load", 0),
            timestamp=datetime.utcnow()
        )
        session.add(telemetry)
        session.commit()
        print(f"[MQTT] Saved telemetry data")

        # Check AI Mode
        setting = session.query(SystemSettings).filter(SystemSettings.key == "ai_mode").first()
        if setting and setting.value == "true":
            run_ai_optimization(session, telemetry, client)

def run_ai_optimization(session, telemetry, client):
    soc = telemetry.battery_soc or 0
    solar = telemetry.solar_power or 0
    
    print(f"[AI] Running optimization. SOC: {soc}%, Solar: {solar}W")
    
    # Define thresholds
    cutoff_priority = None
    if soc < 20:
        cutoff_priority = 1 # Only keep priority 1
    elif soc < 50 and solar < 50:
        cutoff_priority = 2 # Keep priority 1, 2
        
    restore = False
    if soc > 80 or (soc > 50 and solar > 200):
        restore = True
        
    relays = session.query(RelayState).all()
    actions_taken = False
    
    for r in relays:
        if cutoff_priority is not None and r.priority > cutoff_priority and r.is_on:
            r.is_on = False
            asyncio.run_coroutine_threadsafe(
                client.publish(f"nusa_power/relays/control", json.dumps({"relay_id": r.relay_id, "state": False})),
                asyncio.get_running_loop()
            )
            log = AILog(action_type="TURN_OFF_RELAY", description=f"Turned off {r.name} due to low power", priority_level=r.priority)
            session.add(log)
            actions_taken = True
            
        elif restore and not r.is_on and r.priority <= 4:
            r.is_on = True
            asyncio.run_coroutine_threadsafe(
                client.publish(f"nusa_power/relays/control", json.dumps({"relay_id": r.relay_id, "state": True})),
                asyncio.get_running_loop()
            )
            log = AILog(action_type="TURN_ON_RELAY", description=f"Turned on {r.name} as power is restored", priority_level=r.priority)
            session.add(log)
            actions_taken = True

    if actions_taken:
        session.commit()
        print("[AI] Optimization actions committed.")

async def process_message(client, message):
    try:
        topic = str(message.topic)
        payload = json.loads(message.payload.decode())
        device_id = topic.split("/")[-1]
        
        await asyncio.to_thread(db_operations, device_id, payload, client)
    except Exception as e:
        print(f"[MQTT Error] {e}")

async def mqtt_subscriber():
    while True:
        try:
            print(f"Connecting to MQTT Broker at {MQTT_BROKER}:{MQTT_PORT}")
            async with aiomqtt.Client(hostname=MQTT_BROKER, port=MQTT_PORT) as client:
                await client.subscribe("nusapower/telemetry/#")
                print("Subscribed to nusapower/telemetry/#")
                async for message in client.messages:
                    asyncio.create_task(process_message(client, message))
        except aiomqtt.MqttError as e:
            print(f"MQTT connection lost: {e}. Reconnecting in 5 seconds...")
            await asyncio.sleep(5)
        except Exception as e:
            print(f"Unexpected MQTT error: {e}")
            await asyncio.sleep(5)

async def health_check(request):
    return web.Response(text="MQTT Client is running.")

async def start_dummy_server():
    app = web.Application()
    app.router.add_get('/', health_check)
    runner = web.AppRunner(app)
    await runner.setup()
    port = int(os.environ.get("PORT", 8080))
    site = web.TCPSite(runner, '0.0.0.0', port)
    await site.start()
    print(f"Dummy HTTP server listening on port {port}")

async def main():
    await start_dummy_server()
    await mqtt_subscriber()

if __name__ == "__main__":
    asyncio.run(main())
