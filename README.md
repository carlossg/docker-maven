docker-maven
============

# Supported tags and respective Dockerfile links

See [Docker Hub](https://hub.docker.com/_/maven) for updated list of tags

* [jdk-8](https://github.com/carlossg/docker-maven/blob/master/jdk-8/Dockerfile)
* [jdk-8-slim](https://github.com/carlossg/docker-maven/blob/master/jdk-8-slim/Dockerfile)
* [jdk-10](https://github.com/carlossg/docker-maven/blob/master/jdk-10/Dockerfile)
* [jdk-10-slim](https://github.com/carlossg/docker-maven/blob/master/jdk-10-slim/Dockerfile)
* [jdk-11](https://github.com/carlossg/docker-maven/blob/master/jdk-11/Dockerfile)
* [jdk-11-slim](https://github.com/carlossg/docker-maven/blob/master/jdk-11-slim/Dockerfile)
* [jdk-12](https://github.com/carlossg/docker-maven/blob/master/jdk-12/Dockerfile)
* [jdk-13](https://github.com/carlossg/docker-maven/blob/master/jdk-13/Dockerfile)
* [ibmjava-8](https://github.com/carlossg/docker-maven/blob/master/ibmjava-8/Dockerfile)
* [ibmjava-8-alpine](https://github.com/carlossg/docker-maven/blob/master/ibmjava-8-alpine/Dockerfile)
* [amazoncorretto-8](https://github.com/carlossg/docker-maven/blob/master/amazoncorretto-8/Dockerfile)
* [amazoncorretto-11](https://github.com/carlossg/docker-maven/blob/master/amazoncorretto-11/
* [azulzulu-11](https://github.com/carlossg/docker-maven/blob/master/azulzulu-11/

# What is Maven?

[Apache Maven](http://maven.apache.org) is a software project management and comprehension tool.
Based on the concept of a project object model (POM),
Maven can manage a project's build,
reporting and documentation from a central piece of information.


# How to use this image

You can run a Maven project by using the Maven Docker image directly,
passing a Maven command to `docker run`:

    docker run -it --rm --name my-maven-project -v "$(pwd)":/usr/src/mymaven -w /usr/src/mymaven maven:3.3-jdk-8 mvn clean install

## Building local Docker image (optional)

This is a base image that you can extend, so it has the bare minimum packages needed. If you add custom package(s) to the `Dockerfile`, then you can build your local Docker image like this:

    docker build --tag my_local_maven:3.6.0-jdk-8 .


# Multi-stage Builds

You can build your application with Maven and package it in an image that does not include Maven using [multi-stage builds](https://docs.docker.com/engine/userguide/eng-image/multistage-build/).

```
# build
FROM maven
WORKDIR /usr/src/app
COPY pom.xml .
RUN mvn -B -e -C -T 1C org.apache.maven.plugins:maven-dependency-plugin:3.0.2:go-offline
COPY . .
RUN mvn -B -e -o -T 1C verify

# package without maven
FROM openjdk
COPY --from=0 /usr/src/app/target/*.jar ./
```

# Reusing the Maven local repository

The local Maven repository can be reused across containers by creating a volume and mounting it in `/root/.m2`.

    docker volume create --name maven-repo
    docker run -it -v maven-repo:/root/.m2 maven mvn archetype:generate # will download artifacts
    docker run -it -v maven-repo:/root/.m2 maven mvn archetype:generate # will reuse downloaded artifacts

Or you can just use your home .m2 cache directory that you share e.g. with your Eclipse/IDEA:

    docker run -it --rm -v "$PWD":/usr/src/mymaven -v "$HOME/.m2":/root/.m2 -v "$PWD/target:/usr/src/mymaven/target" -w /usr/src/mymaven maven mvn clean package  


# Packaging a local repository with the image

The `$MAVEN_CONFIG` dir (default to `/root/.m2`) could be configured as a volume so anything copied there in a Dockerfile at build time is lost.
For that reason the dir `/usr/share/maven/ref/` exists, and anything in that directory will be copied on container startup to `$MAVEN_CONFIG`.

To create a pre-packaged repository, create a `pom.xml` with the dependencies you need and use this in your `Dockerfile`.
`/usr/share/maven/ref/settings-docker.xml` is a settings file that changes the local repository to `/usr/share/maven/ref/repository`,
but you can use your own settings file as long as it uses `/usr/share/maven/ref/repository` as local repo.

    COPY pom.xml /tmp/pom.xml
    RUN mvn -B -f /tmp/pom.xml -s /usr/share/maven/ref/settings-docker.xml dependency:resolve

To add your custom `settings.xml` file to the image use

    COPY settings.xml /usr/share/maven/ref/

For an example, check the `tests` dir


# Running as non-root

Maven needs the user home to download artifacts to, and if the user does not exist in the image an extra
`user.home` Java property needs to be set.

For example, to run as user `1000` mounting the host' Maven repo

    docker run -v ~/.m2:/var/maven/.m2 -ti --rm -u 1000 -e MAVEN_CONFIG=/var/maven/.m2 maven mvn -Duser.home=/var/maven archetype:generate


# Image Variants

The `maven` images come in many flavors, each designed for a specific use case.

## `maven:<version>`

This is the defacto image. If you are unsure about what your needs are, you probably want to use this one. It is designed to be used both as a throw away container (mount your source code and start the container to start your app), as well as the base to build other images off of.

# Building

Build with the usual

    docker build -t maven .

Tests are written using [bats](https://github.com/sstephenson/bats) under the `tests` dir.
Use the env var TAG to choose what image to run tests against.

    TAG=jdk-11 bats tests

or run all the tests with

    for dir in $(/bin/ls -1 -d */ | grep -v tests); do TAG=$(basename $dir) bats tests; done

Bats can be easily installed with `brew install bats` on OS X.

Note that you may first need to:

```sh
git submodule init
git submodule update
```

# License

View [license information](https://www.apache.org/licenses/) for the software contained in this image.


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
