FROM python:3.7

COPY ./app/requirements.txt /app/requirements.txt

RUN pip install -r /app/requirements.txt

COPY ./app /app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
