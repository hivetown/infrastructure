FROM python:3.11.3-alpine3.16

WORKDIR /app

# Copy requirements.txt and install dependencies
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Copy the application files
COPY src/ .

ENV ZOOKEEPER_HOSTS 10.0.0.10:2181

CMD ["python", "-u", "/app/index.py"]
