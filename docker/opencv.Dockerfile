FROM python:3.7

RUN apt-get update \
  && apt-get install -y \
  libtiff5 \
  libpango-1.0-0 \
  libavcodec58 \
  libgdk-pixbuf2.0-0 \
  libjasper1 \
  libqt4-test \
  libpangocairo-1.0-0 \
  libswscale5 \
  libilmbase23 \
  libatk1.0-0 \
  libgtk-3-0 \
  libqtcore4 \
  libcairo2 \
  libwebp6 \
  libavutil56 \
  libcairo-gobject2 \
  libopenexr23 \
  libqtgui4 \
  libavformat58 \
  && rm -rf /var/lib/apt/lists/*

RUN pip install numpy opencv-python --extra-index-url=https://www.piwheels.org/simple
