# Mlflow Model Registry
This tutorial shows how to set up a `mlflow` model registry by using `postgres` as the `mlflow backend storage` and `sftp` server as the `mlflow artifact storage`.

## Why and what is Mlflow?

`Mlflow` is an open source tool to manage end-to-end machine learning workloads. It allows data scientists to magage the full machine learning lifecycle through common API and UI. `Mlflow model registry` is a centralized model store that stores various meta information about machine learning models such as dependency requirements, model version and more for seamless collaboration.

## How to install?

I use an `Ubuntu 22.10` instance offered by `Digital Ocean` for this tutorial, but this should work for other linux distributions and other environments.

1. Create a `1GB/1CPU Ubuntu 22.10` instance on `Digital Ocean`
1. First, you need to set up the `SFTP server` by following [this tutorial](https://www.digitalocean.com/community/tutorials/how-to-enable-sftp-without-shell-access-on-ubuntu-20-04)
1. Install `Docker` by following [this tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04)
1. Once your `SFTP server` is ready, run a `postgres` instance in `docker` by `docker run --rm --name mlflow-db -e POSTGRES_PASSWORD=<your-password> -e POSTGRES_USER=<your-user> -e POSTGRES_DB=mlflow -d -p 5432:5432 postgres`
1. Get `mlflow` image by any of the following ways
    * Go to the project root directory and run `make mlflow-image`
    * Pull image by `docker pull boxkey/mlflow:v1.27.0`: [source](Dockerfile.mlflow)
1. Once your mlflow image is ready, run `mlflow` server by `docker run --network host -d --rm --name mlflow-server <mlflow-image> mlflow server -h 0.0.0.0 --default-artifact-root sftp://<sftp-user>:<sftp-password>@<sftp-serevr-ip>:/var/sftp/uploads/ --backend-store-uri postgresql://<postgres-user>:<postgres-password>@localhost/mlflow`. Note that
    * `<mlflow-image>` can be either `mlflow:v1.27.0` if you create image locally, or `boxkey/mlflow:v1.27.0`
    * `<sftp-server-ip>` is the host's IP address if you follow the steps above. 

## How to test?

1. Go to the project root directory and make sure it has `.env` file. `.env` should contain values for `MLFLOW_URI` and `ARTIFACT_LOCATION`
1. Make sure your virtual environment such as `conda` is active 
1. Install packages by `make install`
1. Register test model by `make register`
1. Go to `Mlflow UI` and make sure it contains the test model
1. In `Mlflow UI`, register model by following [this tutorial](https://www.mlflow.org/docs/latest/model-registry.html)
1. Specify test model's name and version by filling out `MLFLOW_MODEL_NAME` and `MLFLOW_MODEL_VERSION` in `.env`
1. Run `make test-local`. If everything is set up correctly, you should see something like the following in your terminal: `2022-11-07 13:54:49,121 INFO     [predictor.py:64] Service ready!`
