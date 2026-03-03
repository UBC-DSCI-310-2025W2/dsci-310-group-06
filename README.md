# DSCI 310 Group 6
This is an example readme file

## Containerization

This project uses a Dockerfile and a GitHub Actions workflow to build and publish a Docker image to Docker Hub.  
The workflow triggers on changes to the Dockerfile or the workflow file, and it can also be triggered manually using `workflow_dispatch`.

The workflow logs in to Docker Hub using encrypted GitHub Actions secrets (`DOCKER_USERNAME` and `DOCKER_PASSWORD`), builds the image, and pushes it to our team’s Docker repository.
