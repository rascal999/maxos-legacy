# Whisper to Cursor (Dockerized)

This is a dockerized version of the Whisper to Cursor tool, which transcribes speech and types it at the cursor position.

## Features

- Attempts to record audio from your microphone (with fallback option)
- Transcribes the audio using OpenAI's Whisper speech recognition model
- Types the transcribed text at the current cursor position
- Runs in a Docker container for easy deployment and isolation
- Gracefully handles common Docker permission issues

## Prerequisites

- Docker
- Docker Compose
- X11 for GUI access
- Audio device access (optional, fallback available)

## Installation

No installation is needed. Just run the provided script.

## Usage

1. Make sure your cursor is positioned where you want the text to be typed.
2. Run the script:

```bash
./run-whisper-to-cursor.sh
```

3. The application will:
   - Try to record from your microphone for 5 seconds
   - If microphone access fails, it will generate test audio instead
   - Transcribe the audio using the "base" Whisper model
   - Type the transcribed text at your cursor position
   - Automatically prepare for the next cycle after a short pause

4. To exit, press Ctrl+C at any time.

## Fallback Mode

Due to Docker's limitations with accessing hardware devices, the application includes a fallback mode:

- If microphone access fails, it generates a test audio signal (440 Hz tone)
- This allows you to test the typing functionality even without microphone access
- A message will be displayed when fallback mode is activated

## Models

Whisper offers several models with different sizes and capabilities:

- **tiny**: Fastest, least accurate
- **base**: Good balance of speed and accuracy for most use cases (default)
- **small**: More accurate than base, but slower
- **medium**: High accuracy, slower
- **large**: Most accurate, slowest

The first time you use the application, it will download the base model automatically.

## Customization

If you want to change the default settings (recording duration or model), you'll need to modify the `whisper-to-cursor.py` script:

```python
# Default values
duration = 5  # Change this to your preferred recording duration
model_name = "base"  # Change this to "tiny", "small", "medium", or "large"
```

## Troubleshooting

If you encounter issues:

1. **Container Build Failures**: The script automatically rebuilds the container each time to ensure the latest version is used.

2. **Audio Issues**: The application will automatically fall back to test audio if microphone access fails. For real microphone access, you may need to configure Docker with the appropriate permissions.

3. **X11 Issues**: Ensure X11 forwarding is properly set up and DISPLAY environment variable is correctly set.

4. **Keyboard Input Issues**: The application needs access to the X11 server to simulate keyboard input. Make sure you're running it on a system with a GUI.

## License

This project is licensed under the MIT License.