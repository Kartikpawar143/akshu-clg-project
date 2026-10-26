@echo off
setlocal
cd /d "%~dp0"

echo This removes the project's virtual environments and installed dependencies.
echo The source code and gesture model will be kept.
set /p "CONFIRM=Continue? (y/N): "
if /i not "%CONFIRM%"=="y" (
    echo Cleanup cancelled.
    exit /b 0
)

for %%D in (.venv-win .venv .venv-py310 .venv-py311 .uv-tools) do (
    if exist "%%D" (
        echo Removing %%D...
        rmdir /s /q "%%D"
        if exist "%%D" (
            echo Could not completely remove %%D. Close any programs using it and try again.
            exit /b 1
        )
    )
)

echo Project environments removed. Run setup.bat again to use the app later.
pause
