FROM python:3.11-slim
RUN apt-get update && apt-get install -y graphviz && rm -rf /var/lib/apt/lists/*
WORKDIR /app
RUN pip install flask
COPY asm_to_dot.py .
COPY app.py .
COPY templates/ ./templates/
COPY static/ ./static/
EXPOSE 5000
CMD ["python", "app.py"]
