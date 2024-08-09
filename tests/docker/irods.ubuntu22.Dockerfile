FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true

#### install basic packages ####
RUN apt-get update && \
    apt-get install -y apt-utils apt-transport-https unixodbc unixodbc-dev wget lsb-release sudo \
                       libssl-dev super lsof postgresql odbc-postgresql libjson-perl gnupg \
                       vim sudo rsyslog g++ dpkg-dev cdbs libcurl4-openssl-dev \
                       tig git libpam0g-dev libkrb5-dev libfuse-dev \
                       libbz2-dev libxml2-dev zlib1g-dev \
                       make gcc help2man telnet ftp

RUN apt-get install -y python3 \
    python3-distro \
    python3-psutil \
    python3-jsonschema \
    python3-requests \
    python3-pip \
    python3-pyodbc \
    python3-dev 

#### Get and install iRODS repo ####
RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | sudo apt-key add -
RUN echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/renci-irods.list
RUN apt-get update

#### Install iRODS ####
#ARG irods_version
#ENV IRODS_VERSION ${irods_version}
ENV irods_version 4.3.1-0~jammy

#RUN apt-get install -y irods-server=${irods_version} irods-dev=${irods_version} irods-database-plugin-postgres=${irods_version} irods-runtime=${irods_version} irods-icommands=${irods_version}
#RUN dpkg -i /irods_packages/irods-database-plugin-postgres_4.3.3-0~jammy_amd64.deb /irods_packages/irods-dev_4.3.3-0~jammy_amd64.deb /irods_packages/irods-icommands_4.3.3-0~jammy_amd64.deb /irods_packages/irods-runtime_4.3.3-0~jammy_amd64.deb /irods_packages/irods-server_4.3.3-0~jammy_amd64.deb

#### Set up ICAT database. ####
ADD db_commands.txt /
RUN service postgresql start && su - postgres -c 'psql -f /db_commands.txt'

#RUN apt-get install -y irods-externals-avro-libcxx1.11.0-3 irods-externals-boost-libcxx1.81.0-1 irods-externals-nanodbc-libcxx2.13.0-2 irods-externals-zeromq4-1-libcxx4.1.8-1 irods-externals-spdlog-libcxx1.9.2-2 irods-externals-libarchive3.5.2-0 irods-externals-clang-runtime13.0.1-0 

ADD start.irods.ubuntu22.sh /
RUN chmod u+x /start.irods.ubuntu22.sh
ENTRYPOINT "/start.irods.ubuntu22.sh"
