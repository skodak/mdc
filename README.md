# MDC (Moodle Docker Containers) for OrbStack

MDC is a set of scripts that greatly simplify setting up [Moodle](https://moodle.org/) development
and test environments on Apple macOS using [OrbStack](https://orbstack.dev/) container manager.
MDC is a fork of [moodle-docker](https://github.com/moodlehq/moodle-docker).

**Features**

* No need to understand Docker commands and parameters
* No need for Homebrew or MacPorts installation
* Easy configuration via `mdc.env`, `mdc-config.php` and `mdc.yml` files
* Useful helper scripts for everyday tasks
* Backup and restore of Moodle site data
* Noticeably better performance than Docker Desktop for Mac
* [Container domains](https://docs.orbstack.dev/docker/domains) with https instead of confusing port forwarding
* Fast native [OrbStack app](https://docs.orbstack.dev/menu-bar)
* Amazing [OrbStack debug shell](https://docs.orbstack.dev/features/debug)
* All Moodle supported PHP versions available with commonly used PHP extensions enabled
* Supported database servers - PostgreSQL, MariaDB, MySQL and MS SQL Server
* Behat/Selenium configurations for Chromium, Chrome, Edge and Firefox with VNC and remote port debugging
* Behat browser inspection via "chrome://inspect" (Chrome/Chromium only)
* Catch-all SMTP server and web interface to messages using [Mailpit](https://github.com/axllent/mailpit)

**Table of contents**

- [Prerequisites](#prerequisites)
- [Features](#features)
- [Quick start](#quick-start)
- [Backup and restore](#backup-and-restore)
- [MDC commands](#mdc-commands)
- [Project configuration](#project-configuration)
  - [Environment variables](#environment-variables)
  - [Customisation of config.php](#customisation-of-configphp)
  - [Additional Composer configuration](#additional-composer-configuration)
- [Shared configuration](#shared-configuration)
- [Security recommendations](#security-recommendations)
- [PHPUnit testing](#phpunit-testing)
- [Behat testing](#behat-testing)
  - [VNC debugging](#vnc-debugging)
  - [Headless browser inspection](#headless-browser-inspection-)
- [Advanced usage examples](#advanced-usage-examples)
  - [IDE configuration](#ide-configuration)
  - [Grunt](#grunt)
  - [Shared Moodle codebase](#shared-moodle-codebase)
  - [XDebug live debugging](#xdebug-live-debugging)
  - [Non-moodle projects](#non-moodle-projects)

## Prerequisites

* macOS 12.3 or newer is required (Windows and Linux are not supported)
* latest version of [OrbStack](https://orbstack.dev/) installed

## Quick start

1. Open terminal and cd to your projects directory
2. Clone __mdc__ repository (or extract downloaded packege into mdc directory):
```bash
git clone https://github.com/skodak/mdc.git
```
3. Clone __moodle__ repository (or extract downloaded packege into moodle directory):
```bash
git clone https://github.com/moodle/moodle.git
```
4. Create empty `mdc.env` settings file:
```bash
cd moodle
touch mdc.env
```
5. Add `mdc/bin` directory to your search path in `~/.zshrc`:
```bash
export PATH=$PATH:/path/to/mdc/bin
```
6. Open terminal, cd to your moodle directory and execute `mdc-rebuild` script:
```bash
cd /path/to/moodle
mdc-rebuild
```
7. You can complete the test site installation at [https://webserver.moodle.orb.local/](https://webserver.moodle.orb.local/).
8. Alternatively you can complete the test site installation from CLI:
```bash
cd /path/to/moodle
site-install --agree-license --adminpass="testpassword"
```
9. You can review all outgoing emails at [https://mailpit.moodle.orb.local/](https://mailpit.moodle.orb.local/).
10. When you are finished with testing you can delete the containers using `mdc-down` script:
```bash
cd /path/to/moodle
mdc-down
```

## Backup and restore

Commands `mdc-rebuild` and `mdc-down` are deleting all site data (Moodle database and dataroot files). Without
backup and restore scripts it would not be possible to change settings of existing containers.

MDC backup/restore works only for the same database type, it is not possible to back up data on PostgreSQL
and later restore them in MySQL.

In default installation the backup files are stored in `shared/backups/` subdirectory of mdc. It is possible
to change the location by setting a different value for MDC_BACKUPS_PATH environment variable.

Example of backup and restore:

1. backup data:
```bash
cd /path/with/mdc.env/
mdc-backup mybackup
```
2. alter mdc.env file or login and change some Moodle data
3. reset the site
```bash
mdc-rebuild
```
4. restore data into empty containers:
```bash
cd /path/with/mdc.env/
mdc-restore mybackup
```

## MDC commands

_MDC commands_ are helper scripts located in mdc/bin/ directory. You can get help for most of the commands
by executing them with --help or -h parameter. 

In recent macOS revisions the default shell is _Z Shell_. To allow trouble free use of MDC it is recommended
to add mdc/bin to your search path in interactive terminals by adding following into your `~/.zshrc` file:
```bash
export PATH=$PATH:/path/to/mdc/bin
```

Please note that MDC commands can only be executed from directories with _mdc.env_ files because the current
directory identifies the project for MDC.

List of often used MDC commands with short descriptions:

* `mdc-rebuild` - delete existing project containers if they exist, build Docker compose file and launch new containers
* `mdc-stop` - stop project containers, keep existing site data
* `mdc-start` - start existing project containers, using initial configuration and existing site data
* `mdc-restart` - stop and start project containers keeping current configuration and site data
* `mdc-down` - stop and delete project containers, site data and configuration
* `mdc-backup mybackupname` - create backup named 'mybackupname' using current site data
* `mdc-restore mybackupname` - restore back 'mybackupname' into empty project containers (requires mdc-rebuild)
* `site-install --agree-license --adminpass="Test888-Password"` - install Moodle in empty project containers
* `mdc-php admin/cli/upgrade.php` - execute PHP script using relative path, in this example existing site upgrade is performed
* `phpunit-init` - initialise PHPUnit test environment
* `phpunit --filter=enrol_manual` - run PHPUnit tests, in this example limiting scope to enrol_manual plugin
* `behat-init` - initialise Behat testing environment
* `behat --tags=@enrol_manual` - run Behat tests, in this example limiting scope to enrol_manual plugin
* `mdc-debug webserver` - start OrbStack Debugging Shell inside a webserver container
* `mdc-bash db` - start normal Bash shell inside a db container
* `node-init && grunt` - install node in webserver container and run grunt job in a webserver container

## Project configuration

Each project directory must contain `mdc.env` file which includes Moodle and site configuration settings.
It is also possible to modify default config.php settings by adding `mdc-config.php` file.
File `mdc.yml` may contain project specific Docker Compose additions.

### Environment variables

You can change the configuration of the docker images by setting various environment variables in __mdc.env__ file.
This file is usually placed in your Moodle code directory, however it can be placed in any directory because the bin
scripts are looking for it in the current working directory when executed.

Changes in the environment file should be done **before** calling `mdc-rebuild`. If your containers are running
first call `mdc-down`, then update the environment file and finally start the containers again.

| Environment Variable            | Mandatory | Allowed values                               | Default value                         | Notes                                                                                                                   |
|---------------------------------|-----------|----------------------------------------------|---------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| `MDC_DB_TYPE`                   | no        | pgsql, mariadb, mysqli, sqlsrv               | pgsql                                 | The database server to run against                                                                                      |
| `MDC_DB_VERSION`                | no        | Docker tag - see docker-hub                  | pgsql: 16; mysqli: 8.4; mariadb: 11.4 | The database server docker image tag                                                                                    |
| `MDC_DB_COLLATION`              | no        | Collation supported by given database        | various                               |                                                                                                                         |
| `MDC_PHP_VERSION`               | no        | 8.1, 8.0, 8.2, 8.3, etc.                     | 8.1                                   | The php version to use                                                                                                  |
| `MDC_PHP_ERROR_LOG_PATH`        | no        | Path to PHP error log on your file system    | not set                               | You can specify a different PHP error logging file outside of Docker                                                    |
| `MDC_BROWSER`                   | no        | chromium, chrome, firefix or edge            | chromium                              | The browser to run Behat against. Supports a colon notation to specify a specific Selenium docker image version to use. |
| `MDC_BROWSER_VERSION`           | no        | Docker Hub tag of selenium-stabalone image   | 4                                     | Selenium docker image version to use.                                                                                   |
| `MDC_BROWSER_DEBUG_PORT`        | no        | 9223, 9229 or similar                        | not set                               | In "chrome://inspect" add target "127.0.0.1:port" to inspect behat browser, ports must be unique for each project       |  
| `MDC_PHPUNIT_EXTERNAL_SERVICES` | no        | any value                                    | not set                               | If set, dependencies for memcached, redis, solr, and openldap are added                                                 |
| `MDC_BBB_MOCK`                  | no        | any value                                    | not set                               | If set the BigBlueButton mock image is started and configured                                                           |
| `MDC_BEHAT_FAILDUMP_PATH`       | no        | Path on your file system                     | not set                               | Behat faildumps are available at https://webserver.moodle.orb.local/_/faildumps/, use for path outside of container     |
| `MDC_BACKUPS_PATH`              | no        | Path to backup directory on your file system | subdirectory shared/backups/ of mdc   | Use for alternative backups path outside of containers                                                                  |

Examples can be found in [mdc/templates/mdc.env](templates/mdc.env) file.

### Customisation of config.php

When using standard MDC config.php copied from [mdc/templates/config.php](templates/config.php) file,
then it is possible to alter $CFG and other site settings by adding a `mdc-config.php project
file which gets included close to the end of config.php.

Examples can be found in [mdc/templates/mdc-config.php](templates/mdc-config.php) file.

### Additional Composer configuration

Instead of environmental variables it is also possible to supply extra compose configuration file.

For example this `mdc.yml` adds adminer to project:

```yaml
services:
  adminer:
    container_name: "${COMPOSE_PROJECT_NAME}-adminer"
    image: adminer:latest
    depends_on:
      - "db"
```

If used in project directory named 'moodle' then Adminer would be accessible via [https://adminer.moodle.orb.local/](https://adminer.moodle.orb.local/).

## Shared configuration

Configuration options that apply to all projects can be included in _shared_ subdirectory of mdc:

* `mdc/shared/mdc.env` - environment defaults for all project
* `mdc/shared/mdc-config.php` - config.php overrides for all projects
* `mdc/shared/mdc.yml` - addition Composer changes for all projects

The internal format of these shared files is the same as project configuration files.

## Security recommendations

* MDC cannot be used for production web hosting
* MDC sites are not intended to be accessed from Internet
* Limit Docker ports redirections to 127.0.01 interface
* Always keep macOS firewall enabled and do not allow Docker to listen to incoming connections
* Do not install random additional Moodle plugins without security review

## PHPUnit testing

To initialise the PHPUnit test environment execute `behat-init` script:

```bash
cd /path/to/moodle/
phpunit-init
```

To run PHPUnit tests execute `phpunit` script, for example:

```bash
cd /path/to/moodle/
phpunit --filter=auth_manual
```

You should see something like this:
```
Moodle 4.1.13 (Build: 20240902), d4f5e92ee156002b95db1ab6f76e25870563e2f6
Php: 8.1.29, pgsql: 16.4 (Debian 16.4-1.pgdg120+1), OS: Linux 6.10.6-orbstack-00249-g92ad2848917c aarch64
PHPUnit 9.5.28 by Sebastian Bergmann and contributors.

.....                                                               5 / 5 (100%)

Time: 00:00.776, Memory: 307.00 MB

OK (5 tests, 17 assertions)
```

Notes:

* If you want to run tests with code coverage reports:
```bash
cd /path/to/moodle/
# Build component configuration
phpunit-util --buildcomponentconfigs
# Execute tests for component
mdc exec webserver php -d pcov.enabled=1 -d pcov.directory=. vendor/bin/phpunit --configuration reportbuilder --coverage-text
```
* See available [Command-Line Options](https://phpunit.readthedocs.io/en/9.5/textui.html#textui-clioptions) for further info

## Behat testing

To initialise the Behat test environment execute `behat-init` script: 

```bash
cd /path/to/moodle/
behat-init
```

To run Behat tests execute `behat` script, for example:

```bash
cd /path/to/moodle/
behat --tags=@auth_manual
```

You should see something like this:
```
Moodle 4.1.13 (Build: 20240902), d4f5e92ee156002b95db1ab6f76e25870563e2f6
Php: 8.1.29, pgsql: 16.4 (Debian 16.4-1.pgdg120+1), OS: Linux 6.10.6-orbstack-00249-g92ad2848917c aarch64
Run optional tests:
- Accessibility: Yes
Server OS "Linux", Browser: "chrome"
Started at 02-09-2024, 03:28
...............

2 scenarios (2 passed)
15 steps (15 passed)
0m5.21s (52.11Mb)
```

Notes:

* The behat faildump directory is exposed at https://webserver.moodle.orb.local/_/faildumps/.
* Use `MDC_BROWSER` to switch the browser you want to run the test against.
  You need to recreate your containers using `mdc-rebuild`,
  if you make any changes in __mdc.env__ file.

### VNC debugging

If you want to observe the execution of scenarios in a web browser then
just connect to selenium container using OrbStack container domain name.

You should be able to use any kind of VNC viewer, such as [Real VNC Viewer](https://www.realvnc.com/en/connect/download/viewer/)
or standard macOS application _Screen Sharing_.

With the containers running, enter address "selenium.moodle.orb.local" in VNC Viewer
or copy vnc://selenium.moodle.orb.local address into _Safari_ which will open _Screen Sharing_ application
or execute this in terminal:
```bash
open vnc://selenium.moodle.orb.local
```
You will be prompted for a password, the password is 'secret'.

You should be able to see an empty desktop. When you run any Behat tests with @javascript tag
a browser will pop up, and you will see the tests execute.

### Headless browser inspection 

The only way to inspect headless Chromium/Chrome browser is to use remote debug ports.
Please note the port based debugging may be used also for normal Selenium Chrome/Chromium.

Modify `mdc.env` file to include:

```
MDC_BROWSER=chromium
MDC_BROWSER_DEBUG_PORT=9229
```

To force headless mode you need to modify `mdc-config.php` file to include:

```php
$CFG->behat_profiles['default']['capabilities']['extra_capabilities']['chromeOptions']['args'][] = 'headless=new';
$CFG->behat_profiles['default']['capabilities']['extra_capabilities']['chromeOptions']['args'][] = 'no-gpu';
```

1. Open Chrome and go to chrome://inspect
2. add 127.0.0.1:9229
3. start behat run
3. Click on Remote Target link with your session

## Advanced usage examples

### IDE configuration

* [PhpStorm configuration](./README_PhpStorm.md)
* [VSCode configuration](./README_VSCode.md)

### Grunt

First you need to install appropriate node and npm version in webserver container, for example:

```bash
cd /path/with/mdc.env/
node-init
```

To run grunt use:

```bash
cd /path/with/mdc.env/
grunt
```

### Shared Moodle codebase

Normally you would have Moodle PHP files in the same directory as `mdc.env` file,
and you would be executing mdc scripts form the same directory. However, it is also
possible to create `mdc.env` and `mdc-config.php` files in empty directory.

1. Checkout moodle into a directory, or you can reuse existing moodle project.
```bash
git clone https://github.com/moodle/moodle.git
```
3. Create or alter config.php file to include code from [mdc/templates/config.php](templates/config.php), optionally start the containers:
```bash
cd moodle
cp ../mdc/templates/config.php ./
mdc-build
cd ..
```
2. Create another directory at the same level for SQL Sever testing:
```bash
mkdir moodle_sqlsrv
cd moodle_sqlsrv
```
3. Add `mdc.env` file with following content:
```
MDC_PHP_VERSION=8.1.29
MDC_DIRROOT=/path/to/moodle
MDC_DB_TYPE=sqlsrv
MDC_DB_VERSION=2019-latest
```
4. Create container:
```bash
mdc-rebuild
```
5. Inspect new instance at [https://webserver.moodle-sqlsrv.orb.local/admin/index.php](https://webserver.moodle-sqlsrv.orb.local/admin/index.php)

### XDebug live debugging

The XDebug PHP Extension is not included in this setup and there are reasons not to include it by default.

However, if you want to work with XDebug, especially for live debugging, you can add XDebug to a running webserver container easily:

```bash
# Install XDebug extension with PECL
mdc exec webserver pecl install xdebug

# Set some wise setting for live debugging - change this as needed
read -r -d '' conf <<'EOF'
; Settings for Xdebug Docker configuration
xdebug.mode = debug
xdebug.client_host = host.docker.internal
EOF
mdc exec webserver bash -c "echo '$conf' >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini"

# Enable XDebug extension in Apache and restart the webserver container
mdc exec webserver docker-php-ext-enable xdebug
mdc restart webserver
```

While setting these XDebug settings depending on your local need, please take special care of the value of `xdebug.client_host` which is needed to connect from the container to the host. The given value `host.docker.internal` is a special DNS name for this purpose within Docker for Windows and Docker for Mac. If you are running on another Docker environment, you might want to try the value `localhost` instead or even set the hostname/IP of the host directly.

After these commands, XDebug ist enabled and ready to be used in the webserver container.
If you want to disable and re-enable XDebug during the lifetime of the webserver container, you can achieve this with these additional commands:

```bash
# Disable XDebug extension in Apache and restart the webserver container
mdc exec webserver sed -i 's/^zend_extension=/; zend_extension=/' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
mdc restart webserver

# Enable XDebug extension in Apache and restart the webserver container
mdc exec webserver sed -i 's/^; zend_extension=/zend_extension=/' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
mdc restart webserver
```

### Non-moodle projects

This is an example how the MDC can be abused to run other software.

1. Checkout https://github.com/moodle/devdocs.git code into some directory
```bash
git clone https://github.com/moodle/devdocs.git
cd devdocs
```
2. Create empty `mdc.env` file:
```bash
touch mdc.env
```
3. Add `mdc.yml` file containing webserver port override:
```
services:
  webserver:
    labels:
      - dev.orbstack.http-port=3000
```
4. Create containers and install nvm inside webserver container:
```bash
mdc-rebuild
mdc-bash webserver
```
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
```
5. Exit webserver bash with CTRL+D
6. Execute commands inside webserver container:
```bash
mdc-bash webserver
```
```bash
nvm install
npm i -g yarn
yarn
yarn build
yarn start --host=0.0.0.0
```
7. Open [https://webserver.devdocs.orb.local/](https://webserver.devdocs.orb.local/)
8. Dispose of the devdocs containers:
```bash
cd /path/to/devdocs/
mdc-down
```
