#!/bin/bash
mkdir -p models

echo Preparing models...
python prepare_models.py


echo Starting InsightFace-REST using $NUM_WORKERS workers.
uvicorn main:app --port 5000 --host 0.0.0.0 --workers $NUM_WORKERS

# gunicorn --bind 0.0.0.0:5000 main:app -w 4 -k uvicorn.workers.UvicornWorker --reload --access-logfile - --error-logfile - --log-level info