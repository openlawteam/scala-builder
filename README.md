# Scala/SBT Builder with ScalaJS support

Based on `hseeberger/scala-sbt` but modified to be based on slim base for a
slimmer build, and contains node which is a build environment dependency for
ScalaJS.

Note that while this image contains NodeJS, it should never be used as a base
for Node projects. NodeJS is provided strictly as a dependency of ScalaJS. (For
actual Node projects, please use an official node image as the builder).

## Installation ##

1. Install [Docker](https://www.docker.com)
2. Pull [automated build](https://hub.docker.com/r/openlaw/scala-builder/) from 
public [Docker Hub Registry](https://registry.hub.docker.com):
```
docker pull openlaw/scala-builder
```

## Usage ##

```
docker run -it --rm openlaw/scala-builder
```

## License ##

This code is open source software licensed under the [Apache 2.0 License]("http://www.apache.org/licenses/LICENSE-2.0.html").
