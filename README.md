docker-maven
============

# Supported tags and respective Dockerfile links

* [jdk-7](https://github.com/carlossg/docker-maven/blob/master/jdk-7/Dockerfile)
* [jdk-7-onbuild](https://github.com/carlossg/docker-maven/blob/master/jdk-7/onbuild/Dockerfile)
* [latest, jdk-8](https://github.com/carlossg/docker-maven/blob/master/jdk-8/Dockerfile)
* [onbuild, jdk-8-onbuild](https://github.com/carlossg/docker-maven/blob/master/jdk-8/onbuild/Dockerfile)

# What is Maven?

[Apache Maven](http://maven.apache.org) is a software project management and comprehension tool.
Based on the concept of a project object model (POM),
Maven can manage a project's build,
reporting and documentation from a central piece of information.


# How to use this image

## Create a Dockerfile in your Maven project

    FROM maven:3.3-jdk-7-onbuild
    CMD ["do-something-with-built-packages"]

Put this file in the root of your project, next to the pom.xml.

This image includes multiple ONBUILD triggers which should be all you need to bootstrap.
The build will `COPY . /maven/project` and `RUN mvn install`.

CMD directive above should contain argumetns to second `mvn` invocation after `mnv install` is
complete, for example:

    CMD ["-Pdeployment", "-DskipTests=true", "deploy"]

You can then build and run the image:

    docker build -t my-maven .
    docker run --rm my-maven


## Run a single Maven command

For many simple projects, you may find it inconvenient to write a complete `Dockerfile`.
In such cases, you can run a Maven project by using the Maven Docker image directly,
passing a Maven command to `docker run`:

    docker run --rm -v $HOME/.m2:/maven/.m2 -v $(pwd):/maven/project maven:3.3-jdk-7 clean install

Note that entry point of the image is `mvn`, so the command you pass to `docker run` are actually
Maven invocation arguments. In case you need to override it, you can use `--entrypoint` parameter
of `docker run` command.

The build will be executed as user `maven` with UID 1000. This is important because the mounted
host directories will be accessed using the same local UID. If the UID of the account used to
run Docker is different, you need to add `-u $UID` to `docker run` invocation. Otherwise Maven will
not be able to to write files in `$HOME/.m2` and project `target` directory.

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact us
through a [GitHub issue](https://github.com/carlossg/docker-maven/issues).

You can also reach many of the official image maintainers via the `#docker-library` IRC channel on Freenode.

## Contributing

You are invited to contribute new features, fixes, or updates, large or small; we are always thrilled to receive pull requests, and do our best to process them as fast as we can.

Before you start to code, we recommend discussing your plans through a [GitHub issue](https://github.com/carlossg/docker-maven/issues),
especially for more ambitious contributions.
This gives other contributors a chance to point you in the right direction,
give you feedback on your design, and help you find out if someone else is working on the same thing.
