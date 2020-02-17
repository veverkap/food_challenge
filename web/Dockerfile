FROM python:3.7

COPY ./app/requirements.txt /app/requirements.txt

RUN pip install -r /app/requirements.txt

COPY ./app /app

RUN mkdir -p /root/.cvlib/object_detection/yolo/yolov3

# COPY ./yolov3/yolov3.weights /root/.cvlib/object_detection/yolo/yolov3

COPY ./yolov3/yolov3.cfg /root/.cvlib/object_detection/yolo/yolov3

COPY ./yolov3/yolov3_classes.txt /root/.cvlib/object_detection/yolo/yolov3

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
