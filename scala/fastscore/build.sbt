lazy val root = (project in file(".")).
    settings(
        version       := "1.0.0",
        name          := "fastscore",
        organization  := "com.opendatagroup",
        scalaVersion  := "2.12.4",

        libraryDependencies ++= Seq(
            "com.fasterxml.jackson.module" %% "jackson-module-scala" % "2.9.1",
            "com.sun.jersey" % "jersey-core" % "1.19",
            "com.sun.jersey" % "jersey-client" % "1.19",
            "com.sun.jersey.contribs" % "jersey-multipart" % "1.19",
            "org.jfarcand" % "jersey-ahc-client" % "1.0.5",
            "io.swagger" % "swagger-core" % "1.5.8",
            "joda-time" % "joda-time" % "2.2",
            "org.joda" % "joda-convert" % "1.2",
            "org.scalatest" % "scalatest_2.12" % "3.0.4" % "test",
            "junit" % "junit" % "4.8.1" % "test",
            "io.circe" %% "circe-core" % "0.8.0",
            "io.circe" %% "circe-generic" % "0.8.0",
            "io.circe" %% "circe-parser" % "0.8.0",
            "io.circe" % "circe-java8_2.12" % "0.8.0"
        ),

        resolvers ++= Seq(
            Resolver.jcenterRepo,
            Resolver.mavenLocal
        ),

        scalacOptions := Seq(
          "-unchecked",
          "-deprecation",
          "-feature"
        ),

        coverageExcludedPackages := "com.opendatagroup.fastscore.swagger.*;com.opendatagroup.fastscore.experimental.*",

        publishArtifact in (Compile, packageDoc) := false
    )

ensimeIgnoreScalaMismatch in ThisBuild := true