# Nusa Power: IoT & AI Energy Management System

Nusa Power is an intelligent Internet of Things (IoT) and Artificial Intelligence (AI) system designed for efficient solar power (PLTS) monitoring and battery energy management. The system autonomously manages relay states based on real-time solar panel power generation and battery State of Charge (SOC).

## Architecture Overview

The system consists of two primary components:
1. **Backend (Python)**: An AI engine and MQTT worker that listens to sensor telemetry via the MQTT protocol. It processes real-time data (battery voltage, solar current, grid status) and makes autonomous decisions to optimize energy usage.
2. **Mobile Application (Flutter)**: A cross-platform mobile application providing users with real-time dashboards, manual relay overrides, and system settings configuration.

## Directory Structure

```text
.
├── backend/                  # Python API and AI Engine
│   ├── main.py               # REST API endpoints (FastAPI)
│   ├── mqtt_client.py        # MQTT listener & AI decision engine
│   ├── database.py           # SQLite database configuration
│   ├── models.py             # SQLAlchemy ORM models
│   ├── requirements.txt      # Python dependencies
│   └── Dockerfile            # Container configuration for cloud deployment
│
└── mobile/                   # Flutter Mobile Application
    ├── lib/                  # Dart source code
    │   └── main.dart         # Main UI and application logic
    └── pubspec.yaml          # Flutter dependencies
```

## Deployment Guide (Backend)

The backend is containerized and ready for deployment on platforms like Render, Vercel, or Koyeb. 

### Deploying to Render.com
1. Create a new **Web Service** on your Render dashboard.
2. Connect this GitHub repository.
3. In the configuration settings, set the **Root Directory** to: `backend`
4. Ensure the **Language** is set to `Docker`.
5. Click **Create Web Service**.

### Environment Variables
Ensure the following environment variables are configured in your deployment environment:
* `MQTT_BROKER`: The address of your MQTT broker (e.g., `broker.emqx.io`).
* `MQTT_PORT`: The port for the MQTT connection (default: `1883`).

## Development Setup

### Backend (Python 3.12+)
```bash
cd backend
pip install -r requirements.txt
python main.py
```

### Mobile App (Flutter)
```bash
cd mobile
flutter pub get
flutter run
```

---
*Developed for Nusa Power IoT Systems.*
