FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    portaudio19-dev \
    python3-dev \
    libx11-dev \
    libxtst-dev \
    libxi-dev \
    x11-utils \
    build-essential \
    gcc \
    libasound2-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the script
COPY whisper-to-cursor.py .
RUN chmod +x whisper-to-cursor.py

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DISPLAY=:0

# Run the script
ENTRYPOINT ["python", "whisper-to-cursor.py"]