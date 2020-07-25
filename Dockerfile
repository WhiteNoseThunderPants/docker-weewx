FROM phusion/baseimage:focal-1.0.0alpha1-arm64

ENV HOME=/home/weewx

# current versions
ENV WEEWX_VERSION=4.1.1
ENV BELCHERTOWN_VERSION=1.1

# download URLs
ENV WEEWX_URL=http://weewx.com/downloads/weewx-$WEEWX_VERSION.tar.gz
ENV BELCHERTOWN_URL=https://github.com/poblabs/weewx-belchertown/releases/download/weewx-belchertown-$BELCHERTOWN_VERSION/weewx-belchertown-release-$BELCHERTOWN_VERSION.tar.gz
ENV INFLUX_URL=https://github.com/matthewwall/weewx-influx/archive/master.zip
ENV SFTP_URL=https://github.com/matthewwall/weewx-sftp/archive/master.zip
ENV MQTT_URL=https://github.com/matthewwall/weewx-mqtt/archive/master.zip
ENV WEATHERBUG_URL=https://github.com/matthewwall/weewx-wbug/archive/master.zip
ENV WEATHERCLOUD_URL=https://github.com/matthewwall/weewx-wcloud/archive/master.zip
ENV WINDY_URL=https://github.com/matthewwall/weewx-windy/archive/master.zip
ENV SDR_URL=https://github.com/matthewwall/weewx-sdr/archive/master.zip
ENV BME280_URL=https://gitlab.com/wjcarpenter/bme280wx/-/archive/master/bme280wx-master.zip

# make sure system is up to date
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y apt-utils

# set timezone
ENV TZ=America/Chicago
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install requirements
RUN apt-get install -y python3 python3-pil python3-pip python3-configobj python3-serial python3-usb python3-paho-mqtt python3-cheetah python3-ephem python3-setuptools python3-cffi python3-wheel python3-paramiko python3-libnacl python3-nacl
RUN pip3 install bme280 smbus2 RPi.bme280 Rpi.GPIO pysftp
RUN apt-get install -y sqlite3 curl rsync ssh tzdata wget gftp syslog-ng rtl-sdr rtl-433 i2c-tools
RUN ln -f -s /usr/bin/python3 /usr/bin/python
RUN mkdir /var/log/weewx
RUN pip3 install requests

# install weewx from source
RUN cd /tmp
RUN wget $WEEWX_URL -O weewx.tar.gz
RUN tar xvf weewx.tar.gz
RUN cd /tmp/weewx-$WEEWX_VERSION
RUN ./setup.py install --no-prompt -O2

# download weewx extensions
RUN cd /tmp
RUN wget -O /tmp/weewx-belchertown.tgz $BELCHERTOWN_URL
RUN wget -O /tmp/weewx-influx.zip $INFLUX_URL
RUN wget -O /tmp/weewx-sftp.zip $SFTP_URL
RUN wget -O /tmp/weewx-mqtt.zip $MQTT_URL
RUN wget -O /tmp/weewx-wbug.zip $WEATHERBUG_URL
RUN wget -O /tmp/weewx-wcloud.zip $WEATHERCLOUD_URL
RUN wget -O /tmp/weewx-windy.zip $WINDY_URL
RUN wget -O /tmp/weewx-sdr.zip $SDR_URL
RUN wget -O /tmp/weewx-bme280wx.zip $BME280_URL

# install weewx extensions
RUN bin/wee_extension --install /tmp/weewx-belchertown.tgz
RUN bin/wee_extension --install /tmp/weewx-influx.zip
RUN bin/wee_extension --install /tmp/weewx-sftp.zip
RUN bin/wee_extension --install /tmp/weewx-mqtt.zip
RUN bin/wee_extension --install /tmp/weewx-wbug.zip
RUN bin/wee_extension --install /tmp/weewx-wcloud.zip
RUN bin/wee_extension --install /tmp/weewx-windy.zip
RUN bin/wee_extension --install /tmp/weewx-sdr.zip
RUN bin/wee_extension --install /tmp/weewx-bme280wx.zip

# create weewx directories
RUN mkdir /home/weewx/tmp
RUN mkdir /home/weewx/public_html
RUN mkdir /home/weewx/config

# copy conf file to better directory for volume mapping
RUN cp /home/weewx/weewx.conf /home/weewx/config/

# create service directory
RUN mkdir -p /etc/service/weewx

# copy run file to service directory and set permissions
ADD bin/run /etc/service/weewx/
RUN chmod 755 /etc/service/weewx/run

# clean up install files
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# run the container
CMD ["/sbin/my_init"]
