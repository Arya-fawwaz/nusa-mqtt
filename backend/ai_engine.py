import json
from models import TelemetryData
from typing import Dict, Any

class AIEngine:
    def __init__(self):
        # In a real app, this would load a trained ML model
        pass
        
    def generate_recommendation(self, telemetry: TelemetryData) -> Dict[str, Any]:
        """
        Mock AI recommendation logic based on simple rules.
        In production, replace this with model.predict(features).
        """
        if not telemetry:
            return {"status": "insufficient_data"}
            
        battery_soc = telemetry.battery_soc
        total_load = telemetry.total_load
        
        recommendation = {
            "status": "normal",
            "action": None,
            "reason": "Battery is healthy"
        }
        
        # Rule 1: Critical Battery Level
        if battery_soc < 30.0:
            recommendation = {
                "status": "critical",
                "action": {
                    "turn_off_priorities": [5, 4, 3], # Matikan Rumah Tangga, Produktif, Pendidikan
                    "keep_on": [1, 2] # Vital & Kebutuhan Dasar
                },
                "reason": "Battery SOC below 30%, prioritizing vital facilities."
            }
        # Rule 2: High Load Warning
        elif battery_soc < 50.0 and total_load > 10.0: # example thresholds
            recommendation = {
                "status": "warning",
                "action": {
                    "turn_off_priorities": [5], # Matikan Rumah Tangga saja
                },
                "reason": "High load detected with medium battery. Reduce non-essential load."
            }
            
        return recommendation

ai_engine = AIEngine()
