## Scala and sbt Dockerfile

# OpenJDK8 is the recommended stable series supported on Alpine Linux, but more
# importantly, we need to stick with 8 for builds on docker due to this issue:
#
# https://github.com/sbt/sbt/issues/4168
FROM adoptopenjdk/openjdk8:jdk8u242-b08-alpine

# Build variables
ARG SCALA_VERSION=2.12.11
ARG SBT_VERSION=1.2.8

# Environment variables
ENV SBT_HOME=/usr/share/sbt

# Install and keep a copy of bash.  Some scala/scalac scripts depend on bash(!),
# and work unreliably with ash, et al.
RUN apk add --no-cache bash

# Install SBT
#
# The sbt downloadable archive bundles a `local-preloaded` directory which
# contains pre-cached versions of libraries needed for sbt to function, which is
# supposed to be copied to the user's local ivy cache on first run. However,
# there are two problems with this:
#
#  1. The installation, handled via syncPreloaded() in sbt-launch-lib.bash,
#     appears to be buggy and doesn't actually trigger in this case, resulting
#     in copies of all the libraries being redownloaded from the internet.
#
#  2. The installation installs via rsync archive, which will keep both copies
#     around, resulting in an extra ~50MB of duplicates in the image.
#
# Therefore, we could relocate the preload directory to where it should end
# up (usually $HOME/.sbt/preloaded, but see getPreloaded in sbt-launch.lib.bash
# for more details of how this is calculated) instead of leaving two copies
# lying around.
#
# HOWEVER, even then, the first execution of sbt will "download" from this
# preload folder, creating a third copy with a slightly different directory
# structure in $HOME/.ivy2/cache (yep, it copies, it doesnt symlink or move).
# And naturally that directory structure is different enough that you can't just
# put the local-preloaded directory there to begin with. Thus, we need to
# execute sbt once and then delete the preload cache after.
#
# Additionally, there are Windows specific files included in the download that
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
# tracking, and this additionally does not handle the installation of the
# local-preloaded library -- so if switching to it in the future be sure to
# cache that directory manually as well.
RUN apk add --no-cache --virtual=build-deps curl && \
    # Install sbt base
    mkdir -p "${SBT_HOME}" && \
    set -o pipefail && \
    curl -fsL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" \
      | tar xfz - --strip-components=1 -C "${SBT_HOME}" && \
    ln -s "${SBT_HOME}"/bin/sbt /usr/local/bin/sbt && \
    # Put the preloaded library files where sbt will detect them, and let it
    # invoke once which will "download" them from local filesystem
    mkdir -p "${HOME}"/.sbt && \
    mv "${SBT_HOME}"/lib/local-preloaded "${HOME}"/.sbt/preloaded && \
    sbt ++"${SCALA_VERSION}" sbtVersion && \
    # Now that sbt is happy, get rid of the preload library directory so
    # we dont have two copies taking up extra space (its about 50mb!)
    rm -r "${HOME}"/.sbt/preloaded && \
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
COPY dockerfix.sbt /root/.sbt/1.0/dockerfix.sbt
