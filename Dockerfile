FROM ubuntu:latest 
MAINTAINER Matteo Triggiani <davvore33@gmail.com>

# Install build tools
RUN apt update && apt upgrade -yy
RUN apt install -yy \
        automake            \
        bison               \
        curl                \
        file                \
        flex                \
        git                 \
        libtool             \
        pkg-config          \
        python              \
        texinfo             \
        vim                 \
        wget

# Install osxcross
# NOTE: The Docker Hub's build machines run varying types of CPUs, so an image
# built with `-march=native` on one of those may not run on every machine - I
# ran into this problem when the images wouldn't run on my 2013-era Macbook
# Pro.  As such, we remove this flag entirely.
ENV OSXCROSS_SDK_VERSION 10.8
#RUN mkdir /opt/osxcross 
RUN cd /opt; git clone https://github.com/tpoechtrager/osxcross.git && \
	cd osxcross; \
	git checkout ee54d9fd43b45947ee74c99282b360cd27a8f1cb
WORKDIR /opt/osxcross
RUN sed -i -e 's|-march=native||g' ./build_clang.sh ./wrapper/build.sh 
RUN ./tools/get_dependencies.sh 
RUN curl -L -o ./tarballs/MacOSX${OSXCROSS_SDK_VERSION}.sdk.tar.xz  https://s3.amazonaws.com/andrew-osx-sdks/MacOSX${OSXCROSS_SDK_VERSION}.sdk.tar.xz 
RUN yes | PORTABLE=true ./build.sh 
ENV JOBS=12
RUN ./build_compiler_rt.sh

ENV PATH $PATH:/opt/osxcross/target/bin
CMD /bin/bash
