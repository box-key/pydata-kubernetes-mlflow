FROM python:3.9.2-slim-buster


WORKDIR /app

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
	postgresql \
	postgresql-contrib \
	postgresql-server-dev-all \
	gcc \
	curl

# Install python dependencies
COPY . /app/ 
RUN pip install -q -r requirements.txt

RUN chmod +x /app/docker-entrypoint.sh
CMD [ "/app/docker-entrypoint.sh" ]
