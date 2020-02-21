from fastapi import FastAPI, File, UploadFile
from starlette.requests import Request
from app.detecting_resource import DetectingResource
import os
import logging

app = FastAPI()
logger = logging.getLogger("fastapi")
logger.setLevel(logging.DEBUG)


@app.get("/")
def read_root():
    return {"Hello": "WE ARE ONLINE"}


@app.post("/detect")
def detect(image: UploadFile = File(...)):
    print("DETECTED")
    return DetectingResource().detect(image)
