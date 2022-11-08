FROM python:3.9.13-slim-buster

RUN apt-get update && \
    apt-get install -y \
        postgresql \
        postgresql-contrib \
        postgresql-server-dev-all \
        gcc \
        curl

RUN pip install psycopg2 pysftp==0.2.8 mlflow==1.27.0