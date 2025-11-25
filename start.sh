#!/bin/bash

# Alpha Bowl Start Script
# Checks if port 9009 is in use and kills the process if needed
# Then starts the Flutter web server

set -e

PORT=9009
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo "     Alpha Bowl Football Game Launcher"
echo "     Real-Time 3D Football with RPG"
echo "========================================="
echo ""

# Check if port 9009 is in use
echo "Checking if port $PORT is available..."
PORT_PID=$(lsof -ti:$PORT 2>/dev/null || echo "")

if [ ! -z "$PORT_PID" ]; then
    echo "⚠️  Port $PORT is currently in use by process $PORT_PID"
    echo "Killing process $PORT_PID..."
    kill -9 $PORT_PID 2>/dev/null || true
    sleep 1
    echo "✅ Process killed successfully"
else
    echo "✅ Port $PORT is available"
fi

echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH"
    echo "Please install Flutter from https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "Flutter version:"
flutter --version | head -n 1

echo ""

# Check if we're in a Flutter project
if [ ! -f "$PROJECT_DIR/pubspec.yaml" ]; then
    echo "❌ Error: No Flutter project found in $PROJECT_DIR"
    echo "Please ensure you're running this script from the alpha_bowl directory"
    exit 1
fi

cd "$PROJECT_DIR"

# Get Flutter dependencies
echo "Getting Flutter dependencies..."
flutter pub get

echo ""
echo "========================================="
echo "  Starting Alpha Bowl on http://localhost:$PORT"
echo "========================================="
echo ""
echo "🎮 Controls:"
echo "  W/A/S/D    - Move player"
echo "  V          - Toggle camera mode"
echo "  J/L        - Rotate camera"
echo "  Esc        - Pause menu"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start Flutter web server on port 9009
flutter run -d web-server --web-port=$PORT --web-hostname=localhost
