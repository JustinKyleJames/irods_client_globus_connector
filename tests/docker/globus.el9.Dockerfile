FROM rockylinux:9

RUN \
  yum update -y && \
  yum install -y \
    pam-devel \
    python3-jsonschema \
    epel-release \
    gcc-c++ \
    gnupg \
    make \
    python3 \
    python3-pip \
    rsyslog \
    sudo \
    wget \
    which \
    diffutils \
    procps \
    rpm-build \
  && \
  yum clean all && \
  rm -rf /var/cache/yum /tmp/*

RUN dnf -y install jansson
RUN rpm --force -i https://dl.rockylinux.org/pub/rocky/9/CRB/x86_64/os/Packages/j/jansson-devel-2.14-1.el9.x86_64.rpm
RUN dnf -y --enablerepo=crb install libtool-ltdl-devel

# python 2 and 3 must be installed separately because yum will ignore/discard python2
RUN \
  yum check-update -q >/dev/null || { [ "$?" -eq 100 ] && yum update -y; } && \
  yum install -y \
    python3 \
    python3-devel \
    python3-pip \
  && \
  yum clean all && \
  rm -rf /var/cache/yum /tmp/*

RUN python3 -m pip install xmlrunner distro psutil pyodbc jsonschema requests

RUN rpm --import https://packages.irods.org/irods-signing-key.asc && \
    wget -qO - https://packages.irods.org/renci-irods.yum.repo | tee /etc/yum.repos.d/renci-irods.yum.repo

RUN rpm --import https://core-dev.irods.org/irods-core-dev-signing-key.asc && \
    wget -qO - https://core-dev.irods.org/renci-irods-core-dev.yum.repo | tee /etc/yum.repos.d/renci-irods-core-dev.yum.repo

#### Get and install globus repo ####
RUN wget -q https://downloads.globus.org/globus-connect-server/stable/installers/repo/rpm/globus-repo-latest.noarch.rpm
RUN rpm --force -i globus-repo-latest.noarch.rpm

#### Install and configure globus specific things ####
RUN yum install -y globus-gridftp-server-progs \
    globus-simple-ca \
    globus-gass-copy-progs \
    globus-gsi-cert-utils-progs \
    globus-proxy-utils

RUN yum --disablerepo epel install -y globus-common-devel \
    globus-gridftp-server-devel \
    globus-gridmap-callout-error-devel

RUN mkdir /iRODS_DSI
RUN chmod 777 /iRODS_DSI

#### Install iRODS ####
#### Install icommands - used to set up, validate and tear down tests. ####
#RUN yum install -y irods-icommands

#### Install irods-dev, cmake, clang  - used to build the connector ####
RUN yum install -y irods-externals-cmake3.21.4-0
RUN yum install -y irods-externals-clang*

RUN dnf config-manager --set-enabled crb
RUN dnf -y install unixODBC-devel krb5-devel

ADD start.globus.run.tests.el.sh /
RUN chmod u+x /start.globus.run.tests.el.sh

ADD install_local_irods_client_packages_el9.sh /install_local_irods_packages.sh
RUN chmod u+x /install_local_irods_packages.sh

ENTRYPOINT "/start.globus.run.tests.el.sh"

