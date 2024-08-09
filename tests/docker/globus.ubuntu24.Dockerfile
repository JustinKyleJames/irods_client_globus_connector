FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true

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
    python3-pyodbc

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
RUN apt-get install -y curl \
    g++ \
    gcc \
    vim \
    ftp \
    telnet \
    libcurl4-gnutls-dev \
    unzip \
    python3 \
    python3-distro \
    python3-psutil \
    python3-jsonschema \
    python3-requests \
    python3-pip \
    python3-pyodbc

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

ADD start.globus.run.tests.ubuntu.sh /
RUN chmod u+x /start.globus.run.tests.ubuntu.sh

ADD install_local_irods_client_packages_ubuntu24.sh /install_local_irods_packages.sh
RUN chmod u+x /install_local_irods_packages.sh

ENTRYPOINT "/start.globus.run.tests.ubuntu.sh"
