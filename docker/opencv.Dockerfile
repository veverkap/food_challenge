ARG RASPBIAN_VERSION=buster
FROM balenalib/rpi-raspbian:$RASPBIAN_VERSION

ARG RASPBIAN_VERSION
ARG DEBIAN_FRONTEND=noninteractive

# install opencv3 as detailied in: https://www.pyimagesearch.com/2017/09/04/raspbian-stretch-install-opencv-3-python-on-your-raspberry-pi/

# update apt
RUN apt-get update \
  && apt-get install -y --no-install-recommends apt-utils \
  # install necessary build tools \
  && apt-get -qy install build-essential cmake pkg-config unzip wget \
  # install necessary libraries \
  && apt-get -qy install \
  libjpeg-dev \
  libtiff5-dev \
  libjasper-dev \
  libpng12-dev \
  libavcodec-dev \
  libavformat-dev \
  libswscale-dev \
  libv4l-dev \
  libxvidcore-dev \
  libx264-dev \
  #Had to break the install into chunks as the deps wouldn't resolve.  \
  && apt-get -qy install \
  libgtk2.0-dev \
  libgtk-3-dev \
  libatlas-base-dev \
  gfortran \
  python3-dev \
  python3-pip \
  python3-numpy \
  libraspberrypi0 \
  python3-setuptools \
  # cleanup apt. \
  && apt-get purge -y --auto-remove \
  && rm -rf /var/lib/apt/lists/*

ARG OPENCV_VERSION=4.2.0
ENV OPENCV_VERSION $OPENCV_VERSION

# download latest source & contrib
RUN	cd /tmp \
  && wget -c -N -nv -O opencv.zip https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip \
  && unzip opencv.zip \
  && wget -c -N -nv -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip \
  && unzip opencv_contrib.zip \
  # build opencv \
  && cd /tmp/opencv-$OPENCV_VERSION \
  && mkdir build \
  && cd build \
  && cmake -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX=/usr/local \
  -D INSTALL_C_EXAMPLES=ON \
  -D BUILD_PYTHON_SUPPORT=ON \
  -D BUILD_NEW_PYTHON_SUPPORT=ON \
  -D INSTALL_PYTHON_EXAMPLES=ON \
  -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv_contrib-$OPENCV_VERSION/modules \
  -D BUILD_EXAMPLES=ON .. \
  && make -j4  \
  && make \
  && make install\
  # ldconfig && \
  && make clean \
  # cleanup source \
  && cd / \
  && rm -rf /tmp/* \
  && date \
  && echo "Raspbian $RASPBIAN_VERSION - OpenCV $OPENCV_VERSION Docker Build finished."

CMD ["/bin/bash"]
