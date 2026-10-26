@echo off
setlocal
cd /d "%~dp0"

py -3.11 --version >nul 2>&1
if errorlevel 1 goto missing_python

if not exist ".venv-win\Scripts\python.exe" (
    echo Creating Python 3.11 environment...
    py -3.11 -m venv .venv-win
    if errorlevel 1 goto setup_failed
)

echo Installing project dependencies...
".venv-win\Scripts\python.exe" -m pip install --upgrade pip
if errorlevel 1 goto setup_failed
".venv-win\Scripts\python.exe" -m pip install -r requirements.txt
if errorlevel 1 goto setup_failed

echo Starting hand gesture detection. Press q in the camera window to quit.
".venv-win\Scripts\python.exe" hand_gesture_detection.py
if errorlevel 1 goto run_failed
exit /b 0

:missing_python
echo Python 3.11 was not found. Install 64-bit Python 3.11 from https://www.python.org/downloads/windows/
echo During installation, enable the Python Launcher for Windows.
pause
exit /b 1

:setup_failed
echo Setup failed. Check the error above and your internet connection, then run setup.bat again.
pause
exit /b 1

:run_failed
echo The app exited with an error. Check that your webcam is connected and camera access is allowed.
pause
exit /b 1
