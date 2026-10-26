# Hand Gesture Detection

Real-time webcam gesture recognition using MediaPipe Hands and the included
`mp_hand_gesture` model. Recognized gestures are listed in `gesture.names`.

## Setup

Use Python 3.10 or 3.11. The included model is a legacy TensorFlow SavedModel,
so this project pins TensorFlow 2.15 (Keras 2); newer Keras 3 releases cannot
load this model directory with `load_model()`.

```bash
python3.11 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

## Run

From the project directory, with a webcam attached and a graphical desktop:

```bash
python hand_gesture_detection.py
```

Show one hand to the camera. Press `q` in the output window to quit.

### Windows laptop

Install 64-bit Python 3.11 and enable the Python Launcher during installation.
Then double-click `setup.bat` from File Explorer. It creates a Windows virtual
environment, installs the dependencies, and starts the webcam app. Allow camera
access if Windows asks.
