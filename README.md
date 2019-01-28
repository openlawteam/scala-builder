# Scala and sbt Dockerfile

This repository contains **Dockerfile** of [Scala](http://www.scala-lang.org) and [sbt](http://www.scala-sbt.org).

Based on `hseeberger/scala-sbt` but modified to be based on slim base for a slimmer build.

## Installation ##

1. Install [Docker](https://www.docker.com)
2. Pull [automated build](https://hub.docker.com/r/openlaw/scala-sbt/) from public [Docker Hub Registry](https://registry.hub.docker.com):
```
docker pull openlaw/scala-sbt
```

## Usage ##

```
docker run -it --rm openlaw/scala-sbt
```

## License ##

This code is open source software licensed under the [Apache 2.0 License]("http://www.apache.org/licenses/LICENSE-2.0.html").
