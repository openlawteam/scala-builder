<h1>
    <img src="docs/pizza-scala-128.png" width=64>
    Scala/SBT Builder
</h1>

Docker images for building Scala/SBT projects, with optional ScalaJS support.

Built on top of Alpine Linux with a few tricks to keep things small, and
contains a built-in workaround for the docker layer-caching bug in SBT. See
the Dockerfile for details.

[![](https://images.microbadger.com/badges/version/openlaw/scala-builder.svg)](https://hub.docker.com/r/openlaw/scala-builder)
[![Build Status](https://travis-ci.com/openlawteam/scala-builder.svg?branch=master)](https://travis-ci.com/openlawteam/scala-builder)
![](https://img.shields.io/badge/pizza%20dog-approved-brightgreen.svg)


## Installation

1. Install [Docker](https://www.docker.com)
2. Pull [automated build](https://hub.docker.com/r/openlaw/scala-builder/) from
public [Docker Hub Registry](https://registry.hub.docker.com):
```
docker pull openlaw/scala-builder
```

## Image Variants

### `openlaw/scala-builder:`, `openlaw/scala-builder:*-alpine`

This is the defacto image. If you are unsure about what your needs are, you
probably want to use this one. It is designed to be used both as a throw away
container as well as the base to build other images off of.

### `openlaw/scala-builder:*-node`

Extends the base image with a LTS version of Node.js which is a build
environment dependency for ScalaJS projects.

Note that while this image contains Node.js, *it is provided strictly as a
dependency of ScalaJS*, and should never be used as a base image for node
projects. (For actual node projects, use an official node image as the builder
for much better results).

## Usage

```
$ docker run -it --rm openlaw/scala-builder
```

By default the WORKDIR is set to `/src`, so if you want to mount local code you
can do something like:

    docker run --rm -v $(pwd):/src openlaw/scala-builder sbt compile

## Release process

The CI system will automatically build and release anything with a Semantic
Version tag to Docker Hub. Please use GitHub Releases to mark the release.

## License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
