FROM docker.io/library/debian:latest
RUN apt-get update && \
    apt-get install -y lsb-release
ADD https://git.io/get-mo /usr/bin/mo
COPY . /opt/babashka
RUN mkdir /etc/babashka && \
    ln -s /opt/babashka/dependencies /etc/babashka && \
    ln -s /opt/babashka/helpers /etc/babashka && \
    ln -s /opt/babashka/bin/babashka /usr/bin && \
    chmod +x /usr/bin/mo
