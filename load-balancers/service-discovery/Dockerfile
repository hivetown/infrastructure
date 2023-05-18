FROM python:3.11.3-alpine3.16

WORKDIR /app

# Copy requirements.txt and install dependencies
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Copy the application files
COPY src/ .

CMD ["python", "-u", "/app/index.py"]
