FROM rockylinux:9

RUN \
  dnf update -y && \
  dnf install -y \
    epel-release \
    gcc-c++ \
    gnupg \
    make \
    python3 \
    python3-pip \
    rsyslog \
    sudo \
    unixODBC \
    wget \
    which \
    diffutils \
    procps \
    rpm-build \
    pam-devel \
    libtool-ltdl \
    ftp \
    telnet \
  && \
  dnf clean all && \
  rm -rf /var/cache/dnf /tmp/*

RUN dnf -y --enablerepo=crb install libtool-ltdl-devel
RUN dnf -y install jansson

# python 2 and 3 must be installed separately because dnf will ignore/discard python2
RUN \
  dnf check-update -q >/dev/null || { [ "$?" -eq 100 ] && dnf update -y; } && \
  dnf install -y \
    python3 \
    python3-devel \
    python3-pip \
  && \
  dnf clean all && \
  rm -rf /var/cache/dnf /tmp/*

RUN python3 -m pip install xmlrunner distro psutil pyodbc jsonschema requests

#### Get and install iRODS repo ####
RUN dnf install -y \
        dnf-plugin-config-manager \
    && \
    rpm --import https://packages.irods.org/irods-signing-key.asc && \
    dnf config-manager -y --add-repo https://packages.irods.org/renci-irods.yum.repo && \
    dnf config-manager -y --set-enabled renci-irods && \
    rpm --import https://core-dev.irods.org/irods-core-dev-signing-key.asc && \
    dnf config-manager -y --add-repo https://core-dev.irods.org/renci-irods-core-dev.yum.repo && \
    dnf config-manager -y --set-enabled renci-irods-core-dev && \
    rm -rf /tmp/*

#### Install icommands - used to set up, validate and tear down tests. ####
RUN dnf install -y irods-icommands

#### Install irods-dev, cmake, clang  - used to build the connector ####
#RUN dnf install -y devtoolset-10
RUN dnf install -y irods-externals-cmake3.21.4-0
RUN dnf install -y irods-externals-clang-runtime13.0.0-0 irods-externals-clang13.0.0-0
RUN dnf install -y irods-devel

COPY rsyslog.conf /etc/rsyslog.conf

#### install basic packages ####
#RUN dnf update -y && dnf install -y epel-release
#RUN  dnf install -y apt-utils apt-transport-https unixODBC unixODBC-devel wget sudo \
#                       python python-psutil python-requests python-jsonschema \
#                       libssl-devel super lsof postgresql odbc-postgresql libjson-perl gnupg \
#                       vim rsyslog g++ dpkg-devel cdbs libcurl4-openssl-devel \
#                       tig git libpam0g-devel libkrb5-devel libfuse-devel \
#                       libbz2-devel libxml2-devel zlib1g-devel python-devel \
#                       make gcc help2man telnet ftp udt

#### Get and install globus repo ####
RUN wget -q https://downloads.globus.org/globus-connect-server/stable/installers/repo/rpm/globus-repo-latest.noarch.rpm
RUN rpm --force -i globus-repo-latest.noarch.rpm

#### Install and configure globus specific things ####
RUN dnf install -y globus-gridftp-server-progs \
    globus-simple-ca \
    globus-gass-copy-progs \
    globus-gsi-cert-utils-progs \
    globus-proxy-utils

#RUN dnf --enablerepo=resilientstorage install libtool-ltdl-devel 
#RUN dnf -y --enablerepo=crb install libtool-ltdl-devel
RUN wget -q https://dl.rockylinux.org/pub/rocky/9/CRB/x86_64/os/Packages/j/jansson-devel-2.14-1.el9.x86_64.rpm
RUN rpm --force -i jansson-devel-2.14-1.el9.x86_64.rpm 

#### Get and install globus repo ####
RUN wget -q https://downloads.globus.org/globus-connect-server/stable/installers/repo/rpm/globus-repo-latest.noarch.rpm

RUN dnf config-manager --set-disabled epel
RUN dnf install -y globus-common-devel \
    globus-gridftp-server-devel \
    globus-gridmap-callout-error-devel
RUN dnf config-manager --set-enabled epel


RUN mkdir /iRODS_DSI
RUN chmod 777 /iRODS_DSI

#### Set up ICAT database. ####
ADD db_commands.txt /
RUN dnf install -y postgresql-server postgresql-contrib
RUN su - postgres -c "pg_ctl initdb"
RUN su - postgres -c "/usr/bin/pg_ctl -D /var/lib/pgsql/data -l logfile start && sleep 1 && psql -f /db_commands.txt"

ADD start.globus.run.tests.centos7.sh /
RUN chmod u+x /start.globus.run.tests.centos7.sh

ENTRYPOINT "/start.globus.run.tests.centos7.sh"

