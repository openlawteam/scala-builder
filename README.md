# Scala/SBT Builder

Docker images for building Scala/SBT projects, with optional ScalaJS support.

## Installation 

1. Install [Docker](https://www.docker.com)
2. Pull [automated build](https://hub.docker.com/r/openlaw/scala-builder/) from 
public [Docker Hub Registry](https://registry.hub.docker.com):
```
docker pull openlaw/scala-builder
```

## Image Variants

### `openlaw/scala-builder:`, `openlaw:scala-builder:*-slim`

This is the defacto image. If you are unsure about what your needs are, you
probably want to use this one. It is designed to be used both as a throw away
container as well as the base to build other images off of.

This was originally based on [`hseeberger/scala-sbt`] but modified to be based
on slim base for a smaller build.

[`hseeberger/scala-sbt`]: https://github.com/hseeberger/scala-sbt

### `openlaw/scala-builder:*-node`

Extends the base image with a LTS version of Node.js which is a build
environment dependency for ScalaJS projects.

Note that while this image contains Node.js, *it is provided strictly as a
dependency of ScalaJS*, and should never be used as a base image for node
projects. (For actual node projects, use an official node image as the builder
for much better results).

## Usage ##

```
docker run -it --rm openlaw/scala-builder
```

## License ##

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.