---
layout: post
title: "Deploying of your Docker Swarm cluster"
description: The first steps to use Docker Swarm
tags: [docker, swarm, docker service, docker stack]
comments: true
---

The easiest way to experiment with production-like Docker's environment is to use [Docker Swarm](https://docs.docker.com/engine/swarm/). And there are two ways to manipulate with a Swarm cluster - managing `services` or `stacks`. The below step by step guide provides you ability to configure a Swarm cluster, deploy it and do initial experiments.

Prerequisites
=============

Installations
-------------
The required installations are
1. [Docker](https://www.docker.com)
2. [docker-machine](https://docs.docker.com/machine/)
3. [VirtualBox](https://www.virtualbox.org)

"Counting hits" application
---------------------------
The application counts how many time a page was open. It consists of a [Flask](http://flask.pocoo.org) application which stores data to a [Redis](https://redis.io).

The application's images have 3 different tags:
- `extsoft/counting-hits:latest`
- `extsoft/counting-hits:v1`
- `extsoft/counting-hits:v2`

All of them have equivalent functionality but represent different images.

"Counting hits" source
----------------------
The sources below demonstrate how the images were created. You can just skip this section if you aren't interested in.

**app.py**
```python
import socket

from flask import Flask
from redis import Redis

app = Flask(__name__)
redis = Redis(host='redis', port=6379)

@app.route('/')
def hello():
    count = redis.incr('hits')
    return 'I have been seen {t} times. My hostname is: {h} \n'.format(
            t=count, h=socket.gethostname()
            )

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
```

**requirements.txt**
```text
flask
redis
```

**Dockerfile**
```text
FROM python:3.4-alpine
LABEL maintainer="Dmytro Serdiuk <dmytro.serdiuk@gmail.com>" site="extsoft.pro"
WORKDIR /code
COPY app.py requirements.txt ./
RUN pip install -r requirements.txt && mkdir -p logs
EXPOSE 5000
CMD ["python", "app.py"]
```

Prepare Swarm cluster
=====================
A couple of hosts are required to demonstrate a Swarm cluster. You can use any hosts available for yourself, but I'll create several ones using `docker-machine` and `VirtualBox`. Then, the Swarm cluster will be configured for created hosts.
```bash
# create VMs
docker-machine create --driver virtualbox master
docker-machine create --driver virtualbox worker1
docker-machine create --driver virtualbox worker2
docker-machine ls
# configure SWARM cluster
docker-machine ssh master "docker swarm init --advertise-addr <master IP>"
docker-machine ssh worker1 "docker swarm join --token <token> <master IP>:2377"
docker-machine ssh worker2 "docker swarm join --token <token> <master IP>:2377"
# activate Docker CLI for "master" MV
eval $(docker-machine env master)
```

Deployment with `docker service`
================================
Using `docker service` "Redis" service will be working along with "Counting hits" service. Communication between the services will be established using a custom network.

Run services
------------
```bash
# create a network for services communication
docker network create --driver overlay --subnet 10.0.9.0/24  ch-network
# create a "redis" service
docker service create --detach --replicas 1 --network ch-network --name redis redis:alpine
# create 5 replicas of "ch" service
docker service create --detach --replicas 5 --network ch-network --publish 5000:5000 --name ch extsoft/counting-hits:v1
# wait around 10 seconds and check if all replicas are up
docker service ls
# check service status
docker service ps ch
# verify that all 5 replicas of "ch" service are working
for i in {1..10}; do curl http://192.168.99.100:5000; done
```

Scale services
--------------
```bash
# scale up to 7 replicas of "ch" service
docker service scale --detach ch=7
# see "ch" service stats
docker service inspect --pretty ch
# scale up to 2 replicas of "ch" service
docker service scale --detach ch=3
```

Update service image
--------------------
```bash
docker service ps ch
# update "ch" service with new image version
docker service update --image extsoft/counting-hits:v2 ch
# wait some time and check a state of the "ch" service
docker service ps ch
# one more image update
docker service update --image extsoft/counting-hits:latest ch
```

Maintain a worker
=================
Due to some reasons, you might want to shut down a worker (a host or a VM) for a maintenance purpose. If you want move working replicas from this worker to others, you need to drain availability of a worker and Swarm automatically will deploy replicas to other available workers. After this, the maintenance procedure can be performed.

```bash
# drain worker1 VM before maintenance
docker node update --availability drain worker1
# check Availability
docker node inspect --pretty worker1
# make sure nothing run on worker1
docker service ps ch
# activate worker1 VM after maintenance
docker node update --availability active worker1
```

Deployment with `docker stack`
==============================
Now let's deploy the application using `docker stack`. First of all, need to prepare a compose file which describing the services structure. Then, just run the services using prepared configuration.

Prepare a compose file
----------------------
**stack-compose.yml**
```text
version: '3.0'
services:
  ch:
    image: extsoft/counting-hits:v1
    depends_on:
    - redis
    ports:
    - '5001:5000'
    deploy:
      replicas: 4
  redis:
    image: redis:alpine
    volumes:
    - redis-data:/data:rw
volumes:
  redis-data:
    driver: local
```

Run stack
---------
```bash
docker stack deploy --compose-file stack-compose.yml ch
# look for available stacks
docker stack ls
# look for services in ch stack
docker stack services ch
# look for containers in ch stack
docker stack ps ch
# test app
for i in {1..10}; do curl http://192.168.99.100:5001; done
```

Also, you are able to manipulate `stack` services with `docker service` commands.

Clean env
=========

```bash
eval $(docker-machine env -u)
docker-machine rm -y $(docker-machine ls -q)
```

Conclusion
==========
Hope you enjoyed this guide! Any questions?
