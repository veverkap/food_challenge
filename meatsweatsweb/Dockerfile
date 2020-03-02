FROM registry.veverka.net/opencv:latest

EXPOSE 80

COPY ./app /app

RUN pip3 install fastapi numpy python-multipart tensorflow uvicorn --extra-index-url=https://www.piwheels.org/simple

RUN pip3 install git+https://github.com/veverkap/cvlib.git

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
