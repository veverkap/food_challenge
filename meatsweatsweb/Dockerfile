FROM python:3.7

RUN pip install fastapi uvicorn --extra-index-url=https://www.piwheels.org/simple

EXPOSE 80

COPY ./app /app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
