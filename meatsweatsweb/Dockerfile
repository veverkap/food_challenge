FROM registry.veverka.net/opencv:latest

EXPOSE 80

COPY ./app /app

RUN pip3 install cvlib fastapi numpy python-multipart tensorflow uvicorn --extra-index-url=https://www.piwheels.org/simple

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
