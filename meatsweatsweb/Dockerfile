FROM python:3.7

RUN apt install libjasper1

EXPOSE 80

COPY ./app /app

RUN pip install -r app/requirements.txt --extra-index-url=https://www.piwheels.org/simple

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
