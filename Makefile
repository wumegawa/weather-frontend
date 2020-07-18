include .env

DOCKER_TEST           := $(shell cat /proc/1/cgroup | grep 0::)
DOCKER_BRIDGE_HOST_IP := $(shell docker network inspect bridge --format='{{(index .IPAM.Config 0).Gateway}}')
BUILD_COMMIT          := "$(shell git describe --always --abbrev=40 --dirty)"
# Alternative method: BUILD_COMMIT := $(shell git rev-parse HEAD)
BUILD_DATE            := "$(shell date --rfc-3339=seconds)"
DOCKER_COMPOSE_VARS   := DOCKER_BRIDGE_HOST_IP=$(DOCKER_BRIDGE_HOST_IP) BUILD_COMMIT=$(BUILD_COMMIT) BUILD_DATE=$(BUILD_DATE)

.SILENT: hello
hello:
	echo Welcome to MyStage Vue.js Frontend make system!

# #################################################################################################################### #
# The following section of this file contains only commands that should be accessible OUTSIDE Docker containers
# #################################################################################################################### #
ifeq (,$(findstring containerd,$(DOCKER_TEST)))

.SILENT: git-cleanup
git-cleanup:
	./bash/git-cleanup.sh

# Start the container, keep stdout attached
start:
	$(DOCKER_COMPOSE_VARS) docker-compose up --abort-on-container-exit

# Rebuild containers without cache
cc:
	$(DOCKER_COMPOSE_VARS) docker-compose build --no-cache

# Rebuild and run the container, keep stdout attached
restart:
	$(DOCKER_COMPOSE_VARS) docker-compose up --force-recreate --build --abort-on-container-exit

# Start the container, detach stdout
up: # create-network
	$(DOCKER_COMPOSE_VARS) docker-compose up -d

# Rebuild and run the container, detach stdout
rebuild: # create-network
	$(DOCKER_COMPOSE_VARS) docker-compose up -d --force-recreate --build

# Stop and remove containers
down:
	$(DOCKER_COMPOSE_VARS) docker-compose down

reset: down rebuild

ash-root:
	docker exec -it weather-frontend /bin/ash

ash-node:
	docker exec -it --user=node weather-frontend /bin/ash

# #################################################################################################################### #
# The following section of this file contains only commands that should be accessible INSIDE Docker containers
# #################################################################################################################### #
else

endif
