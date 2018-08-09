FROM ubuntu:18.04 as builder
MAINTAINER Jozef Knaperek <jozef.knaperek@01cryptohouse.com>

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		wget \
		gcc-7 \
		g++-7 \
		cmake \
		make \
		miniupnpc \
		libminiupnpc-dev \
		ninja-build \
		libbz2-dev \
		libdb++-dev \
		libdb-dev \
		libssl-dev \
		libcurl4-openssl-dev \
		openssl \
		libreadline-dev \
		autoconf \
		libtool \
		doxygen \
		uuid-dev \
		zip \
		build-essential \
		python-dev \
		autotools-dev \
		libicu-dev \
		automake \
		ncurses-dev \
		nodejs \
		npm \
		git \
		libboost-all-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz \
	&& tar -xvzf db-4.8.30.NC.tar.gz \
	&& cd db-4.8.30.NC/build_unix \
	&& ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=/root/linux_depends \
	&& make \
	&& make install

COPY . /src
WORKDIR /src/src/

# Use BUILD=Release for production builds
ARG BUILD=Debug

# Fill these args from version control system in your build script
ARG REVISION_SHA=a1b2c3d4
ARG REVISION_TIMESTAMP=1521619797

RUN BDB_INCLUDE_PATH=/root/linux_depends/include/ BDB_LIB_PATH=/root/linux_depends/lib/ make -f makefile.linux


##### Runner ######
FROM ubuntu:18.04
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		libcurl3 \
		libboost-all-dev \
		miniupnpc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG uid=1000
ARG gid=1000

RUN groupadd --gid $gid -r capricoin && useradd --uid $uid --create-home --system -g capricoin capricoin

COPY --from=builder /src/src/Capricoind /usr/local/bin/
COPY docker-entrypoint.sh /usr/local/bin/entrypoint.sh

ENV CAPRICOIN_DATA=/data
RUN mkdir "$CAPRICOIN_DATA" \
	&& chown -R capricoin:capricoin "$CAPRICOIN_DATA" \
	&& ln -sfn "$CAPRICOIN_DATA" /home/capricoin/.Capricoin \
	&& chown -h capricoin:capricoin /home/capricoin/.Capricoin

VOLUME /data

USER capricoin
WORKDIR /home/capricoin

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/Capricoind"]

EXPOSE 22714
# RPC port is 22713