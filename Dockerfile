FROM raspbian/stretch

# Build arguments
ARG VERSION
ARG CHANNEL

# Runtime environment variables
ENV MYSENSORSGW_VERSION=${VERSION} \
    MYSENSORSGW_PORT=5003 \
    MYSENSORSGW_DEBUG=disable \
    MYSENSORSGW_DEVICE=/dev/spidev0.0 \
    MYSENSORSGW_SPI_DRIVER=BCM \
    MYSENSORSGW_SOC=BCM2711 \
    MYSENSORSGW_RF24_IRQ_PIN=18

# Install MySensors dependencies
RUN apt-get update && \
    apt-get install -y \
        unzip \
        make \
	g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add start.sh and mysensors.conf; set execute permissions
COPY start.sh /start.sh
COPY mysensors.conf /etc/mysensors.conf
RUN chmod +x /start.sh 

# Add MySensors source from Github, build mysensors gw, install it
ADD https://github.com/mysensors/MySensors/archive/development.zip /root/MySensors.zip
RUN unzip /root/MySensors.zip -d /root && \
    rm -f /root/MySensors.zip && \
    cd /root/MySensors-development && \
    ./configure --my-transport=rf24 --no_init_system --prefix=/usr \
	--spi-driver=$MYSENSORSGW_SPI_DRIVER --soc=$MYSENSORSGW_SOC\
	--my-rf24-irq-pin=$MYSENSORSGW_RF24_IRQ_PIN \
	--spi-spidev-device=$MYSENSORSGW_DEVICE --my-port=$MYSENSORSGW_PORT \
	--my-debug=$MYSENSORSGW_DEBUG \
	--extra-cxxflags="-DMY_RX_MESSAlsGE_BUFFER_SIZE=\(32\) -DMY_RF24_DATARATE=\(RF24_1MBPS\)" && \
    make install && \
    cd /root && \
    rm -rf /root/MySensors-development && \
    apt-get autoremove -y g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE ${MYSENSORSGW_PORT}

CMD [ "bash", "/start.sh" ]

# Recommended start command
# docker run -d --name=mysgw --device=/dev/spidev0.0 -p 5003:5003 --restart=always --privileged lustasag/mysgw

