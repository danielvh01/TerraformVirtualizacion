# Dockerfile

FROM python:3.9-slim

WORKDIR /app

RUN pip install flask pytz

COPY . .

CMD ["python", "app.py"]