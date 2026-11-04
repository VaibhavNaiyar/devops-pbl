# Practice 11 – Docker overview, architecture, images, containers, Swarm

**Architecture (for viva):** Docker client (CLI) → REST API → Docker daemon (dockerd) → containerd → runc. Images are layered, read-only; containers add a writable layer. Registry = Docker Hub.

## Images & containers
```bash
docker version && docker info
docker pull nginx:alpine
docker images
docker run -d --name web1 -p 8080:80 nginx:alpine     # open http://localhost:8080
docker ps; docker logs web1; docker exec -it web1 sh
docker stop web1 && docker rm web1
docker history nginx:alpine                           # image layers
```
## Build your own image
```bash
cd practices/11-docker
docker build -t pbl-flask:1.0 ./app
docker run -d --name flask -p 5000:5000 pbl-flask:1.0
docker inspect flask | more
docker rm -f flask
docker compose up -d --build        # web + redis; refresh localhost:5000 -> hits increase
docker compose ps; docker compose down
```
## Volumes & networks
```bash
docker volume ls; docker network ls
docker network create pbl-net
```
## Swarm
```bash
docker swarm init
docker stack deploy -c swarm-stack.yml pbl
docker service ls
docker service ps pbl_web           # 3 replicas
docker service scale pbl_web=5
curl localhost:5000                 # "container" changes -> load balancing
docker stack rm pbl && docker swarm leave --force
```
