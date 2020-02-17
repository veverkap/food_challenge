from fastapi import FastAPI, File, UploadFile
from detecting_resource import DetectingResource
app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "sdfdsa"}


@app.post("/detect")
def detect(image: UploadFile = File(...)):
    return DetectingResource().detect(image)
