FROM docker.io/library/debian:latest
COPY . /opt/babashka
RUN mkdir /etc/babashka && \
    ln -s /opt/babashka/dependencies /etc/babashka && \
    ln -s /opt/babashka/helpers /etc/babashka && \
    ln -s /opt/babashka/bin/babashka /usr/bin

