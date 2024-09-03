# VSCOde configuration in MDC (Moodle Docker Containers) for OrbStack

__NOTE: the page is not maintained, please submit patches if you know how to make this work__

1. Install _Docker_ extension from Microsoft
2. Add __mdc.env__ to your Moodle project
3. Create containers with `mdc-rebuild`

## Use _Better PHPUnit_ to run tests in VSCode

1. Initialise phpunit with `phpunit-init`
2. Install _Better PHPUnit_ extension
3. Update VSCode configuration (note you need to edit project path):
```json
{
    "better-phpunit.docker.command": "docker compose -f mdc-compose-final.yml exec webserver",
    "better-phpunit.docker.enable": true,
    "better-phpunit.phpunitBinary": "vendor/bin/phpunit",
    "better-phpunit.docker.paths": {
        "/path/to/your/moodle": "/var/www/html"
    },
    "better-phpunit.xmlConfigFilepath": "/var/www/html/phpunit.xml"
}
```
4. Open a test file, go to method and press Cmd+shif+p and select one of _Better PHPUnit_ options to run tests.
