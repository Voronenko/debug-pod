FROM python:3.9-slim-buster

ARG DEF_REMOTE_PORT=8081
ARG DEF_LOCAL_PORT=8081

ARG VCS_REF
ARG BUILD_DATE

# Metadata
LABEL org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.name="debug-pod" \
    org.label-schema.url="https://hub.docker.com/r/voronenko/debug-pod/" \
    org.label-schema.vcs-url="https://github.com/voronenko/debug-pod" \
    org.label-schema.build-date=$BUILD_DATE


ENV REMOTE_PORT=$DEF_REMOTE_PORT
ENV LOCAL_PORT=$DEF_LOCAL_PORT

RUN echo "Installing base packages" && \
    apt update -yq && \
    apt install -yq gcc socat dnsutils curl telnet iputils-ping jq less traceroute wget lsb-release unzip

RUN pip install httpie http-prompt

RUN echo "Workaround on mongo tools deps" && \
    apt update -yq && \
    apt install -yq gnupg2 && \
    echo "deb http://security.ubuntu.com/ubuntu xenial-security main" > /etc/apt/sources.list.d/libssl100.list && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 40976EAF437D05B5 && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 3B4FE6ACC0B21F32 && \
    apt update -yq && \
    apt install -uq libssl1.0.0 && \
    rm /etc/apt/sources.list.d/libssl100.list && \
    apt update -yq

RUN echo "Installing clickhouse community cli" && \
    apt install -yq clickhouse-client && \
    pip3 install clickhouse-cli

# https://www.mongodb.com/try/download/community
RUN echo "Getting mongo binary" && \
    curl -sLo /tmp/mongo_binary.deb https://repo.mongodb.org/apt/ubuntu/dists/bionic/mongodb-org/4.0/multiverse/binary-amd64/mongodb-org-shell_4.0.24_amd64.deb && \
    dpkg-reconfigure debconf -f noninteractive -p critical && \
    dpkg -i /tmp/mongo_binary.deb && \
    rm /tmp/mongo_binary.deb

RUN echo "Getting mongodb tools" && \
    curl -sLo /tmp/mongo_tools.deb https://fastdl.mongodb.org/tools/db/mongodb-database-tools-debian10-x86_64-100.3.1.deb && \
    dpkg-reconfigure debconf -f noninteractive -p critical && \
    dpkg -i /tmp/mongo_tools.deb && \
    rm /tmp/mongo_tools.deb

RUN echo "Getting mongodb mongosh" && \
    curl -sLo /tmp/mongo_shell.deb https://downloads.mongodb.com/compass/mongodb-mongosh_0.14.0_amd64.deb && \
    dpkg-reconfigure debconf -f noninteractive -p critical && \
    dpkg -i /tmp/mongo_shell.deb && \
    rm /tmp/mongo_shell.deb

RUN echo "Installing postgres 15 client tools" && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -  && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list && \
    apt update && \
    apt install -yq postgresql-client-15 postgresql-server-dev-all python3-psycopg2 && \
    pip3 install -U pgcli

RUN echo "Installing mariadb client tools" && \
    apt install -yq mariadb-client 

# Download and install AWS CLI version 2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && ./aws/install \
  && rm -rf awscliv2.zip ./aws

# Verify the installation
RUN aws --version


WORKDIR /root

RUN curl -sSL http://bit.ly/slavkodotfiles > bootstrap.sh && chmod +x bootstrap.sh && ./bootstrap.sh docker
