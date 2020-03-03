FROM registry.veverka.net/opencv:latest

EXPOSE 80

COPY ./app /app

RUN pip3 install fastapi numpy python-multipart tensorflow uvicorn --extra-index-url=https://www.piwheels.org/simple

RUN apt-get update \
  && apt-get install -y --no-install-recommends git \
  && apt-get purge -y --auto-remove \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.cvlib/object_detection/yolo/yolov3

RUN pip3 install git+https://github.com/veverkap/cvlib.git

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
