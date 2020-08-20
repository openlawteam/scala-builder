## Scala and sbt Dockerfile

FROM adoptopenjdk/openjdk11:x86_64-alpine-jdk-11.0.8_10

# Build variables
ARG SCALA_VERSION=2.12.12
ARG SBT_VERSION=1.3.13

# Environment variables
ENV SBT_HOME=/usr/share/sbt

# Install and keep a copy of bash.  Some scala/scalac scripts depend on bash(!),
# and work unreliably with ash, et al.
RUN apk add --no-cache bash

# Install SBT
#
# There are Windows specific files included in the download that
# we remove to save space and avoid confusion (bin/sbt.bat conf/sbtconfig.txt).
#
# And yep, we do this all in one mega command to keep the layer small. If you
# are working on this in the future, https://github.com/wagoodman/dive is your
# friend.
#
# NOTE: there is currently an experimental sbt pkg for alpine in edge/testing:
#
#     https://git.alpinelinux.org/aports/tree/testing/sbt/APKBUILD.
#
# But we don't want to depend on something outside of the stable alpine
# tracking.
RUN apk add --no-cache --virtual=build-deps curl && \
    # Install sbt base
    mkdir -p "${SBT_HOME}" && \
    set -o pipefail && \
    curl -fsL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" \
      | tar xfz - --strip-components=1 -C "${SBT_HOME}" && \
    ln -s "${SBT_HOME}"/bin/sbt /usr/local/bin/sbt && \
    mkdir -p "${HOME}"/.sbt && \
    sbt ++"${SCALA_VERSION}" sbtVersion && \
    # Get rid of Windows specific files
    rm "${SBT_HOME}"/bin/sbt.bat && \
    rm "${SBT_HOME}"/conf/sbtconfig.txt && \
    # Get rid of build-dependencies we only needed for this install step
    apk del build-deps

# Verify SBT is installed successfully.
#
# This step doesn't really do anything, and should be a no-op. Thus it also
# exists somewhat as a debug layer -- if inspection/logs reveal that additional
# file are being automatically installed at this step, then we probably didnt
# successfully fully cache install SBT in the previous step.
RUN sbt sbtVersion

# Define working directory. This is basically just the starting point for usage
# of containers based on this image, so let's have an isolated src directory for
# people to mount their code into, and avoid confusion with $HOME.
WORKDIR /src

# Install Scala
#
# SBT *really* wants to manage Scala itself and will fight you if you try to do
# other ways, so we cave in and let it download a copy of the version we want
# for caching. Unfortunately, it has no command to do this explicitly that we
# could discover, so the only way to make this happen is to create a phantom
# project, compile it, and then delete it afterwards.
#
# (Inspecting this layer reveals some additional .ivy2 cache is also created,
# TODO to figure out more what's actually going on there, but we want to cache
# that anyhow for now. Note even if we were not installing Scala with this step,
# we may have to continue to do this anyhow in the future.)
RUN \
  mkdir project && \
  echo "scalaVersion := \"${SCALA_VERSION}\"" > build.sbt && \
  echo "sbt.version=${SBT_VERSION}" > project/build.properties && \
  echo "case object Temp" > Temp.scala && \
  sbt compile && \
  rm -r project && rm build.sbt && rm Temp.scala && rm -r target

# Related to SBT issue noted at the top of this file[1][2], we need to tell
# SBT to rely on JDK native timestamping in JDK8 to work around the issue.
#
# Note that this workaround will only work on JDK8, in OpenJDK >=11 then
# the default JDK timestamp call returns millisecond precision, so this
# workaround would no longer function to get around the SBT issue.
#
# The suggested method is to set an environment variable to handle such as:
#
#   SBT_OPTS="${SBT_OPTS} -Dsbt.io.jdktimestamps=true"
#
# Unfortunately this is trivially easy to accidentally override downstream by a
# user of this builder image without realizing they are breaking something (as
# it is fairly common to define SBT_OPTS during a runtime invocation, and one
# often accidentally overrides instead of appends), so set this via filesystem
# instead for increased robustness.
#
# [1]: https://github.com/sbt/sbt/issues/4168
# [2]: https://stackoverflow.com/a/54138157
# COPY dockerfix.sbt /root/.sbt/1.0/dockerfix.sbt
