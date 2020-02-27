FROM python:3.7

# RUN apt-get update && apt-get -y install libatlas3-base libwebp6 libtiff5 libjasper1 libilmbase12 libopenexr22 libilmbase12 libgstreamer1.0-0 libavcodec57 libavformat57 libavutil55 libswscale4 libqtgui4 libqt4-test libqtcore4

EXPOSE 80

COPY ./app /app

RUN pip install -r app/requirements.txt --extra-index-url=https://www.piwheels.org/simple

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
