# README for  `qc_suite` <img src="logo.svg" align="right" alt="" width="120" />

Github repo for the [podman](https://podman.io/) conatiner [`qc_suite`](https://hub.docker.com/repository/docker/khench/qc_suite).

## Documentation of the initial setup

Originally, the `qc_suite` container was build using [buildah](https://buildah.io/), from the accompanying `Containerfile`:

```sh
buildah bud -t qc_suite
```

To make the container publically availabe, it is pushed to [dockerhub](https://hub.docker.com/r/khench/qc_suite) using [skopeo](https://github.com/containers/skopeo) and [podman](https://podman.io/):

```sh
skopeo login -u khench docker.io
podman push localhost/qc_suite docker.io/khench/qc_suite:v0.1
```

## Accessing the container

The bundled software can be accessed directly from [dockerhub](https://hub.docker.com/r/khench/qc_suite) with `podman` (or `docker`, or `singularity`):

```sh
podman run docker.io/khench/qc_suite:v0.1 which bamcov
```