"""
ML Model Serving API
FastAPI endpoints for churn prediction, segmentation, and forecasting.
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Dict
import pickle
import numpy as np
from pathlib import Path

app = FastAPI(
    title="SuperApp ML API",
    description="Production ML models for customer analytics",
    version="1.0.0"
)

# Load models on startup
MODELS = {}

@app.on_event("startup")
async def load_models():
    """Load all ML models into memory"""
    print("Loading ML models...")
    
    # Churn prediction
    with open('models_ml/churn_prediction/outputs/xgboost_churn_model.pkl', 'rb') as f:
        MODELS['churn_model'] = pickle.load(f)
    with open('models_ml/churn_prediction/outputs/scaler.pkl', 'rb') as f:
        MODELS['churn_scaler'] = pickle.load(f)
    
    # Segmentation
    with open('models_ml/segmentation/outputs/kmeans_segmentation_model.pkl', 'rb') as f:
        MODELS['segment_model'] = pickle.load(f)
    with open('models_ml/segmentation/outputs/scaler.pkl', 'rb') as f:
        MODELS['segment_scaler'] = pickle.load(f)
    
    # Forecasting
    with open('models_ml/forecasting/outputs/rf_forecast_model.pkl', 'rb') as f:
        MODELS['forecast_model'] = pickle.load(f)
    with open('models_ml/forecasting/outputs/scaler.pkl', 'rb') as f:
        MODELS['forecast_scaler'] = pickle.load(f)
    
    print("✅ All models loaded successfully!")

# Request/Response models
class UserFeatures(BaseModel):
    total_events: int
    events_last_30d: int
    events_last_7d: int
    unique_event_types: int
    login_events: float
    view_events: float
    click_events: float
    purchase_events: float
    days_with_events: int
    days_since_last_event: int

class ChurnPrediction(BaseModel):
    user_id: str = None
    churn_probability: float
    is_churned: bool
    risk_level: str

class SegmentPrediction(BaseModel):
    user_id: str = None
    cluster_id: int
    segment_name: str

class ForecastPrediction(BaseModel):
    user_id: str = None
    predicted_events: float

# Health check
@app.get("/")
def root():
    return {
        "service": "SuperApp ML API",
        "status": "healthy",
        "models_loaded": len(MODELS) // 2,  # 3 models, each with scaler
        "endpoints": ["/predict/churn", "/predict/segment", "/predict/forecast"]
    }

# Churn prediction endpoint
@app.post("/predict/churn", response_model=ChurnPrediction)
def predict_churn(features: UserFeatures):
    """Predict customer churn probability"""
    try:
        # Prepare features
        X = np.array([[
            features.total_events,
            features.events_last_30d,
            features.events_last_7d,
            features.unique_event_types,
            features.login_events,
            features.view_events,
            features.click_events,
            features.purchase_events,
            features.days_with_events,
            features.days_since_last_event
        ]])
        
        # Scale and predict
        X_scaled = MODELS['churn_scaler'].transform(X)
        proba = MODELS['churn_model'].predict_proba(X_scaled)[0][1]
        is_churned = proba > 0.5
        
        # Risk level
        if proba > 0.7:
            risk_level = "high"
        elif proba > 0.4:
            risk_level = "medium"
        else:
            risk_level = "low"
        
        return ChurnPrediction(
            churn_probability=float(proba),
            is_churned=bool(is_churned),
            risk_level=risk_level
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Segmentation endpoint
@app.post("/predict/segment", response_model=SegmentPrediction)
def predict_segment(features: UserFeatures):
    """Predict customer segment"""
    try:
        X = np.array([[
            features.total_events,
            features.events_last_30d,
            features.events_last_7d,
            features.unique_event_types,
            features.login_events,
            features.view_events,
            features.click_events,
            features.purchase_events,
            features.days_with_events,
            features.days_since_last_event
        ]])
        
        X_scaled = MODELS['segment_scaler'].transform(X)
        cluster_id = int(MODELS['segment_model'].predict(X_scaled)[0])
        
        # Map cluster to segment name
        segment_names = {
            0: "Casual Users",
            1: "Active Users",
            2: "Low Engagement",
            3: "Power Users"
        }
        
        return SegmentPrediction(
            cluster_id=cluster_id,
            segment_name=segment_names.get(cluster_id, "Unknown")
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Forecasting endpoint
@app.post("/predict/forecast", response_model=ForecastPrediction)
def predict_forecast(features: UserFeatures):
    """Forecast future event volume"""
    try:
        # Use only forecasting features
        X = np.array([[
            features.events_last_30d,
            features.events_last_7d,
            features.unique_event_types,
            features.login_events,
            features.view_events,
            features.click_events,
            features.purchase_events,
            features.days_with_events,
            features.days_since_last_event
        ]])
        
        X_scaled = MODELS['forecast_scaler'].transform(X)
        predicted_events = float(MODELS['forecast_model'].predict(X_scaled)[0])
        
        return ForecastPrediction(
            predicted_events=max(0, predicted_events)  # Ensure non-negative
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
