CREATE TABLE docker_commands (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    command TEXT NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    example TEXT
);

INSERT INTO docker_commands
(title, command, description, category, example)
VALUES

-- =========================================================
-- BASICS
-- =========================================================

(
    'Check Docker Version',
    'docker --version',
    'Displays the installed Docker version.',
    'Basics',
    'docker --version'
),

(
    'Show Docker Information',
    'docker info',
    'Displays detailed information about the Docker installation and daemon.',
    'Basics',
    'docker info'
),

(
    'Show Docker Help',
    'docker help',
    'Displays available Docker commands and general help.',
    'Basics',
    'docker help'
),

(
    'Help for a Command',
    'docker run --help',
    'Shows available options for a specific Docker command.',
    'Basics',
    'docker run --help'
),

-- =========================================================
-- IMAGES
-- =========================================================

(
    'List Images',
    'docker images',
    'Displays Docker images stored locally.',
    'Images',
    'docker images'
),

(
    'List Images with docker image ls',
    'docker image ls',
    'Lists locally available Docker images.',
    'Images',
    'docker image ls'
),

(
    'Pull an Image',
    'docker pull nginx',
    'Downloads an image from a container registry.',
    'Images',
    'docker pull nginx'
),

(
    'Build an Image',
    'docker build -t myapp .',
    'Builds an image using the Dockerfile in the current directory.',
    'Images',
    'docker build -t myapp .'
),

(
    'Build without Cache',
    'docker build --no-cache -t myapp .',
    'Builds an image without using previous build cache.',
    'Images',
    'docker build --no-cache -t myapp .'
),

(
    'Tag an Image',
    'docker tag myapp username/myapp:latest',
    'Creates another tag for an existing image.',
    'Images',
    'docker tag myapp username/myapp:latest'
),

(
    'Push Image',
    'docker push username/myapp:latest',
    'Uploads an image to a container registry.',
    'Images',
    'docker push username/myapp:latest'
),

(
    'Remove an Image',
    'docker rmi nginx',
    'Removes a Docker image from the local system.',
    'Images',
    'docker rmi nginx'
),

(
    'Inspect an Image',
    'docker image inspect nginx',
    'Displays detailed metadata about an image.',
    'Images',
    'docker image inspect nginx'
),

(
    'Show Image History',
    'docker history nginx',
    'Shows the layers that make up a Docker image.',
    'Images',
    'docker history nginx'
),

(
    'Save Image to File',
    'docker save -o app.tar myapp',
    'Exports a Docker image to a tar archive.',
    'Images',
    'docker save -o app.tar myapp'
),

(
    'Load Image from File',
    'docker load -i app.tar',
    'Loads a Docker image from a tar archive.',
    'Images',
    'docker load -i app.tar'
),

-- =========================================================
-- CONTAINERS
-- =========================================================

(
    'Run a Container',
    'docker run nginx',
    'Creates and starts a container from an image.',
    'Containers',
    'docker run nginx'
),

(
    'Run in Detached Mode',
    'docker run -d nginx',
    'Runs a container in the background.',
    'Containers',
    'docker run -d nginx'
),

(
    'Run with a Custom Name',
    'docker run -d --name web nginx',
    'Creates a container with a custom name.',
    'Containers',
    'docker run -d --name web nginx'
),

(
    'Run with Port Mapping',
    'docker run -d -p 8080:80 nginx',
    'Maps a host port to a container port.',
    'Containers',
    'docker run -d -p 8080:80 nginx'
),

(
    'Run with Environment Variable',
    'docker run -e APP_ENV=production myapp',
    'Passes an environment variable into a container.',
    'Containers',
    'docker run -e APP_ENV=production myapp'
),

(
    'List Running Containers',
    'docker ps',
    'Shows currently running containers.',
    'Containers',
    'docker ps'
),

(
    'List All Containers',
    'docker ps -a',
    'Shows running and stopped containers.',
    'Containers',
    'docker ps -a'
),

(
    'Stop a Container',
    'docker stop <container>',
    'Gracefully stops a running container.',
    'Containers',
    'docker stop my-container'
),

(
    'Start a Container',
    'docker start <container>',
    'Starts an existing stopped container.',
    'Containers',
    'docker start my-container'
),

(
    'Restart a Container',
    'docker restart <container>',
    'Stops and starts a container again.',
    'Containers',
    'docker restart my-container'
),

(
    'Pause a Container',
    'docker pause <container>',
    'Pauses all processes inside a container.',
    'Containers',
    'docker pause my-container'
),

(
    'Unpause a Container',
    'docker unpause <container>',
    'Resumes a paused container.',
    'Containers',
    'docker unpause my-container'
),

(
    'Remove a Container',
    'docker rm <container>',
    'Removes a stopped container.',
    'Containers',
    'docker rm my-container'
),

(
    'Force Remove a Container',
    'docker rm -f <container>',
    'Stops and removes a running container.',
    'Containers',
    'docker rm -f my-container'
),

(
    'Remove All Stopped Containers',
    'docker container prune',
    'Removes all stopped containers.',
    'Cleanup',
    'docker container prune'
),

-- =========================================================
-- CONTAINER DEBUGGING
-- =========================================================

(
    'View Container Logs',
    'docker logs <container>',
    'Displays logs generated by a container.',
    'Debugging',
    'docker logs my-container'
),

(
    'Follow Container Logs',
    'docker logs -f <container>',
    'Continuously follows container logs.',
    'Debugging',
    'docker logs -f my-container'
),

(
    'Execute Command in Container',
    'docker exec <container> <command>',
    'Runs a command inside a running container.',
    'Debugging',
    'docker exec my-container ls'
),

(
    'Open Container Shell',
    'docker exec -it <container> sh',
    'Opens an interactive shell inside a running container.',
    'Debugging',
    'docker exec -it my-container sh'
),

(
    'Inspect a Container',
    'docker inspect <container>',
    'Displays detailed configuration and runtime information.',
    'Debugging',
    'docker inspect my-container'
),

(
    'View Container Processes',
    'docker top <container>',
    'Shows processes currently running inside a container.',
    'Debugging',
    'docker top my-container'
),

(
    'View Container Resource Usage',
    'docker stats',
    'Displays live CPU, memory, network and disk usage.',
    'Debugging',
    'docker stats'
),

(
    'View Port Mappings',
    'docker port <container>',
    'Shows port mappings configured for a container.',
    'Networking',
    'docker port my-container'
),

(
    'Copy Files from Container',
    'docker cp <container>:/path ./path',
    'Copies files from a container to the host.',
    'Containers',
    'docker cp my-container:/app/log.txt .'
),

(
    'Copy Files to Container',
    'docker cp ./file <container>:/path',
    'Copies files from the host into a container.',
    'Containers',
    'docker cp ./config.json my-container:/app/'
),

-- =========================================================
-- ENVIRONMENT
-- =========================================================

(
    'Pass an Environment File',
    'docker run --env-file .env myapp',
    'Loads environment variables from a file into a container.',
    'Configuration',
    'docker run --env-file .env myapp'
),

(
    'List Container Environment',
    'docker exec <container> env',
    'Displays environment variables inside a running container.',
    'Configuration',
    'docker exec my-container env'
),

-- =========================================================
-- VOLUMES
-- =========================================================

(
    'List Volumes',
    'docker volume ls',
    'Lists Docker volumes.',
    'Volumes',
    'docker volume ls'
),

(
    'Create a Volume',
    'docker volume create myvolume',
    'Creates a persistent Docker volume.',
    'Volumes',
    'docker volume create myvolume'
),

(
    'Inspect a Volume',
    'docker volume inspect myvolume',
    'Displays detailed information about a volume.',
    'Volumes',
    'docker volume inspect myvolume'
),

(
    'Remove a Volume',
    'docker volume rm myvolume',
    'Removes a Docker volume.',
    'Volumes',
    'docker volume rm myvolume'
),

(
    'Remove Unused Volumes',
    'docker volume prune',
    'Removes volumes that are not used by any container.',
    'Cleanup',
    'docker volume prune'
),

(
    'Mount a Volume',
    'docker run -v myvolume:/data nginx',
    'Mounts a Docker volume inside a container.',
    'Volumes',
    'docker run -v myvolume:/data nginx'
),

-- =========================================================
-- NETWORKING
-- =========================================================

(
    'List Networks',
    'docker network ls',
    'Lists Docker networks.',
    'Networks',
    'docker network ls'
),

(
    'Create a Network',
    'docker network create mynetwork',
    'Creates a custom Docker bridge network.',
    'Networks',
    'docker network create mynetwork'
),

(
    'Inspect a Network',
    'docker network inspect mynetwork',
    'Displays detailed information about a Docker network.',
    'Networks',
    'docker network inspect mynetwork'
),

(
    'Connect Container to Network',
    'docker network connect mynetwork <container>',
    'Connects an existing container to a Docker network.',
    'Networks',
    'docker network connect mynetwork my-container'
),

(
    'Disconnect Container from Network',
    'docker network disconnect mynetwork <container>',
    'Disconnects a container from a Docker network.',
    'Networks',
    'docker network disconnect mynetwork my-container'
),

(
    'Remove a Network',
    'docker network rm mynetwork',
    'Removes a Docker network.',
    'Networks',
    'docker network rm mynetwork'
),

(
    'Remove Unused Networks',
    'docker network prune',
    'Removes unused Docker networks.',
    'Cleanup',
    'docker network prune'
),

-- =========================================================
-- DOCKER COMPOSE
-- =========================================================

(
    'Start Compose Services',
    'docker compose up',
    'Creates and starts all services defined in a Compose file.',
    'Compose',
    'docker compose up'
),

(
    'Start Compose in Background',
    'docker compose up -d',
    'Starts Compose services in detached mode.',
    'Compose',
    'docker compose up -d'
),

(
    'Build Compose Images',
    'docker compose build',
    'Builds images for services defined in Compose.',
    'Compose',
    'docker compose build'
),

(
    'Build and Start Compose',
    'docker compose up -d --build',
    'Builds images and starts Compose services.',
    'Compose',
    'docker compose up -d --build'
),

(
    'Stop Compose Services',
    'docker compose stop',
    'Stops Compose services without removing them.',
    'Compose',
    'docker compose stop'
),

(
    'Restart Compose Services',
    'docker compose restart',
    'Restarts Compose services.',
    'Compose',
    'docker compose restart'
),

(
    'Show Compose Services',
    'docker compose ps',
    'Displays the status of Compose services.',
    'Compose',
    'docker compose ps'
),

(
    'View Compose Logs',
    'docker compose logs',
    'Displays logs from Compose services.',
    'Compose',
    'docker compose logs'
),

(
    'Follow Compose Logs',
    'docker compose logs -f',
    'Continuously follows Compose service logs.',
    'Compose',
    'docker compose logs -f'
),

(
    'Execute Command in Compose Service',
    'docker compose exec <service> sh',
    'Opens a shell inside a running Compose service.',
    'Compose',
    'docker compose exec backend sh'
),

(
    'Stop and Remove Compose',
    'docker compose down',
    'Stops and removes Compose containers and networks.',
    'Compose',
    'docker compose down'
),

(
    'Remove Compose with Volumes',
    'docker compose down -v',
    'Removes Compose containers, networks and associated volumes.',
    'Compose',
    'docker compose down -v'
),

(
    'Pull Compose Images',
    'docker compose pull',
    'Downloads the latest images required by Compose services.',
    'Compose',
    'docker compose pull'
),

(
    'Validate Compose File',
    'docker compose config',
    'Validates and displays the resolved Compose configuration.',
    'Compose',
    'docker compose config'
),

-- =========================================================
-- DOCKERFILE / BUILD
-- =========================================================

(
    'Build with a Specific Dockerfile',
    'docker build -f Dockerfile.prod -t myapp .',
    'Builds an image using a specific Dockerfile.',
    'Build',
    'docker build -f Dockerfile.prod -t myapp .'
),

(
    'Build with Build Arguments',
    'docker build --build-arg NODE_ENV=production -t myapp .',
    'Passes a build-time argument to the Dockerfile.',
    'Build',
    'docker build --build-arg NODE_ENV=production -t myapp .'
),

-- =========================================================
-- REGISTRY / DOCKER HUB
-- =========================================================

(
    'Login to Docker Registry',
    'docker login',
    'Authenticates Docker with a container registry.',
    'Registry',
    'docker login'
),

(
    'Logout from Docker Registry',
    'docker logout',
    'Logs out from a Docker registry.',
    'Registry',
    'docker logout'
),

(
    'Search Docker Hub',
    'docker search nginx',
    'Searches Docker Hub for available images.',
    'Registry',
    'docker search nginx'
),

(
    'Pull a Specific Image Tag',
    'docker pull nginx:alpine',
    'Pulls a specific image version or tag.',
    'Registry',
    'docker pull nginx:alpine'
),

-- =========================================================
-- CLEANUP
-- =========================================================

(
    'Remove Unused Resources',
    'docker system prune',
    'Removes unused containers, networks and images.',
    'Cleanup',
    'docker system prune'
),

(
    'Remove All Unused Resources',
    'docker system prune -a',
    'Removes unused containers, networks, images and build cache.',
    'Cleanup',
    'docker system prune -a'
),

-- =========================================================
-- SYSTEM / DISK
-- =========================================================

(
    'Show Docker Disk Usage',
    'docker system df',
    'Shows how much disk space Docker is using.',
    'System',
    'docker system df'
),

(
    'Detailed Docker Disk Usage',
    'docker system df -v',
    'Shows detailed Docker disk usage information.',
    'System',
    'docker system df -v'
);
