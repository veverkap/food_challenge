from fastapi import FastAPI, File, UploadFile
from app.detecting_resource import DetectingResource
import os

app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "WE ARE ONLINE"}


@app.post("/detect")
def detect(image: UploadFile = File(...)):
    return DetectingResource().detect(image)
