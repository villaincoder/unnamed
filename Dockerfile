FROM ubuntu:18.04 AS build_nginx

RUN apt update && \
    apt install -y --fix-missing \
        gcc \
        build-essential \
        libssl-dev \
        libpcre3-dev \
        zlib1g-dev

ADD nginx-1.18.0.tar.gz /root
ADD nginx-rtmp-module-1.2.1.tar.gz /root

RUN cd /root/nginx-1.18.0 && \
    ./configure \
        --add-module=/root/nginx-rtmp-module-1.2.1 \
        --with-http_ssl_module \
        --with-threads \
        --with-file-aio \
        --with-cc-opt="-Wimplicit-fallthrough=0" \
        --with-debug && \
    make && \
    make install



FROM ubuntu:18.04 AS build_ffmpeg

RUN apt update && \
    apt install -y --fix-missing \
        gcc \
        build-essential \
        yasm \
        libssl-dev \
        libass-dev \
        libfdk-aac-dev \
        libmp3lame-dev \
        libopus-dev \
        libtheora-dev \
        libvorbis-dev \
        libvpx-dev \
        libwebp-dev \
        libx264-dev \
        libx265-dev

ADD ffmpeg-4.2.3.tar.bz2 /root

RUN cd /root/ffmpeg-4.2.3 && \
    ./configure \
        --enable-version3 \
        --enable-gpl \
        --enable-nonfree \
        --enable-small \
        --enable-libmp3lame \
        --enable-libx264 \
        --enable-libx265 \
        --enable-libvpx \
        --enable-libtheora \
        --enable-libvorbis \
        --enable-libopus \
        --enable-libfdk-aac \
        --enable-libass \
        --enable-libwebp \
        --enable-postproc \
        --enable-avresample \
        --enable-libfreetype \
        --enable-openssl \
        --disable-debug \
        --disable-doc \
        --disable-ffplay \
        --extra-libs="-lpthread -lm"  && \
    make && \
    make install



FROM ubuntu:18.04

RUN apt update && \
    apt install -y --fix-missing \
        libpcre32-3 \
        openssl \
        libass9 \
        libvpx5 \
        libmp3lame0 \
        libwebpmux3 \
        libfdk-aac1 \
        libopus0 \
        libtheora0 \
        libvorbis0a \
        libvorbisenc2 \
        libx264-152 \
        libx265-146 && \
    apt autoclean && \
    apt autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/*

COPY --from=build_ffmpeg /usr/local /usr/local
COPY --from=build_nginx /usr/local/nginx /usr/local/nginx

COPY nginx.conf /usr/local/nginx/conf/nginx.conf
COPY ffmpeg_push.sh /opt/

RUN addgroup --system --gid 101 nginx && \
    adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx

RUN mkdir -p /var/log/nginx && \
    mkdir -p /opt/data && \
    mkdir /www && \
    ln -sf /usr/local/nginx/sbin/nginx /usr/sbin/nginx && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    chmod +x /opt/ffmpeg_push.sh && \
    chown -R nginx:nginx /opt

CMD ["nginx", "-g", "daemon off;"]