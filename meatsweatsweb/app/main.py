from fastapi import FastAPI, File, UploadFile
from starlette.requests import Request
from app.detecting_resource import DetectingResource
import os
import cv2
import logging

app = FastAPI()
logger = logging.getLogger("fastapi")
logger.setLevel(logging.DEBUG)
print("OpenCV Version: {}".format(cv2.__version__))


@app.get("/")
def read_root():
    return {"Hello": "WE ARE ONLINE"}


@app.post("/detect")
def detect(image: UploadFile = File(...)):
    return DetectingResource().detect(image)
