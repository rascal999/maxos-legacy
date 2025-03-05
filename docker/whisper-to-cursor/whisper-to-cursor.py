#!/usr/bin/env python3

import os
import tempfile
import time
import numpy as np
import whisper
import keyboard
import sys
import wave

def generate_test_audio(duration=5, sample_rate=16000):
    """Generate a test audio signal (sine wave) for demonstration purposes."""
    print(f"Generating test audio for {duration} seconds...")
    
    # Generate a simple sine wave
    t = np.linspace(0, duration, int(duration * sample_rate), False)
    tone = np.sin(2 * np.pi * 440 * t)  # 440 Hz tone
    
    # Normalize
    audio_data = tone.astype(np.float32)
    
    return audio_data, sample_rate

def try_record_audio(duration=5, sample_rate=16000):
    """Try to record audio from the microphone, with fallback to test audio."""
    try:
        import sounddevice as sd
        import soundfile as sf
        
        print(f"Recording from microphone for {duration} seconds...")
        print("If you don't hear any sound, the microphone might not be accessible.")
        
        # Record audio using sounddevice
        recording = sd.rec(int(duration * sample_rate), samplerate=sample_rate, channels=1)
        sd.wait()  # Wait until recording is finished
        
        # Normalize the audio data
        audio_data = recording.flatten().astype(np.float32)
        if np.max(np.abs(audio_data)) > 0:
            audio_data = audio_data / np.max(np.abs(audio_data))
        
        return audio_data, sample_rate
    
    except Exception as e:
        print(f"Error accessing microphone: {e}")
        print("Falling back to test audio...")
        return generate_test_audio(duration, sample_rate)

def save_audio_to_file(audio_data, sample_rate, filename):
    """Save audio data to a WAV file."""
    with wave.open(filename, 'wb') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)  # 2 bytes for int16
        wf.setframerate(sample_rate)
        wf.writeframes((audio_data * 32767).astype(np.int16).tobytes())

def transcribe_audio(audio_data, sample_rate, model_name="base"):
    """Transcribe audio using Whisper."""
    print(f"Transcribing with {model_name} model...")
    
    try:
        # Load Whisper model
        model = whisper.load_model(model_name)
        
        # Create a temporary file for the audio
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as temp_file:
            temp_filename = temp_file.name
        
        # Save audio to the temporary file
        save_audio_to_file(audio_data, sample_rate, temp_filename)
        
        # Transcribe the audio
        result = model.transcribe(temp_filename)
        
        # Clean up the temporary file
        os.unlink(temp_filename)
        
        return result["text"].strip()
    except Exception as e:
        print(f"Error during transcription: {e}")
        return "Error transcribing audio. This is a demonstration of typing at the cursor position."

def type_text(text):
    """Type the transcribed text at the current cursor position."""
    print(f"Typing: {text}")
    
    try:
        # Type the text using keyboard module
        for char in text:
            keyboard.write(char)
            time.sleep(0.01)  # Small delay to prevent typing too fast
    except Exception as e:
        print(f"Error typing text: {e}")
        print("Unable to type at cursor. This might be due to X11 permissions or keyboard access issues.")

def main():
    """Main function to record, transcribe, and type text."""
    print("Whisper to Cursor - Transcribe speech and type it at the cursor")
    print("Press Ctrl+C to exit")
    
    # Default values
    duration = 5
    model_name = "base"
    
    # Check if running in Docker
    in_docker = os.path.exists('/.dockerenv')
    if in_docker:
        print("Running in Docker container")
        print("Note: Microphone access might be limited in Docker. Using fallback if needed.")
    
    try:
        while True:
            print(f"Using recording duration: {duration} seconds")
            print(f"Using model: {model_name}")
            print("Position your cursor where you want the text to be typed.")
            print("Recording/generation will start in 3 seconds...")
            time.sleep(3)
            
            # Try to record audio (with fallback)
            audio_data, sample_rate = try_record_audio(duration)
            
            # Transcribe audio
            text = transcribe_audio(audio_data, sample_rate, model_name)
            
            # Type the transcribed text
            type_text(text)
            
            print("\nProcess complete. Press Ctrl+C to exit or wait for next cycle.")
            print("Next cycle will start in 5 seconds...")
            time.sleep(5)
    
    except KeyboardInterrupt:
        print("\nExiting...")

if __name__ == "__main__":
    main()