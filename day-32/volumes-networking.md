# Day 32 -- Docker Volumes & Networking

**Goal:** Understand how Docker handles persistent data and
container-to-container communication.

------------------------------------------------------------------------

# 1. The Problem -- Containers Are Ephemeral

Containers are designed to be replaceable. If data is stored only inside
a container's writable filesystem, removing the container also removes
that data.

## Step 1: Run a MySQL container

``` bash
docker run -d \
  --name mysql-no-volume \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=testdb \
  mysql:8.0
```

Check that it is running:

``` bash
docker ps
```

Wait for MySQL to become ready:

``` bash
docker logs mysql-no-volume
```

## Step 2: Create a table and insert data

Open a MySQL shell:

``` bash
docker exec -it mysql-no-volume mysql -uroot -prootpass testdb
```

Run:

``` sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

INSERT INTO users (name) VALUES
('Nandan'),
('Docker'),
('DevOps');

SELECT * FROM users;
```

Expected data:

``` text
+----+--------+
| id | name   |
+----+--------+
|  1 | Nandan |
|  2 | Docker |
|  3 | DevOps |
+----+--------+
```

Exit:

``` sql
exit;
```

## Step 3: Stop and remove the container

``` bash
docker stop mysql-no-volume
docker rm mysql-no-volume
```

## Step 4: Start a brand-new container

``` bash
docker run -d \
  --name mysql-no-volume \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=testdb \
  mysql:8.0
```

Check the database:

``` bash
docker exec -it mysql-no-volume mysql -uroot -prootpass testdb
```

``` sql
SHOW TABLES;
```

### Result

The `users` table and its rows are gone.

### Why?

The database files were stored inside the first container's writable
filesystem. When the container was removed with:

``` bash
docker rm mysql-no-volume
```

that container filesystem was removed as well.

**Important:** The Docker image is not the database storage. The image
provides the software and initial filesystem; persistent database data
should be stored outside the container using a volume or bind mount.

------------------------------------------------------------------------

# 2. Named Volumes

A Docker named volume is managed by Docker and exists independently of a
container.

## Step 1: Create a named volume

``` bash
docker volume create mysql-data
```

Verify:

``` bash
docker volume ls
```

Expected:

``` text
DRIVER    VOLUME NAME
local     mysql-data
```

Inspect it:

``` bash
docker volume inspect mysql-data
```

This shows information such as the volume name, driver and Docker's
storage location.

## Step 2: Run MySQL with the volume

``` bash
docker run -d \
  --name mysql-volume \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=testdb \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0
```

### Volume mapping

``` text
Host/Docker-managed volume
        |
        v
mysql-data
        |
        v
/var/lib/mysql inside container
        |
        v
MySQL database files
```

## Step 3: Add data

``` bash
docker exec -it mysql-volume mysql -uroot -prootpass testdb
```

Run:

``` sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

INSERT INTO users (name) VALUES
('Nandan'),
('Docker'),
('Persistent Data');

SELECT * FROM users;
```

Expected:

``` text
+----+-----------------+
| id | name            |
+----+-----------------+
|  1 | Nandan          |
|  2 | Docker          |
|  3 | Persistent Data |
+----+-----------------+
```

Exit:

``` sql
EXIT;
```

## Step 4: Remove the container

``` bash
docker stop mysql-volume
docker rm mysql-volume
```

Notice that the volume was NOT removed.

Verify:

``` bash
docker volume ls
```

`mysql-data` should still exist.

## Step 5: Create a brand-new container using the same volume

``` bash
docker run -d \
  --name mysql-volume-new \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=testdb \
  -v mysql-data:/var/lib/mysql \
  mysql:8.0
```

Check the data:

``` bash
docker exec -it mysql-volume-new mysql -uroot -prootpass testdb
```

``` sql
SELECT * FROM users;
```

### Result

The original data is still present.

### Why?

The database files were stored in the named volume rather than the
container's temporary writable layer.

The container can be deleted and recreated while the volume remains.

## Useful commands

List volumes:

``` bash
docker volume ls
```

Inspect a volume:

``` bash
docker volume inspect mysql-data
```

Remove a volume:

``` bash
docker volume rm mysql-data
```

**Warning:** Removing the volume can permanently remove the persistent
data associated with it.

------------------------------------------------------------------------

# 3. Bind Mounts

A bind mount maps a specific directory or file on the host machine
directly into a container.

Unlike a named volume, the host controls the source path.

## Step 1: Create a host directory

Linux/macOS:

``` bash
mkdir -p ~/docker-day32/nginx-site
cd ~/docker-day32/nginx-site
```

Create `index.html`:

``` bash
cat > index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Day 32 Docker</title>
</head>
<body>
    <h1>Hello from Docker Bind Mount!</h1>
    <p>Day 32 of 90 Days of DevOps</p>
</body>
</html>
EOF
```

Verify:

``` bash
cat index.html
```

## Step 2: Run Nginx with a bind mount

``` bash
docker run -d \
  --name nginx-bind \
  -p 8080:80 \
  -v ~/docker-day32/nginx-site:/usr/share/nginx/html \
  nginx:alpine
```

Check:

``` bash
docker ps
```

Open in a browser:

``` text
http://localhost:8080
```

If Docker is running on a remote EC2 instance, use:

``` text
http://<EC2-PUBLIC-IP>:8080
```

and make sure the EC2 security group allows inbound TCP traffic on port
`8080`.

## Step 3: Edit the host file

Change `index.html`:

``` bash
cat > index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Day 32 Docker</title>
</head>
<body>
    <h1>Updated from the Host!</h1>
    <p>The bind mount reflects host changes immediately.</p>
</body>
</html>
EOF
```

Refresh the browser.

### Result

The updated page appears without rebuilding the Docker image or
recreating the container.

### Why?

The host directory and the container directory point to the same files
through the bind mount.

------------------------------------------------------------------------

# 4. Named Volume vs Bind Mount

  --------------------------------------------------------------------------------------
  Feature                 Named Volume                  Bind Mount
  ----------------------- ----------------------------- --------------------------------
  Managed by              Docker                        Host/user

  Source                  Docker-managed storage        Specific host path

  Example                 `mysql-data:/var/lib/mysql`   `~/site:/usr/share/nginx/html`

  Good for                Database/application          Development files/config/source
                          persistent data               code

  Host path control       Docker manages it             User explicitly chooses it

  Portable configuration  Usually easier                Depends on host path

  Direct host file        Not normally the main use     Yes
  editing                 case                          
  --------------------------------------------------------------------------------------

### Simple way to remember

**Named volume:**

> "Docker, manage this persistent storage for me."

**Bind mount:**

> "Docker, use this exact folder from my host."

------------------------------------------------------------------------

# 5. Docker Networking Basics

Docker networks allow containers to communicate with each other.

## Step 1: List Docker networks

``` bash
docker network ls
```

Typical output:

``` text
NETWORK ID     NAME      DRIVER    SCOPE
xxxxxxx        bridge    bridge    local
xxxxxxx        host      host      local
xxxxxxx        none      null      local
```

The default `bridge` network is created by Docker.

## Step 2: Inspect the default bridge

``` bash
docker network inspect bridge
```

Look at the `Containers` section to see which containers are attached.

------------------------------------------------------------------------

# 6. Default Bridge Network -- Name Communication

Run two containers on the default bridge network.

``` bash
docker run -dit --name container1 alpine sh
docker run -dit --name container2 alpine sh
```

Check:

``` bash
docker ps
```

## Try to ping by container name

From `container1`:

``` bash
docker exec container1 ping -c 3 container2
```

### Result

On the legacy/default `bridge` network, automatic container-name DNS
resolution is generally not available.

You may see an error similar to:

``` text
ping: bad address 'container2'
```

This is an important difference between the default bridge and a
user-defined bridge network.

------------------------------------------------------------------------

# 7. Default Bridge -- IP Communication

Find the IP address of `container2`:

``` bash
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' container2
```

Example:

``` text
172.17.0.3
```

Now ping that IP from `container1`:

``` bash
docker exec container1 ping -c 3 172.17.0.3
```

### Result

The containers can communicate using the container IP address, assuming
ICMP/ping is available in the image and networking is otherwise
functioning.

### Key observation

Default bridge:

``` text
container1 ----IP----> container2
```

Name-based discovery is not the same as on a user-defined bridge.

------------------------------------------------------------------------

# 8. Custom Bridge Network

A user-defined bridge network provides better container networking
features, including automatic DNS-based service discovery by container
name.

## Step 1: Create the network

``` bash
docker network create my-app-net
```

Verify:

``` bash
docker network ls
```

## Step 2: Run two containers on the custom network

``` bash
docker run -dit \
  --name app1 \
  --network my-app-net \
  alpine sh
```

``` bash
docker run -dit \
  --name app2 \
  --network my-app-net \
  alpine sh
```

## Step 3: Ping by name

``` bash
docker exec app1 ping -c 3 app2
```

### Result

This should work.

The custom bridge network provides Docker's embedded DNS so `app1` can
resolve:

``` text
app2
```

to the appropriate container IP.

### Communication flow

``` text
app1
 |
 | DNS: app2
 v
Docker embedded DNS
 |
 v
app2 IP address
 |
 v
app2
```

------------------------------------------------------------------------

# 9. Why Does Custom Networking Support Name-Based Communication?

Docker's user-defined bridge networks provide automatic service
discovery through Docker's embedded DNS.

When containers are connected to the same user-defined network:

``` text
app1 ---- my-app-net ---- app2
```

`app1` can resolve `app2` by name.

This is much easier than manually discovering and using changing
container IP addresses.

Container IP addresses can change when containers are recreated, but the
container/service name can remain the stable way for other containers to
locate it.

------------------------------------------------------------------------

# 10. Put It Together -- Database + Application

Now combine both concepts:

-   Custom network
-   MySQL database
-   Named volume
-   Application container
-   Name-based communication

## Step 1: Create the network

``` bash
docker network create my-app-net
```

If it already exists, Docker will report that it exists. In that case,
continue.

## Step 2: Create the database volume

``` bash
docker volume create app-db-data
```

Verify:

``` bash
docker volume ls
```

## Step 3: Run MySQL

``` bash
docker run -d \
  --name app-db \
  --network my-app-net \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=appdb \
  -v app-db-data:/var/lib/mysql \
  mysql:8.0
```

Check:

``` bash
docker ps
```

## Step 4: Verify the database

``` bash
docker exec -it app-db mysql -uroot -prootpass appdb
```

Run:

``` sql
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100)
);

INSERT INTO products (name) VALUES
('Docker'),
('MySQL'),
('DevOps');

SELECT * FROM products;
```

Exit:

``` sql
EXIT;
```

------------------------------------------------------------------------

# 11. Run an Application Container

For a simple networking test, use Alpine.

``` bash
docker run -dit \
  --name app \
  --network my-app-net \
  alpine sh
```

Now the application container and database container are on the same
network:

``` text
              my-app-net
       ┌─────────────────────┐
       │                     │
       │   app  ────────── app-db
       │                     │
       └─────────────────────┘
              |
          app-db-data
            volume
```

## Step 12: Verify name-based communication

From the application container:

``` bash
docker exec app ping -c 3 app-db
```

The name `app-db` should resolve to the MySQL container's IP.

------------------------------------------------------------------------

# 12. Verify the MySQL Port

Ping only proves network-level reachability. To test the actual MySQL
service, check port `3306`.

From the application container:

``` bash
docker exec app sh -c "nc -zv app-db 3306"
```

If `nc` is not installed in the Alpine image, install it:

``` bash
docker exec app apk add --no-cache netcat-openbsd
```

Then:

``` bash
docker exec app nc -zv app-db 3306
```

Expected result is similar to:

``` text
app-db (172.x.x.x:3306) open
```

This confirms that the application container can reach MySQL using the
database container's name.

------------------------------------------------------------------------

# 13. Important Networking Concept: Container Port vs Host Port

In the database example, we did **not** use:

``` bash
-p 3306:3306
```

Why?

Because the application container communicates with MySQL internally
through the Docker network.

It can use:

``` text
app-db:3306
```

The host does not need to expose MySQL publicly.

## Example

``` text
Browser
   |
   | :8080
   v
Host
   |
   v
App container
   |
   | app-db:3306
   v
MySQL container
```

`-p` is mainly needed when something outside the Docker network needs to
access the container service.

------------------------------------------------------------------------

# 14. Useful Inspection Commands

## List containers

``` bash
docker ps
```

## List all containers

``` bash
docker ps -a
```

## List volumes

``` bash
docker volume ls
```

## Inspect volume

``` bash
docker volume inspect app-db-data
```

## List networks

``` bash
docker network ls
```

## Inspect network

``` bash
docker network inspect my-app-net
```

## Inspect a container

``` bash
docker inspect app-db
```

## View logs

``` bash
docker logs app-db
```

------------------------------------------------------------------------

# 15. Cleanup

After completing the experiments, remove the containers:

``` bash
docker rm -f mysql-no-volume mysql-volume-new nginx-bind container1 container2 app1 app2 app app-db
```

Remove the test network:

``` bash
docker network rm my-app-net
```

If you no longer need the persistent data:

``` bash
docker volume rm mysql-data app-db-data
```

**Do not remove the volumes if you want to preserve the database data.**

------------------------------------------------------------------------

# 16. Screenshots to Capture

Add screenshots from your own terminal/browser experiments at these
points.

### Screenshot 1 -- Container without volume

Show:

``` bash
docker ps
```

and the SQL query showing the inserted rows.

**\[Insert Screenshot 1 here\]**

### Screenshot 2 -- Data lost after container removal

Show:

``` sql
SHOW TABLES;
```

after creating a new container without a volume.

**\[Insert Screenshot 2 here\]**

### Screenshot 3 -- Named volume

Show:

``` bash
docker volume ls
docker volume inspect mysql-data
```

**\[Insert Screenshot 3 here\]**

### Screenshot 4 -- Persistent data

Show the data after creating a new MySQL container with the same volume:

``` sql
SELECT * FROM users;
```

**\[Insert Screenshot 4 here\]**

### Screenshot 5 -- Bind mount

Show the browser displaying the Nginx page.

**\[Insert Screenshot 5 here\]**

### Screenshot 6 -- Bind mount update

Edit `index.html`, refresh the browser, and capture the updated page.

**\[Insert Screenshot 6 here\]**

### Screenshot 7 -- Docker networks

Show:

``` bash
docker network ls
docker network inspect bridge
```

**\[Insert Screenshot 7 here\]**

### Screenshot 8 -- Default bridge networking

Show the failed name-based ping and successful IP-based ping.

**\[Insert Screenshot 8 here\]**

### Screenshot 9 -- Custom network

Show:

``` bash
docker network create my-app-net
docker network ls
docker exec app1 ping -c 3 app2
```

**\[Insert Screenshot 9 here\]**

### Screenshot 10 -- Final database + application setup

Show:

``` bash
docker network inspect my-app-net
docker volume inspect app-db-data
docker exec app ping -c 3 app-db
```

**\[Insert Screenshot 10 here\]**

------------------------------------------------------------------------

# 17. Final Observations

## Containers without volumes

Container storage is temporary from a persistence perspective. Removing
the container removes the data stored in its writable layer.

## Named volumes

Named volumes allow data to survive container deletion.

``` text
Container A
     |
     v
Named Volume
     ^
     |
Container B
```

A new container can reuse the same volume.

## Bind mounts

Bind mounts expose a specific host path inside the container.

``` text
Host folder
     |
     v
Container folder
```

Changes made on the host can immediately be reflected inside the
container.

## Default bridge network

Containers can communicate using IP addresses, but the legacy/default
bridge does not provide the same automatic name-based container
discovery as a user-defined bridge network.

## Custom bridge network

User-defined bridge networks provide automatic DNS-based name resolution
between connected containers.

``` text
app  --->  app-db
       name-based communication
```

## Final architecture

``` text
                  my-app-net
        ┌─────────────────────────────┐
        │                             │
        │   App Container             │
        │       |                     │
        │       | app-db:3306         │
        │       v                     │
        │   MySQL Container           │
        │       |                     │
        └───────|─────────────────────┘
                v
          app-db-data
          Named Volume
```

------------------------------------------------------------------------

# 18. Key Commands Learned

### Volumes

``` bash
docker volume create NAME
docker volume ls
docker volume inspect NAME
docker volume rm NAME
```

### Named volume

``` bash
-v volume_name:/container/path
```

### Bind mount

``` bash
-v /host/path:/container/path
```

### Networks

``` bash
docker network ls
docker network inspect bridge
docker network create my-app-net
docker network inspect my-app-net
docker network rm my-app-net
```

### Connect a container to a network

``` bash
docker run --network my-app-net IMAGE
```

### Test container communication

``` bash
docker exec container1 ping container2
```

------------------------------------------------------------------------

# 19. Day 32 Takeaway

> **Containers are disposable, but data and services do not have to
> be.**

Docker volumes solve **data persistence**, while Docker networks solve
**container communication**.

The key difference learned today is:

``` text
Volume       → Where persistent data lives
Bind Mount   → Host folder ↔ container folder
Network      → How containers communicate
Custom DNS   → How containers find each other by name
```

This makes it possible to build multi-container applications where the
application, database, and other services can be independently recreated
without losing persistent data.
