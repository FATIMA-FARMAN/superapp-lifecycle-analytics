# SuperApp ML Platform

Production-grade machine learning platform for customer analytics, featuring churn prediction, customer segmentation, and event forecasting.

## 🎯 Models

### 1. Churn Prediction (XGBoost)
- **Accuracy**: 94%
- **AUC-ROC**: 0.9935
- **Use Case**: Identify customers at risk of churning
- **Key Features**: total_events, days_since_last_event, days_with_events

### 2. Customer Segmentation (K-Means)
- **Segments**: 4 behavioral clusters
  - Power Users (20.8%)
  - Active Users (31.8%)
  - Casual Users (41.8%)
  - Low Engagement (5.6%)
- **Silhouette Score**: 0.255
- **Use Case**: Targeted marketing and personalization

### 3. Event Forecasting (Random Forest)
- **R² Score**: 0.9713
- **MAE**: 1.75 events
- **Use Case**: Predict future user engagement levels
- **Key Features**: days_with_events (95.7% importance)

## 🚀 Quick Start

### Local Development
```bash
# Install dependencies
pip install -r requirements_api.txt

# Run API server
python api/main.py

# API available at http://localhost:8000
```

### Docker Deployment
```bash
# Build and run
docker-compose up --build

# Run in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## 📡 API Endpoints

### Health Check
```bash
GET /
```

### Churn Prediction
```bash
POST /predict/churn

Request Body:
{
  "total_events": 25,
  "events_last_30d": 0,
  "events_last_7d": 0,
  "unique_event_types": 5,
  "login_events": 5,
  "view_events": 10,
  "click_events": 5,
  "purchase_events": 5,
  "days_with_events": 20,
  "days_since_last_event": 45
}

Response:
{
  "churn_probability": 0.0015,
  "is_churned": false,
  "risk_level": "low"
}
```

### Customer Segmentation
```bash
POST /predict/segment

Response:
{
  "cluster_id": 1,
  "segment_name": "Active Users"
}
```

### Event Forecasting
```bash
POST /predict/forecast

Response:
{
  "predicted_events": 22.43
}
```

## 📊 Project Structure
```
├── data/                           # Raw data
├── models/                         # dbt models
│   ├── staging/                   # Source data cleaning
│   ├── intermediate/              # Business logic
│   ├── marts/                     # Analytics tables
│   └── ml_features/               # ML feature engineering
├── models_ml/                      # ML models
│   ├── churn_prediction/
│   │   ├── train_model.py
│   │   └── outputs/
│   ├── segmentation/
│   └── forecasting/
├── api/                           # FastAPI application
│   └── main.py
├── Dockerfile
├── docker-compose.yml
└── dbt_project.yml
```

## 🔧 Tech Stack

**Data Engineering:**
- dbt (data transformation)
- DuckDB (analytics database)
- SQL (feature engineering)

**Machine Learning:**
- XGBoost (classification)
- scikit-learn (clustering, regression)
- pandas, numpy (data processing)

**API & Deployment:**
- FastAPI (API framework)
- Docker (containerization)
- Uvicorn (ASGI server)

## 📈 Model Performance

| Model | Metric | Score |
|-------|--------|-------|
| Churn Prediction | AUC-ROC | 0.9935 |
| Churn Prediction | Accuracy | 94% |
| Segmentation | Silhouette | 0.255 |
| Forecasting | R² | 0.9713 |
| Forecasting | MAE | 1.75 events |

## 🎓 Key Features

- **Production-Ready**: Full CI/CD pipeline with dbt
- **Scalable Architecture**: Containerized microservices
- **Feature Engineering**: 50+ engineered features
- **Model Monitoring**: Performance tracking and metrics
- **API Documentation**: Auto-generated OpenAPI docs at `/docs`

## 📝 Author

Created for portfolio demonstration of end-to-end ML engineering:
- Analytics engineering (dbt)
- Feature engineering (SQL + Python)
- ML model development (XGBoost, scikit-learn)
- API development (FastAPI)
- Deployment (Docker)

## 🔗 Links

- API Docs (Swagger): `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`
- GitHub: [Your repo link]
