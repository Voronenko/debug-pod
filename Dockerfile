FROM debian:buster-slim

ARG DEF_REMOTE_PORT=8081
ARG DEF_LOCAL_PORT=8081

ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.name="cdci-port-forward" \
      org.label-schema.url="https://hub.docker.com/r/voronenko/debug-pod/" \
      org.label-schema.vcs-url="https://github.com/voronenko/debug-pod" \
      org.label-schema.build-date=$BUILD_DATE


ENV REMOTE_PORT=$DEF_REMOTE_PORT
ENV LOCAL_PORT=$DEF_LOCAL_PORT

RUN echo "Installing base packages" && \
    apt update -yq && \
    apt install -yq socat dnsutils curl telnet clickhouse-client

RUN echo "Getting mongodb tools" && \
    curl -sLo /tmp/mongo_tools.deb https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian10-x86_64-100.3.1.deb && \
    dpkg-reconfigure debconf -f noninteractive -p critical && \
    dpkg -i /tmp/mongo_tools.deb
