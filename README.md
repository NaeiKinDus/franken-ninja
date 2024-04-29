Invoice Ninja's Monster
=======================
A Kubernetes-oriented variation of Invoice Ninja's application with a dose of [FrankenPHP](https://frankenphp.dev).

## Abstract
This project was born because multiplying images and containers in order to serve a PHP project is burdensome:
deploying the configuration required by the project to your reverse proxy, adding an NGINX container, a PHP-FPM, ...
In comes FrankenPHP, a Caddy-based software that offers many improvements over the classical NGINX + PHP-FPM setups.

## Features
- everything in a single image: no need to deploy an NGINX / Apache container,
- better PHP performance: [benchmarks](https://github.com/dunglas/frankenphp-demo/tree/main/benchmark) performed on a demo project show a nice boost over PHP-FPM,
- based on Caddy: supports automatic HTTPS and HTTP2, high performance webserver and much more,
- all-in-one docker-compose.yml: all the required services for an easy local or Docker swarm usage,
- separate containers for website and background workers: avoid one container impacting the operations of the other, or
  spawn more containers to absorb increased load,
- easy maintenance: use [Task](https://github.com/go-task/task) and customize the image or the application to fit your needs,
- deploy on Kubernetes using OpenTofu (or Terraform): no YAML! Well, it is replaced by some HCL, but that's cleaner to
  read, right?

## Usage
### Requirements
- Docker (tested on version 25.0.3),
- Docker Compose (tested on version 2.24.5),
- [Task](https://github.com/go-task/task) (tested on version 3.31.0),
- [OpenTofu]() (tested on version 1.6.2) to deploy to a Kubernetes cluster.

### Setup
// TODO
-> list env config options + setup steps,
-> Terraform usage / K8S usage,
-> /etc/hosts: 127.0.0.1 <hostname>
-> variables:
- CADDY_GLOBAL_OPTIONS
- FRANKENPHP_CONFIG
- CADDY_EXTRA_CONFIG
- SERVER_NAME
- CADDY_SERVER_EXTRA_DIRECTIVES
- APP_TYPE=app (app|upkeep|*)
- SKIP_DB_LINK_CHECK=empty (check: is empty)
- WAIT_FOR_DB_LINK_MAX_RETRY=5
- WAIT_FOR_DB_LINK_SLEEP_TIME=10
- SKIP_INIT_TASKS=empty (check: is empty)
- DISABLE_SCHEDULE=empty (check: is empty)
- QUEUE_WORKERS_SLEEP_PERIOD=3 (seconds)
- QUEUE_WORKERS_MAX_TRIES=3
- QUEUE_WORKERS_MEMORY_MAX=256 (MB)
- QUEUE_WORKERS_BACKOFF_PERIOD=10 (seconds)
- QUEUE_WORKERS_COUNT=3


Why `CADDY_SERVER_EXTRA_DIRECTIVES: "tls internal"`
How to add custom HTTPS cert

### Execution


## Roadmap
- add [React UI](https://github.com/invoiceninja/ui)
- add task to autofetch opentofu
- check building for ARM processors (Apple, RPi, ...)
- add github actions / gitlab CICD to build and push to docker hub,
- add TF HPA
- Add precommit hooks + gitlab pipeline to run tests
- add mirroring gitlab -> github
- usage of app-upkeep and `command`
- sql_init.d usage
- add license + spdx tags
- add TF guide + requirements:
  - pvc.storage-class
  - ingress host
- open /metrics path to cluster to allow prometheus probing
- add doc on assumptions: external DB, external Redis, Traefik Ingress, based on K3S
- add alternative ingress using nginx?
- add ARM support


## Debuging
```
chromium --headless --disable-gpu --disable-translate --disable-extensions \
  --disable-sync --disable-background-networking --disable-software-rasterizer \
  --disable-default-apps --disable-dev-shm-usage --safebrowsing-disable-auto-update \
  --run-all-compositor-stages-before-draw --no-first-run --no-margins --no-sandbox \
  --print-to-pdf-no-header --no-pdf-header-footer --hide-scrollbars \
  --ignore-certificate-errors --print-to-pdf=/tmp/test.pdf /tmp/test.html
```

---

## Deployment
### Configuration
#### Secrets
- appKey,
- dbPassword,
- mailerPassword,
- apiSecret,
- redisPassword.

#### Required
- appUrl: URL used to access your application, including the scheme part; example: `https://invoice.example.com`
- dbHost: SQL database host, either an FQDN or an IP address; example: `10.42.0.1`
- dbPassword: password of the SQL user account used to connect to the database; example: `#1234my_DEFINITELY_NOT_secure_pwd`
- redisHost: Redis host, either an FQDN or an IP address; example: `redis-master-0.redis-headless.default.svc.cluster.local`

#### Recommended
- apiSecret (default: randomized): a secret used to secure API access against unauthorized clients
- appKey (default: randomized): a base64 string used to secure data, **KEEP IT SAFE AND SECURE** as you will need it
  to restore access during a reinstall; example: `base64:HGj9L2YJx8EdM7L5Pox993XrR/AgWTgZ7TF+uVv6VF4=`
- defaultUsername (default: "user@example.com"): the username of the default account created the first time the application is started; example: `me@mydomain.com`
- defaultUserPassword (default: randomized): the password used for the default account; example: `my0WnNotSecurepWd`
- errorEmail (default: empty): email address used to send error reports; example: `you@example.com`
- mailer (default: "log"): type of mailer configuration to use, if left to default value
  no other mailer options except mailerLogChannel are processed; example: `failover`
- mailerFromAddr (default: unset, required if mailer=smtp|failover): email address displayed for the contact address and emails sent by the application; example: `invoice@example.com`
- mailerHost (default: unset, required if mailer=smtp|failover): mailer host to use, either an FQDN or an IP address; example: `mailer.example.com`
- mailerPassword (default: unset, likely required if mailer=smtp|failover): password for the mailer account used to send emails
- mailerUsername (default: unset, likely required if mailer=smtp|failover): username used to authenticate when sending smtp emails; example: `username@example.com`


#### Optional
- appDebug (default: "false"): boolean flag to enable or disable the debug mode of the application; example: `false`
- daysBeforePdfDeletion (default: "0"): number of days a PDF document is stored before being deleted, 0 meaning never; example: `365`
- daysBeforeBackupDeletion (default: "0"): number of days a backup is stored before being deleted, 0 meaning never; example: `365`
- dbConnection (default: "mysql"): the connection type to use when connecting to a database; example: `sqlite`
- dbName (default: "invoice_ninja"): name of the database used by the application; example: `invoice_ninja`
- dbUsername (default: "invoice_ninja"): username used to establish a connection to the database; example: `invoice_ninja`
- dbPort (default: "3306"): default SQL database port; example: `3306`
- logChannel (default: "stderr"): channel used to store logs generated by the application; example: `invoiceninja`
- pdfGenerator (default: "snappdf"): PDF generation method; example: `hosted_ninja`
- mailerPort (default: "25"): port used to send emails when mailer is set to `smtp`; example: `587`
- mailerEncryption (default: "tls"): encryption to use when communication with the mailer; example: `tls`
- mailerFromName (default: "InvoiceNinja"): name displayed for the contact address and emails sent by the application; example: `invoice@example.com`
- mailerLogChannel (default: "stderr"): name of the logging channel to use when the mailer is set either to "failover" or "log"; example: `stack`
- openexchangeAppId (default: empty): key required to use the OpenExchangeApp service; example: `DlZmA[<3y`
- redisPassword (default: empty): password used to access Redis, if required; example: `123unsecurePasswOrD`
- redisPort (default: "6379"): port used to access the Redis server; example: `6379`
- requireHttps (default: "true"): boolean flag to force or not the usage of HTTPS; example: `true`
- trustedProxies (default: "*"): list of trusted proxies, required to allow application to properly work when behind a proxy; example: `10.42.0.1,10.43.0.0/16`
- updateSecret (default: randomized): a secret used to secure HTTP access to the `update` route used to update the application; example: `someRandomWsdklgkljhasg`
- webcronSecret (default: "false"): a secret used to start cronjobs using an HTTP call; example: `456StillNotSecureButOhWell`
- zipTaxKey (default: empty): Key to use the Zip Tax service; example: `somekey`