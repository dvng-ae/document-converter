FROM python:3.13-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libreoffice \
    libreoffice-calc \
    libreoffice-writer \
    libreoffice-impress \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY server.py .

ENV PORT=10000

CMD gunicorn --bind 0.0.0.0:$PORT server:app