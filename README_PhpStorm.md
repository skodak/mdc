# PhpStorm configuration in MDC (Moodle DOcker Containers) for OrbStack

PhpStorm can be configured to use mdc directly which eliminates the need to install PHP binaries,
webserver or database.

There is also a simple _Docker manager_ in Services tab in PhpStorm which can be used to stop/start the containers.

### Configure remote docker PHP CLI interpreter

Then verify mdc instance is up and running - see Quick start section above.

Then open your Moodle project directory in PhpStorm and add a remote PHP CLI interpreter:

1. Open "Preferences / PHP"
2. Add new _CLI Interpreter_ by clicking "..."
3. Click "+" and select "From Docker, Vagrant, VM, WSL, remote..."
4. Select existing docker server or click "Docker compose" and press "New..."  in "Server:" field
5. Select __./mdc-compose.yml__ file in "Configuration files:" field
6. Select __webserver__ in "Service:" field
7. Press "OK"
8. Switch lifecycle to __Connect to existing container ('docker-compose exec')__
9. Press reload icon in "PHP executable:" field, PhpStorm should detect correct PHP binary
10. You should customise the interpreter name at the top and make it "Visible only for this project"
11. Press "OK" to save interpreter settings
12. Verify the new interpreter is selected in "CLI Interpreter:" field
13. Press "OK" to save PHP settings

### Configure remote PHPUnit interpreter

First make sure your docker compose instance is running and PHPUnit was initialised.
The remote PHP CLI interpreter must be already configured in your PhpStorm.

1. Open "Preferences / PHP / Test Frameworks"
2. Click "+" and select "PHPUnit by remote interpreter"
3. Select your docker interpreter that was created for this project and press "OK"
4. Verify "Path to script:" field is set to `/var/www/html/vendor/autoload.php`
5. Verify "Default configuration file:" field is enabled and set it to `/var/www/html/phpunit.xml`
6. Press "Apply" and verify correct PHPUnit version was detected
7. Press "OK"

You may want to delete all unused interpreters.
To execute PHPUnit tests open a testcase file and click on a green arrow gutter icon.

### Configure remote Behat interpreter

First make sure your docker compose project is running and Behat was initialised.
The remote PHP CLI interpreter must be already configured in your PhpStorm.

1. Open "Preferences / PHP / Test Frameworks"
2. Click "+" and select "Behat by remote interpreter"
3. Select your docker interpreter that was created for this project and press "OK"
4. Set "Path to Behat executable:" field to `/var/www/html/vendor/behat/behat/bin/behat`
5. Enable "Default configuration file:" field and se it to `/var/www/behatdata/behatrun/behat/behat.yml`
6. Press "Apply" and verify correct Behat version was detected - if not check the instance is running and Behat was initialised manually
7. Press "OK"

You may want to delete all unused interpreters.
To execute Behat tests open a feature file and click on a green arrow gutter icon.
If you have configured a VNC port then you can watch the scenario progress in your VPN client.

### Connect PhpStorm to docker database

You can connect to moodle database directly using container domains.

Make sure your docker compose project is running and test site was initialised.

Then setup new database connection in PhpStorm through the exposed port, for example:

1. Open "Database" tab in PhpStorm
2. Press "+" and select "Database source / PostgreSQL"
3. Set "User:" field to 'moodle'
4. Set "Password:" field to 'm@0dl3ing'
5. Set "Database:" field to 'moodle'
6. Set "Host:" to db.mdc-moodle.orb.local, keep "Port:" to default database port
7. Press "OK"
8. Refresh the database metadata
9. Open "Preferences / Language & Frameworks / SQL Dialects"
10. Set "Project SQL Dialect:" field to 'PostgreSQL'
11. Press "OK"
12. Copy __.phpstorm.meta.php__ file from `mdc/templates/` directory into your Moodle project
13. You may need to use "File / Invalidate caches..." and restart the IDE

As a test open lib/accesslib.php and find some full SQL statement and verify the SQL syntax
is highlighted and SQL syntax errors are detected.
