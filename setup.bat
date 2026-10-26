@echo off
setlocal
cd /d "%~dp0"

py -3.11 --version >nul 2>&1
if not errorlevel 1 goto python_ready

where winget >nul 2>&1
if errorlevel 1 goto missing_python

echo Python 3.11 was not found. Installing it with Windows Package Manager...
winget install --id Python.Python.3.11 --exact --scope user --accept-package-agreements --accept-source-agreements
if errorlevel 1 goto python_install_failed

rem The installer may have placed Python in the standard per-user directory,
rem which is not necessarily on the PATH of this already-open terminal.
if exist "%LocalAppData%\Programs\Python\Python311\python.exe" (
    set "PYTHON_EXE=%LocalAppData%\Programs\Python\Python311\python.exe"
    goto python_ready
)

py -3.11 --version >nul 2>&1
if errorlevel 1 goto restart_terminal

:python_ready
if not exist ".venv-win\Scripts\python.exe" (
    echo Creating Python 3.11 environment...
    if defined PYTHON_EXE (
        "%PYTHON_EXE%" -m venv .venv-win
    ) else (
        py -3.11 -m venv .venv-win
    )
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
echo Python 3.11 and Windows Package Manager (winget) were not found.
echo Install 64-bit Python 3.11 from https://www.python.org/downloads/windows/
echo Enable the Python Launcher for Windows, then close and reopen Git Bash.
pause
exit /b 1

:python_install_failed
echo Automatic Python installation failed. Install 64-bit Python 3.11 manually from https://www.python.org/downloads/windows/
pause
exit /b 1

:restart_terminal
echo Python 3.11 was installed. Close and reopen Git Bash, then run setup.bat again.
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
