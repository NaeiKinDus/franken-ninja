Invoice Ninja's Monster
=======================
A Kubernetes-oriented variation of Invoice Ninja's application with a dose of [FrankenPHP](https://frankenphp.dev).

# Abstract
This project was born because multiplying images and containers in order to serve a PHP project is burdensome:
deploying the configuration required by the project to your reverse proxy, adding an NGINX container, a PHP-FPM, ...
In comes FrankenPHP, a Caddy-based software that offers many improvements over the classical NGINX + PHP-FPM setups.

# Features
- everything in a single image: no need to deploy an NGINX / Apache container,
- better PHP performance: [benchmarks](https://github.com/dunglas/frankenphp-demo/tree/main/benchmark) performed on a demo project show a nice boost over PHP-FPM,
- based on Caddy: supports automatic HTTPS and HTTP2, high performance webserver and much more,
- all-in-one docker-compose.yml: all the required services for an easy local or Docker swarm usage,
- separate containers for website and background workers: avoid one container impacting the operations of the other, or
  spawn more containers to absorb increased load,
- lighter image: looking at the version 5.8.51 based on amd64 architecture, IN's image is 800.48MB compressed and 2.59GB
  decompressed whereas this image is 542.22MB compressed and 1.55GB decompressed,
- easy maintenance: use [Task](https://github.com/go-task/task) and customize the image or the application to fit your needs,
- deploy on Kubernetes using OpenTofu (or Terraform): no YAML! Well, it is replaced by some HCL but that's cleaner to
  read, right?

# Usage
## Requirements
- Docker (tested on version 25.0.3),
- Docker Compose (tested on version 2.24.5),
- [Task](https://github.com/go-task/task) (tested on version 3.31.0),
- [OpenTofu](https://opentofu.org/) (tested on version 1.6.2) to deploy to a Kubernetes cluster.

## Setup
### For Docker
Copy the file named [.env.example](./config/.env.example) to `./config/.env` and customize it according to your needs.
Depending on your operating system, modify the hosts file (Linux & Unixes: `/etc/hosts`, Windows: `C:\Windows\System32\drivers\etc\hosts`)
and add the following entry:
```shell
# replace <hostname> with your actual hostname, the one defined in either `SERVER_NAME` (Docker) or
# `ingress_host_url` (terraform)
# example: 127.0.1.1 invoice.mydomain.com
127.0.1.1 <hostname>
```

If you want to restore an SQL backup or execute custom SQL statements, you can place `.sql` files in the
`./config/sql_init.d` directory. They will be automatically called by the MariaDB container during the first initialization.

#### Required configuration
The following variables **must** be set before using the application:
- APP_KEY    : a base64-encoded 32 bytes string starting with `base64:`; you may use the output from `task app:key`
- APP_URL    : full URL used to access the application, including the protocol part
- SERVER_NAME: hostname used to access the application, without the protocol part

### For Terraform
Copy the file named [terraform.tfvars.example](./terraform/terraform.tfvars.example) to `./terraform/terraform.tfvars`
and customize it according to your needs.

#### Required configuration
The following variables **must** be set before using the application:
- app_config_app_key    : a base64-encoded 32 bytes string starting with `base64:`; you may use the output from `task app:key`
- app_config_db_host    : hostname of the SQL server
- app_config_db_password: password to connect to the SQL server
- app_config_redis_host : hostname of the Redis server
- ingress_host_url      : hostname used to access the application, without the protocol part

For more information on the ways the deployment can be customized, look at the [variables.tf](./terraform/variables.tf)
file.

### Docker image
The docker image is available [here](https://hub.docker.com/r/pouncetech/invoiceninja) but if you want to use a custom
image or build it yourself you can do so by running the following:
```shell
# For the latest available Invoice Ninja release.
# This will generate two images, one with the most recent Invoice Ninja tag, one with the `latest` tag
task image:build

# For a specific Invoice Ninja version
# This will only generate an image with the specified tag; no `latest` tag will be generated
INVOICE_NINJA_VERSION=<tag_name> image:build
```

## Running the app
### Using docker compose
```shell
docker compose up -d
```

### Using opentofu / terraform
```shell
tofu plan -out ./tf_plan
tofu apply ./tf_plan
```

# Limitations / Caveats
## Application
- no React UI at the moment,
- to use a database other than MySQL / MariaDB you have to modify the Docker image and add the relevant CLI client since
  it is required by the `artisan` PHP command and, due to image size concerns, only the MySQL one is provided by default,

## Terraform
- because only one deployment is used, all containers will be on the same pod / node; creating a multi-node deployment
  would require more work and is outside the scope of this project
- this project is tested using [K3S](https://www.rancher.com/products/k3s) and primarily targets components offered by it;
  this means that for example the Ingress part is based on Traefik Proxy and support for other proxies such as Nginx may
  come but at a later date
