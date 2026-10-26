#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

PYTHON_BIN=""
PYTHON_VERSION=""
find_python() {
    for candidate in python3.11 python3.10; do
        if command -v "$candidate" >/dev/null 2>&1; then
            PYTHON_BIN="$(command -v "$candidate")"
            PYTHON_VERSION="${candidate#python}"
            return 0
        fi
    done
    return 1
}

find_python || true

if [[ -z "$PYTHON_BIN" ]]; then
    if ! command -v apt-get >/dev/null 2>&1; then
        echo "Python 3.10 or 3.11 is required, and apt-get is unavailable to install it." >&2
        exit 1
    fi

    if [[ "$(id -u)" -ne 0 ]]; then
        echo "Python 3.10 or 3.11 is missing. Rerun this script as root so it can install Python using apt." >&2
        exit 1
    fi

    echo "Python 3.10/3.11 not found. Updating apt package lists..."
    apt-get update

    INSTALLED_PYTHON="false"
    for version in 3.11 3.10; do
        echo "Trying to install Python $version and its venv support..."
        if apt-get install -y "python${version}" "python${version}-venv"; then
            INSTALLED_PYTHON="true"
            break
        fi
    done

    if [[ "$INSTALLED_PYTHON" != "true" ]]; then
        echo "Python 3.10/3.11 is not available in the configured apt repositories. Trying uv to install Python 3.11..."

        UV_BIN=""
        if command -v uv >/dev/null 2>&1; then
            UV_BIN="$(command -v uv)"
        else
            # Keep uv and its pip installation isolated from Ubuntu's system Python.
            if ! python3 -m venv .uv-tools; then
                echo "Could not create a tools environment. Installing Ubuntu's venv support..."
                apt-get install -y python3-venv
                python3 -m venv .uv-tools
            fi
            .uv-tools/bin/python -m pip install --upgrade pip uv
            UV_BIN="$PROJECT_DIR/.uv-tools/bin/uv"
        fi

        "$UV_BIN" python install 3.11
        PYTHON_BIN="$("$UV_BIN" python find 3.11)"
        PYTHON_VERSION="3.11"
    fi
fi

VENV_DIR=".venv"
if [[ -x "$VENV_DIR/bin/python" ]]; then
    VENV_VERSION="$("$VENV_DIR/bin/python" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
    if [[ "$VENV_VERSION" != "$PYTHON_VERSION" ]]; then
        VENV_DIR=".venv-py${PYTHON_VERSION//./}"
        echo "Existing .venv uses Python $VENV_VERSION; using $VENV_DIR for Python $PYTHON_VERSION."
    fi
fi

if [[ ! -x "$VENV_DIR/bin/python" ]]; then
    "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

echo "Installing project dependencies into $VENV_DIR..."
"$VENV_DIR/bin/python" -m pip install --upgrade pip
"$VENV_DIR/bin/python" -m pip install -r requirements.txt

echo "Starting hand gesture detection. Press q in the camera window to quit."
exec "$VENV_DIR/bin/python" hand_gesture_detection.py
