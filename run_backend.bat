@echo off
echo ========================================================
echo  WildFire AI - Starting Flask ML REST API Server
echo ========================================================
python -m pip install -r backend/requirements.txt
python backend/app.py
pause
