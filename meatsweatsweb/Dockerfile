FROM debian:buster

RUN apt-get update && apt-get install -y apt-utils \
  python3-pip \
  python3-opencv

EXPOSE 80

COPY ./app /app

RUN pip3 install opencv-python --upgrade

RUN pip3 install -r app/requirements.txt --extra-index-url=https://www.piwheels.org/simple

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
