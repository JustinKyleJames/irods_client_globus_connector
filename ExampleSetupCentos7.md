# Setup iRODS 4.2 with Grid Community Toolkit GridFTP using B2STAGE-GridFTP in CentOS 7

## Prerequisites

Follow the instructions at https://packages.irods.org/ to add the iRODS repository to your package manager. Installation instructions can be found at https://irods.org/download/

Install iRODS 4.2 and development package on server.example.org. This includes the following packages:

* irods-server
* irods-database-plugin-postgres
* irods-dev
* irods-runtime

For 4.2, the iRODS external packages need to be installed. These provide a consistent build environment (cmake, clang, etc.) to build the GridFTP plugin.

```
sudo yum install 'irods-externals*'
```

As an iRODS admin user create the user 'user1' in iRODS.

```
iadmin mkuser user1 rodsuser
```

## Building and Installing the Grid Community Toolkit (GCT)

First install required packages:

```
sudo yum install -y autoconf automake make libtool libtool-ltdl libtool-ltdl-devel gcc gcc-c++ patch openssl openssl-devel
```

Clone the GCT repo, build and install it:

```
git clone https://github.com/gridcf/gct.git
cd gct
autoreconf -i
./configure
make
sudo make install
```

The Grid Community Toolkit will now be installed in /usr/local/globus-6.


## Building and Configuring the iRODS GridFTP Data Storage Interface (DSI)

Clone the B2STAGE-GridFTP repository and checkout the GridCF branch:

```
cd ~
git clone https://github.com/JustinKyleJames/B2STAGE-GridFTP
cd B2STAGE-GridFTP
git checkout GridCF
```

Create an /iRODS_DSI folder that will hold the output files of the build (shared object, configuration files, etc.)

```
sudo mkdir /iRODS_DSI
sudo chmod 777 /iRODS_DSI
```

Set some environment variables that are used by the build process and the PATH so that the correct version of cmake will be found.

```
export PATH=/opt/irods-externals/cmake3.11.4-0/bin:$PATH
export GLOBUS_LOCATION="/usr/local/globus-6"
export IRODS_PATH="/usr"
export DEST_LIB_DIR="/iRODS_DSI"
export DEST_BIN_DIR="/iRODS_DSI"
export DEST_ETC_DIR="/iRODS_DSI"
export IRODS_EXTERNALS_PATH=/opt/irods-externals
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/globus-6/lib
```

If you are building for iRODS 4.2, set the IRODS_42_COMPAT environment variable to true.

```
export IRODS_42_COMPAT=true
```

Now build and install the iRODS DSI:

```
cmake .
sudo -E make install
```
## Installing a Certificate Authority

Install a certificate authority using grid-ca-create. We will also read the hexidecimal ID from the certificate that is created. This will be used later.

```
export PATH=$PATH:/$GLOBUS_LOCATION/bin
cd ~
grid-ca-create -noint
HEX_ID=$(basename /usr/local/globus-6/etc/grid-security/certificates/*.0 | cut -d/ -f5 | cut -d. -f1)
grid-ca-package -r -ca ${HEX_ID}
sudo rpm -i globus-simple-ca-${HEX_ID}*.rpm
```

## Creating and Signing the Server Certificate

Create a server key and certificate signing request and place them in /etc/grid-security.

```
grid-cert-request -ca ${HEX_ID} -nopw -cn `hostname` -dir /etc/grid-security -prefix host
```

Sign the server certificate.  If you use the default configuration when creating the certificate authority the password to sign the certificate will be 'globus'.

```
grid-ca-sign -in /etc/grid-security/hostcert_request.pem -out /etc/grid-security/hostcert.pem
```

## Creating and Signing the User Certificate

First create a new user on the system.

```
sudo adduser osuser1
```

Create a user key and certificate signing request (userkey.pem and usercert_request.pem) and place these in ~osuer1/.globus.

```
sudo /usr/local/globus-6/bin/grid-cert-request -ca ${HEX_ID} -nopw -cn `hostname` -dir ~osuser1/.globus -prefix user -commonname user1
```

Sign the certificate with grid-ca-sign. If you use the default configuration when creating the certificate authority the password to sign the certificate will be 'globus'.

```
sudo /usr/local/globus-6/bin/grid-ca-sign -in ~osuser1/.globus/usercert_request.pem -out ~osuser1/.globus/usercert.pem
sudo chown osuser1:osuser1 ~osuser1/.globus/*
```

## Update Configuration Files

Create a grid-mapfile that matches the subject in the certificate to an iRODS user name. Place this grid-mapfile in both /etc/grid-security and ~/.gridmap

```
subject=`sudo openssl x509 -noout -in ~osuser1/.globus/usercert.pem -subject | cut -d= -f2- | sed -e 's| *\(.*\)|\1|g'`
echo "\"$subject\" user1" | sudo tee -a /etc/grid-security/grid-mapfile
#cp /etc/grid-security/grid-mapfile ~osuser1/.gridmap
```

Create /etc/grid-security/gridftp.conf with the following contents:

```
$LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/iRODS_DSI"
$irodsConnectAsAdmin "rods"
load_dsi_module iRODS
auth_level 4
port 2811
```

Set the LD_LIBRARY_PATH so the server can find the DSI libraries.

```
export LIBRARY_PATH=$LIBRARY_PATH:/usr/local/globus-6/lib
```

## Connect the root user to iRODS

Login as the root user and add the following to /root/.irods/irods_environment.json

```
{
    "irods_host": "localhost",
    "irods_zone_name": "tempZone",
    "irods_port": 1247,
    "irods_user_name": "rods",
    "irods_default_resource": "demoResc"
}
```

Run 'iinit' and enter the password for the rods user. This will allow the GridFTP DSI plugin to access iRODS using an administrative account.

> Note: If you run iinit without first creating the irods_environment.json file, iRODS will not ask you for the default resource and this variable will not be set. This will cause unexpected failures. If this is done, edit irods_environment.json and add in the irods_default_resource.

## Start the GridFTP Server and Test

Start the server.

```
/usr/local/globus-6/sbin/globus-gridftp-server
```
Login to osuser1.  Create a random file and test copying this file into iRODS and getting it out of iRODS.

```
# create a 1 MB test file
dd if=/dev/urandom of=file.dat bs=1000 count=1000

# put the file into irods
/usr/local/globus-6/bin/globus-url-copy file.dat gsiftp://`hostname`:2811/tempZone/home/user1/

# get the file from irods
/usr/local/globus-6/bin/globus-url-copy gsiftp://`hostname`:2811/tempZone/home/user1/file.dat file2.dat

# diff the files - these should be the same
diff file.dat file2.dat
```







