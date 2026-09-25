# Day 45 – Docker Build & Push in GitHub Actions

## Challenge Tasks

### Task 1: Prepare

Created a modern static web application for the Docker CI/CD demonstration.

- `index.html` contains the animated CI/CD dashboard.
- `Dockerfile` packages the application with Nginx.
- GitHub repository secrets:
  - `DOCKER_USERNAME`
  - `DOCKER_TOKEN`

![Task 1](images/task1.png)

---

### Task 2: Build the Docker Image in CI

Created `.github/workflows/docker-publish.yml`.

The workflow checks out the repository and builds the Docker image using `docker/build-push-action@v6`.

**Verify:** The image builds successfully in GitHub Actions.

![Task 2](images/task2.png)

---

### Task 3: Push to Docker Hub

On a push to `main`, the workflow:

1. Logs in to Docker Hub using GitHub Secrets.
2. Builds the Docker image.
3. Pushes the `latest` tag.
4. Pushes a commit-specific `sha-<short-commit>` tag.

**Verify:** Both tags are visible in Docker Hub.

![Task 3](images/task3.png)

---

### Task 4: Only Push on Main

Feature branches and pull requests build the Docker image for validation, but they do not push it to Docker Hub.

A push to `main` performs the Docker Hub login and pushes both image tags.

**Main branch:**

![Task 4 - Main](images/task4.1.png)

**Feature branch / PR:**

![Task 4 - Feature](images/task4.2.png)

---

### Task 5: Add a Status Badge

Add this to the repository `README.md`:

```markdown
![Docker Build & Push](https://github.com/Nandan29300/github-actions-practice/actions/workflows/docker-publish.yml/badge.svg)
```

![Task 5](images/task5.png)

---

### Task 6: Pull and Run It

After the image is available on Docker Hub:

```bash
docker pull Nandan29300/webapp:latest
docker run -d --name dockerflow -p 8080:80 Nandan29300/webapp:latest
```

Open:

```text
http://localhost:8080
```

![Task 6](images/task6.png)

### Docker Hub

Replace the repository link if you choose a different Docker Hub repository name.

[Docker Hub – webapp](https://hub.docker.com/r/Nandan29300/webapp)

---

## Full Journey: `git push` to a Running Container

1. **Git push** – Code is pushed to GitHub.

2. **GitHub Actions triggers** – The workflow starts for `main`, feature branches, or pull requests.

3. **Checkout** – `actions/checkout@v4` downloads the repository into the runner.

4. **Build** – Docker builds the image from the Dockerfile.

5. **Branch decision**:
   - `main` push → image is pushed to Docker Hub.
   - feature branch / PR → image is only built and not pushed.

6. **Tag** – The main branch image receives:
   - `latest`
   - `sha-<first 7 characters of commit SHA>`

7. **Push** – Both tags are uploaded to Docker Hub.

8. **Pull** – A machine pulls the image from Docker Hub.

9. **Run** – Docker starts the Nginx container and maps host port `8080` to container port `80`.

10. **Serve** – Nginx serves the animated `index.html` application.

---

## What I Learned

- How Docker images can be built automatically in GitHub Actions.
- How Docker Hub authentication works with GitHub Secrets.
- How to use immutable SHA-based image tags alongside `latest`.
- How to separate build validation from production publishing.
- How a CI/CD pipeline connects source control, image builds, a container registry, and a running container.
