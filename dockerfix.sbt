/*
    Workaround for https://github.com/sbt/sbt/issues/4168, requires JDK8.
    See https://github.com/openlawteam/scala-builder for details.
*/
initialize ~= { _ =>
    System.setProperty("sbt.io.jdktimestamps", "true")
}
