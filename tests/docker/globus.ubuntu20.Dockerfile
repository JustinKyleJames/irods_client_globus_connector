FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true

#### Get and install iRODS repo ####
RUN apt-get update && apt-get install -y wget gnupg2 lsb-release
RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | apt-key add -
RUN echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/renci-irods.list
RUN apt-get update

#### Install icommands - used to set up, validate and tear down tests. ####
#RUN apt-get install -y irods-icommands

#### Install irods-dev, cmake, clang  - used to build the connector ####
RUN apt-get install -y irods-externals-cmake3.21.4-0
RUN apt-get install -y irods-externals-clang*
#RUN apt-get install -y irods-dev

#### install basic packages ####
RUN apt-get update && apt-get install -y curl \
    vim \
    ftp \
    telnet \
    libcurl4-openssl-dev \
    unzip \
    python3 \
    python3-distro \
    python3-psutil \
    python3-jsonschema \
    python3-requests \
    python3-pip \
    python3-pyodbc \
    sudo \
    libfuse2 \
    libcurl3-gnutls \
    lsof

#### Get and install globus repo ####
RUN wget -q https://downloads.globus.org/globus-connect-server/stable/installers/repo/deb/globus-repo_latest_all.deb
RUN dpkg -i globus-repo_latest_all.deb
RUN apt-get update

#### Install and configure globus specific things ####
RUN apt-get install -y globus-gridftp-server-progs \
    globus-simple-ca \
    globus-gass-copy-progs \
    libglobus-common-dev \
    libglobus-gridftp-server-dev \
    libglobus-gridmap-callout-error-dev \
    globus-gsi-cert-utils-progs \
    globus-proxy-utils

RUN mkdir /iRODS_DSI
RUN chmod 777 /iRODS_DSI

#### Get and install iRODS repo ####
#RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | sudo apt-key add -
#RUN echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/renci-irods.list
#RUN apt-get update

RUN apt-get install irods-externals-avro-libcxx1.11.0-3 irods-externals-boost-libcxx1.81.0-1 irods-externals-fmt-libcxx8.1.1-1 irods-externals-nanodbc-libcxx2.13.0-2 irods-externals-zeromq4-1-libcxx4.1.8-1 irods-externals-spdlog-libcxx1.9.2-2 irods-externals-libarchive3.5.2-0 irods-externals-catch22.13.8-0 irods-externals-cppzmq4.8.1-1 irods-externals-json3.10.4-0 irods-externals-catch22.13.8-0 irods-externals-cppzmq4.8.1-1 irods-externals-json3.10.4-0

ADD start.globus.run.tests.ubuntu.sh /
RUN chmod u+x /start.globus.run.tests.ubuntu.sh

ADD install_local_irods_client_packages_ubuntu20.sh /install_local_irods_packages.sh
RUN chmod u+x /install_local_irods_packages.sh

ENTRYPOINT "/start.globus.run.tests.ubuntu.sh"
