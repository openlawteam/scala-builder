## Scala and sbt Dockerfile
#
# Originally based on: https://github.com/hseeberger/scala-sbt
# Modified to use slim base image for build.
FROM openjdk:11.0.1-slim

# Build variables
ARG SCALA_VERSION=2.12.8
ARG SBT_VERSION=1.2.8

# Install needed local programs for installations
RUN apt-get update && apt-get install --no-install-recommends -y \
    curl \
    gnupg \
  && rm -rf /var/lib/apt/lists/*

# Install Scala
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /root/.bashrc

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install -y sbt && \
  sbt sbtVersion && \
  rm -rf /var/lib/apt/lists/*

# Cache stuff in /root/.ivy2 etc
#
# TODO: better document what is actually happening here and why.
RUN \
  mkdir project && \
  echo "scalaVersion := \"${SCALA_VERSION}\"" > build.sbt && \
  echo "sbt.version=${SBT_VERSION}" > project/build.properties && \
  echo "case object Temp" > Temp.scala && \
  sbt compile && \
  rm -r project && rm build.sbt && rm Temp.scala && rm -r target

# Define working directory
WORKDIR /root
