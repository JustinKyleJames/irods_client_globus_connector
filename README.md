irods_client_globus_connector
=============================

This is the iRODS Globus Connector.

GridFTP is a high-performance, secure, reliable data transfer protocol which provides remote access to data stores.
There are many different types of data storage systems from standard file systems to arrays of magnetic tape: to allow GridFTP to be used with as many data storage systems as possible, the GridFTP can be extended, implementing an interface called Data Storage Interface (DSI).

The iRODS Globus Connector is a DSI that consists of C functions which can interact with iRODS through the iRODS C API. The main supported operations are get, put, delete, and list.

![Alt text](/images/iRODS-DSI.png?raw=true "iRODS Globus Connector")

Once installed and configured, users will be able to interact with iRODS through
any GridFTP client passing to it a valid iRODS path; for instance:
```
$ globus-url-copy -list gsiftp://develvm.cluster.cineca.it:2811/tempZone/home/myuser/
```

will list the content of the `/tempZone/home/myuser/` iRODS collection.

The module can be loaded by the GridFTP server at start-up time through a specific command line option. Therefore, no changes are required in the GridFTP server installation. The decoupling from the possible future changes to the server simplifies the maintenance of the software module.

Install From Pre-Built Packages
===============

The Globus plugin for iRODS can be installed from pre-built packages.

- First, the iRODS repos need to be installed into your package manager.  See the instructions at https://packages.irods.org/ to do this.

- Install the packages as follows:

	Ubuntu:
	```
	sudo apt-get install irods-gridftp-client
	```

	CentOS:
	```
	sudo yum -y install irods-gridftp-client
	```

- The pre-built packages install the lib files in /usr/lib, the configuration file in /etc/grid-security, and the test binary programs in /usr/bin.



Building the Plugin and Installing in Custom Location
===============

Prerequisites
--------------------------------
- CMake 2.7 or higher (part of irods-externals in iRODS 4.2.X)

- iRODS with the Development Tools and Runtime Libraries packages: follow the instructions at https://packages.irods.org/ to add the iRODS repository to your package manager. Installation instructions can be found at https://irods.org/download/

- For 4.2, the iRODS external packages need to be installed. These provide a consistent build environment (cmake, clang, etc.) to build the iRODS Globus Connector:

	Ubuntu:
	```
	sudo apt-get -y install irods-externals-cmake3.21.4-0 irods-externals-clang13.0.0-0 irods-dev irods-runtime
	```

	CentOS:
	sudo yum -y install irods-externals-cmake3.21.4-0 irods-externals-clang13.0.0-0 irods-devel irods-runtime rpm-build
	```

- Globus and other packages:

	Ubuntu:
	```
	curl -LOs http://downloads.globus.org/toolkit/gt6/stable/installers/repo/deb/globus-toolkit-repo_latest_all.deb
	sudo dpkg -i globus-toolkit-repo_latest_all.deb
	sudo sed -i /etc/apt/sources.list.d/globus-toolkit-6-stable*.list \
		-e 's/\^# deb /deb /'
	sudo sed -i /etc/apt/sources.list.d/globus-connect-server-stable*.list \
		-e 's/^# deb /deb /'
	sudo apt-key add /usr/share/globus-toolkit-repo/RPM-GPG-KEY-Globus
	sudo apt update
	sudo apt-get install -y globus-gridftp-server-progs globus-gass-copy-progs libglobus-gss-assist-dev
	sudo apt-get install -y libglobus-common-dev libglobus-gridftp-server-dev libglobus-gridmap-callout-error-dev
	sudo apt-get install -y libcurl4-openssl-dev
	sudo apt-get install -y git
	sudo apt-get install -y g++
	sudo apt-get install -y dpkg-dev
	sudo apt-get install -y cdbs
	sudo apt-get install -y globus-gsi-cert-utils-progs
	sudo apt-get install -y globus-proxy-utils
	```

	CentOS:
	```
	sudo yum install -y epel-release
	sudo yum install -y https://downloads.globus.org/globus-connect-server/stable/installers/repo/rpm/globus-repo-latest.noarch.rpm
	sudo yum install -y globus-gridftp-server-progs globus-gass-copy-progs
	sudo yum --disablerepo epel install -y globus-common-devel globus-gridftp-server-devel globus-gridmap-callout-error-devel
	sudo yum install -y libcurl-devel git gcc-c++ make
	sudo yum install -y globus-gsi-cert-utils-progs
	sudo yum install -y globus-proxy-utils
	```


Building iRODS Globus Connector with CMake
--------------------------------

1. Clone this repository:
	```
	git clone https://github.com/irods/irods_client_globus_connector.git
	```

2. Create a deployment folder:
	```
	mkdir /<preferred_path>
	```

3. Set the `PATH` so that the correct version of cmake will be found:
	```
	export PATH=/opt/irods-externals/cmake3.21.4-0/bin:$PATH
	```

4. (Optional) Set some additional variables if desired/necessary:
	```
	export GLOBUS_LOCATION="/<preferred_path>"
	export DEST_LIB_DIR="/<preferred_path>"
	export DEST_BIN_DIR="/<preferred_path>"
	export DEST_ETC_DIR="/<preferred_path>"
	```

	In Ubuntu you may need to set up C_INCLUDE_PATH so that the `globus_config.h` header can be found:
	```
	export C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu/globus
	```
	or
	```
	export C_INCLUDE_PATH=/usr/include/globus
	```

5. Build and install the iRODS Globus Connector:
	```
	cd irods_client_globus_connector
	mkdir build
	cd build
	cmake ..
	```

6. Install or build the package
	```
	make install
	```
	or
	```
	make package
	```

Configuring the GridFTP server and run
===============

1. As the user who runs the GridFTP server, create the file `~/.irods/irods_environment.json` (or `~/.irods/.irodsEnv` for iRODS < 4.1.x) and populate it with the information related to a "rodsadmin" user; for instance:
	```
	{
	   "irods_host" : "irods4",
	   "irods_port" : 1247,
	   "irods_user_name" : "rods",
	   "irods_zone_name" : "tempZone",
	   "irods_default_resource" : "demoResc"
	}
	```
	Note that the `"irods_host"` and `"irods_port"` identify the iRODS server that the iRODS Globus Connector will contact during each request. Be sure to set the `irods_default_resource`, this variable is not set when you create the file with `iinit` or when you copy it over from another user.

2. As the user who runs the GridFTP server, try an `ils` icommand to verify that the information set in the `irods_environment.json` are fine. If needed, perform an `iinit` to authenticate the iRODS user.

3. Update the gridftp.conf file, typically in `$GLOBUS_LOCATION/etc/gridftp.conf`.

- If the plugin was installed via pre-built packages:
	```
	$irodsConnectAsAdmin "rods"
	$spOption irods_client_globus_connector
	load_dsi_module iRODS
	auth_level 4
	```
- If the plugin was built and the user set DEST_LIB_DIR to /<preferred_path>
	```
	$LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/<preferred_path>"
	$irodsConnectAsAdmin "rods"
	$spOption irods_client_globus_connector
	load_dsi_module iRODS
	auth_level 4
	```
	In case the GridFTP is run as a system service, also set the $HOME env variable pointing to the home folder of the user who runs the gridftp server:
	```
	$HOME /path/to/user/home
	```

	The $spOption setting allows the `ips` command to properly report agents as being spawned by a connection from the iRODS Globus Connector. This environment variable can be set to whatever string is appropriate for your setup.

	The following is example output of `ips` when $spOption is set to "irods_client_globus_connector":

	```
	# ips
	Server: localhost
	     7814 rods#tempZone  0:00:13  irods_client_globus_connector  127.0.0.1
	     7845 rods#tempZone  0:00:00  ips  127.0.0.1
	```

4. If the plugin was built and the user set the DEST_LIB_DIR to /<preferred_path>, add the following line at the beginning of the `globus-gridftp-server` (usually `/etc/init.d/globus-gridftp-server`) file. (This is not required if installing from pre-built packages.)
	```
	export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/<preferred_path>/"
	```

5. When deploying the Globus Connector with iRODS 4.1, it is necessary to load the GridFTP server library alongside the DSI library by adding the following lines at the beginning of the `globus-gridftp-server`  (usually `/etc/init.d/globus-gridftp-server`) file:

	Ubuntu:
	```
	export LD_PRELOAD="$LD_PRELOAD:/usr/lib/x86_64-linux-gnu/libglobus_gridftp_server.so:/libglobus_gridftp_server_iRODS.so"
	```

	CentOS:
	```
	export LD_PRELOAD="$LD_PRELOAD:/usr/lib64/libglobus_gridftp_server.so:/libglobus_gridftp_server_iRODS.so"
	```

6. Run the server with:
	```
	/etc/init.d/globus-gridftp-server restart
	```


Additional configuration
--------------------------------

1. Optionally, it is possible to enable the iRODS Globus Connector to manage the input path as a PID: the iRODS Globus Connector will try to resolve the PID and perform the requested operation using the URI returned by the Handle server (currently only listing and downloading is supported).
	For instance:
	```
	globus-url-copy -list  gsiftp://develvm01.pico.cineca.it:2811/11100/da3dae0a-6371-11e5-ba64-a41f13eb32b2/
	```
	will return the list of objects contained in the collection to which the PID "11100/da3dae0a-6371-11e5-ba64-a41f13eb32b2/" points, or:
	```
	globus-url-copy gsiftp://develvm01.pico.cineca.it:2811/11100/xa3dae0a-6371-11e5-ba64-a41f13eb32b1 /test.txt
	```
	will download the object pointed by the PID "11100/xa3dae0a-6371-11e5-ba64-a41f13eb32b1".

	If the PID resolution fails (either because the Handle server cannot resolve the PID or because the path passed as input is not a PID) the iRODS Globus Connector will try to perform the requested operation anyway, using the original input path. This guarantees that the iRODS Globus Connector can accept both PIDs and standard iRODS paths.

	To enable the PID resolution export the address of your handle-resolver to the GridFTP configuration file (typically `$GLOBUS_LOCATION/etc/gridftp.conf`):
	```
	$pidHandleServer "http://hdl.handle.net/api/handles"
	```
	If you are using a different resolver than the global handle resolver, replace `hdl.handle.net` with the correct address.

	Note: Once the PID is correctly resolved, the requested operation (listing or downloading) will be correctly performed only if the URI returned by the Handle server is a valid iRODS path pointing to the iRODS instance to which the iRODS Globus Connector is connected to.

2. If desired, change the default home directory by setting the homeDirPattern environment variable in
	```
	$GLOBUS_LOCATION/etc/gridftp.conf
	```
	The pattern can reference up to two strings with `%s`, first gets substituted with the zone name, second with the user name.  The default pattern is `"/%s/home/%s"`, making the default directory `/<zone>/home/<username>`.

	Default configuration:
	```
	$homeDirPattern "/%s/home/%s"
	```

	Example alternative configuration (defaulting to `/<zone>/home`):
	```
	$homeDirPattern "/%s/home"
	```

3. It is possible to specify a policy to manage more than one iRODS resource setting the irodsResourceMap environment variable in `$GLOBUS_LOCATION/etc/gridftp.conf`.
	```
	$irodsResourceMap "path/to/mapResourcefile"
	```

	The irodsResourceMap variable must point to a file which specifies which iRODS resource has to be used when uploading or downloading a file in a particular iRODS path.
	For example:
	```
	$cat path/to/mapResourcefile

	/CINECA01/home/cin_staff/rmucci00;resc-repl
	/CINECA01/home/cin_staff/mrossi;resc-repl
	```
	If none of the listed paths is matched, the iRODS default resource is used.

4. Optionally, use a Globus gridmap callout module to map subject DNs to iRODS user names based on the existing mappings in iRODS (in `r_user_auth` table).
	Configuring this feature eliminates the need for a local grid map file - all user mappings can be done through the callout function.

	The gridmap callout configuration file gets already created as '/preferred_path/gridmap_iRODS_callout.conf'.

	To activate the module, set the '$GSI_AUTHZ_CONF' environment variable in `$GLOBUS_LOCATION/etc/gridftp.conf` to point to the configuration file already created as '/preferred_path/gridmap_iRODS_callout.conf'.
	```
	$GSI_AUTHZ_CONF /preferred_path/gridmap_iRODS_callout.conf
	```
	Note that in order for this module to work, the server certificate DN must be authorized to connect as a rodsAdmin user (e.g., the 'rods' user).

5.  To configure the number of threads used for iRODS read/write operations, add the $numberOfIrodsReadWriteThreads parameter to the GridFTP configuration file.  For example, to set this to 2 threads, set it as follows:

    ```
    $numberOfIrodsReadWriteThreads 2
    ```

    If this parameter is not set or the value is invalid, the default of 3 threads will be used.

    The maximum value for this is 10 threads.  If it is set to a number higher than 10, it will default to 10.

6.  To configure the file size threshold (in bytes) to switch from single threaded uploads and downloads to multiple threaded uploads and downloads, add the $irodsParallelFileSizeThresholdBytes parameter in the GridFTP configuration file.  For example, to set this to 32MB, set it as follows:

    ```
    $irodsParallelFileSizeThresholdBytes 33554432
    ```

    The default value for this parameter is 32 MiB for uploads.  Any upload with a file size less than $irodsParallelFileSizeThresholdBytes will use only one thread.  Any upload with a file size greater than or equal to $irodsParallelFileSizeThresholdBytes will use $numberOfIrodsReadWriteThreads upload threads.

    There is no default for downloads.  If $irodsParallelFileSizeThresholdBytes is not set, $numberOfIrodsReadWriteThreads threads will always be spawned for downloads.  When $irodsParallelFileSizeThresholdBytes is set, iRODS must do a query to the iRODS database to determine the file size.  If $irodsParallelFileSizeThresholdBytes is set, the plugin will then only spawn multiple threads if the file size is greater than or equal to the value set in $irodsParallelFileSizeThresholdBytes.

    It is suggested that the administrator tests small file uploads and downloads to determine the best setting for the $irodsParallelFileSizeThresholdBytes.  This depends on the network topology.  In some cases, doing a query to iRODS for file size might be less efficient than starting up multiple threads.  If that is the case, do not set $irodsParallelFileSizeThresholdBytes.


Additional notes
---------------------------------

This module also supports invoking an iRODS server-side command with iexec in case the DN does not have a mapping yet. The command would receive the DN being mapped as a single argument and may for example add a mapping to an existing account, or create a new account.
To enable this feature, set the `$irodsDnCommand` environment variable in '/etc/gridftp.conf' to the name of the command to execute. On the iRODS server, the command should be installed in '$IRODS_HOME/server/bin/cmd/'.
For example, to invoke a script called 'createUser', add:
```
$irodsDnCommand "createUser"
```

There is also a command line utility to test the mapping lookups (and script execution) that would otherwise be done by the gridmap module. This utility command gets installed into '$DEST_BIN_DIR/testirodsmap' and should be invoked with the DN as a single argument.
The command would need to see the same environment variables as the gridmap module loaded into the GridFTP server - specifically, `$irodsEnvFile` pointing to the iRODS environment and '$irodsDnCommand' setting the command to invoke if no mapping is found. The 'testirodsmap' command also needs to have access to the server host certificate - and find it either through the default mechanisms used by Globus GSI or by explicitly setting the
'X509_USER_CERT' and 'X509_USER_KEY' environment variables.
(The easiest way is to run the command in the same environment as the Globus GridFTP server, i.e., under the root account). For example, invoke the command with:
```
export irodsDnCommand=createUser
export irodsEnvFile=/path/to/.irodsEnv
$DEST_BIN_DIR/testirodsmap "/C=XX/O=YYY/CN=Example User"
```

Checksum Considerations
-----------------------

Checksums are calculated by doing a full open/read/close on the data object.  This plugin must read the file to calculate the checksum because iRODS does not provide a checksum API that meets the needs for this use case.

1. The existing checksum functionality within iRODS doesn't support all of the desired checksum algorithms.
2. The checksum algorithm in Globus is specified by the client. iRODS has one global setting for the algorithm.

Due to this, uploads with checksums can be delayed while the checksum is being calculated in the client. In addition, performing the open/read/close will cause additional iRODS policy to fire.

The checksums are stored in iRODS metadata so not all checksum requests require that we read the full file contents. If the data object has not been updated since the last checksum calculation, the checksum will not be recalculated.

Automated Testing
-----------------

See [Automated Testing README](tests/docker/README.md) for information about running the automated testing scripts.


License
---------------------------------
Copyright 2020-2021 University of North Carolina at Chapel Hill

Copyright 2011-2017 EUDAT CDI - www.eudat.eu

Copyright 1999-2006 University of Chicago


 Globus iRODS Connector

 Author: Justin James, RENCI

 Globus DSI to manage data on iRODS.

 Author: Roberto Mucci - SCAI - CINECA
 Email:  hpc-service@cineca.it

 Globus gridmap iRODS callout to map subject DNs to iRODS accounts.

 Author: Vladimir Mencl, University of Canterbury
 Email:  vladimir.mencl@canterbury.ac.nz

