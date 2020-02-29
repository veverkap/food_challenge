FROM debian:buster

RUN apt-get update && apt-get install -y \
  build-essential cmake git pkg-config libgtk-3-dev \
  libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
  libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
  gfortran openexr libatlas-base-dev python3-dev python3-numpy \
  libtbb2 libtbb-dev libdc1394-22-dev python3-pip

RUN mkdir -p /tmp/opencv_build

RUN cd /tmp/opencv_build && \
  git clone --depth 1 https://github.com/opencv/opencv.git && \
  git clone --depth 1 https://github.com/opencv/opencv_contrib.git

RUN cd /tmp/opencv_build/opencv && \
  mkdir build && cd build && \
  cmake -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX=/usr/local \
  -D INSTALL_C_EXAMPLES=ON \
  -D INSTALL_PYTHON_EXAMPLES=ON \
  -D OPENCV_GENERATE_PKGCONFIG=ON \
  -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv_build/opencv_contrib/modules \
  -D BUILD_EXAMPLES=ON ..

RUN nproc

RUN cd /tmp/opencv_build/opencv/build && make -j$(nproc)

RUN cd /tmp/opencv_build/opencv/build && make install

RUN pkg-config --modversion opencv4



# EXPOSE 80

# COPY ./app /app

# RUN pip3 install opencv-python --upgrade

# RUN pip3 install -r app/requirements.txt --extra-index-url=https://www.piwheels.org/simple

# CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]
