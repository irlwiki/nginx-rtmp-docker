FROM nginx:stable-alpine AS builder

RUN apk add --no-cache --virtual .build-deps \
     git \
     gcc \
     libc-dev \
     make \
     openssl-dev \
     pcre-dev \
     zlib-dev \
     linux-headers \
     libxslt-dev \
     gd-dev \
     geoip-dev \
     perl-dev \
     libedit-dev \
     mercurial \
     bash \
     alpine-sdk \
     findutils && \
    wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
    git clone https://github.com/arut/nginx-rtmp-module /tmp/nginx-rtmp-module && \
    CONFARGS=$(nginx -V 2>&1 | sed -n -e "s/^.*arguments: //" -e "s/--with-cc-opt='.*'/--with-cc-opt='-Os -fomit-frame-pointer -Wimplicit-fallthrough=0'/p") && \
    tar -zxC /tmp -f nginx.tar.gz && \
    cd /tmp/nginx-$NGINX_VERSION && \
    sh -c "./configure --with-compat --add-dynamic-module=/tmp/nginx-rtmp-module $CONFARGS" && \
    make modules -j$(nproc) && \
    mv ./objs/*.so /

FROM nginx:alpine
COPY --from=builder /ngx_rtmp_module.so /usr/lib/nginx/modules/