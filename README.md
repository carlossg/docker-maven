docker-maven
============

# Supported tags and respective Dockerfile links

Images are published under:

* [`csanchez/maven`](https://hub.docker.com/r/csanchez/maven)
* [`maven`](https://hub.docker.com/_/maven) (linux and extending Docker official images only)
* [`ghcr.io/carlossg/maven`](https://github.com/users/carlossg/packages/container/maven) (linux only)

## Linux Based Images

See Docker Hub or GitHub Container Registry for an updated list of tags

* [openjdk-8](https://github.com/carlossg/docker-maven/blob/master/openjdk-8/Dockerfile)
* [openjdk-8-slim](https://github.com/carlossg/docker-maven/blob/master/openjdk-8-slim/Dockerfile)
* [openjdk-11](https://github.com/carlossg/docker-maven/blob/master/openjdk-11/Dockerfile)
* [openjdk-11-slim](https://github.com/carlossg/docker-maven/blob/master/openjdk-11-slim/Dockerfile)
* [openjdk-15](https://github.com/carlossg/docker-maven/blob/master/openjdk-15/Dockerfile)
* [openjdk-15-slim](https://github.com/carlossg/docker-maven/blob/master/openjdk-15-slim/Dockerfile)
* [openjdk-16](https://github.com/carlossg/docker-maven/blob/master/openjdk-16/Dockerfile)
* [openjdk-16-slim](https://github.com/carlossg/docker-maven/blob/master/openjdk-16-slim/Dockerfile)
* [openjdk-17](https://github.com/carlossg/docker-maven/blob/master/openjdk-17/Dockerfile)
* [openjdk-17-slim](https://github.com/carlossg/docker-maven/blob/master/openjdk-17-slim/Dockerfile)
* [adoptopenjdk-8](https://github.com/carlossg/docker-maven/blob/master/adoptopenjdk-8/Dockerfile)
* [adoptopenjdk-8-openj9](https://github.com/carlossg/docker-maven/blob/master/adoptopenjdk-8-openj9/Dockerfile)
* [adoptopenjdk-11](https://github.com/carlossg/docker-maven/blob/master/adoptopenjdk-11/Dockerfile)
* [adoptopenjdk-11-openj9](https://github.com/carlossg/docker-maven/blob/master/adoptopenjdk-11-openj9/Dockerfile)
* [adoptopenjdk-14](https://github.com/carlossg/docker-maven/blob/master/adoptopenjdk-14/Dockerfile)
* [adoptopenjdk-14-openj9](https://github.com/carlossg/docker-maven/blob/master/adoptopenjdk-14-openj9/Dockerfile)
* [adoptopenjdk-15](https://github.com/carlossg/docker-maven/blob/master/adoptopenjdk-15/Dockerfile)
* [adoptopenjdk-15-openj9](https://github.com/carlossg/docker-maven/blob/master/adoptopenjdk-15-openj9/Dockerfile)
* [ibmjava-8](https://github.com/carlossg/docker-maven/blob/master/ibmjava-8/Dockerfile)
* [ibmjava-8-alpine](https://github.com/carlossg/docker-maven/blob/master/ibmjava-8-alpine/Dockerfile)
* [amazoncorretto-8](https://github.com/carlossg/docker-maven/blob/master/amazoncorretto-8/Dockerfile)
* [amazoncorretto-11](https://github.com/carlossg/docker-maven/blob/master/amazoncorretto-11/)
* [amazoncorretto-15](https://github.com/carlossg/docker-maven/blob/master/amazoncorretto-15/)

Only under `csanchez/maven` and `ghcr.io/carlossg/maven`:

* [azulzulu-11](https://github.com/carlossg/docker-maven/blob/master/azulzulu-11/Dockerfile)
* [azulzulu-11-alpine](https://github.com/carlossg/docker-maven/blob/master/azulzulu-11-alpine/Dockerfile)
* [azulzulu-14](https://github.com/carlossg/docker-maven/blob/master/azulzulu-14/Dockerfile)
* [azulzulu-14-alpine](https://github.com/carlossg/docker-maven/blob/master/azulzulu-14-alpine/Dockerfile)
* [libericaopenjdk-11](https://github.com/carlossg/docker-maven/blob/master/libericaopenjdk-11/Dockerfile)
* [libericaopenjdk-11-alpine](https://github.com/carlossg/docker-maven/blob/master/libericaopenjdk-11-alpine/Dockerfile)
* [libericaopenjdk-8](https://github.com/carlossg/docker-maven/blob/master/libericaopenjdk-8/Dockerfile)
* [libericaopenjdk-8-alpine](https://github.com/carlossg/docker-maven/blob/master/libericaopenjdk-8-alpine/Dockerfile)

## Windows Based Images

See Docker Hub [`csanchez/maven`](https://hub.docker.com/r/csanchez/maven) for an updated list of tags

* [openjdk-8-windowsservercore-1809](https://github.com/carlossg/docker-maven/blob/master/openjdk-8-windowsservercore/Dockerfile)
* [openjdk-8-nanoserver](https://github.com/carlossg/docker-maven/blob/master/openjdk-8-nanoserver/Dockerfile)
* [openjdk-11-windowsservercore-1809](https://github.com/carlossg/docker-maven/blob/master/openjdk-11-windowsservercore/Dockerfile)
* [openjdk-11-nanoserver](https://github.com/carlossg/docker-maven/blob/master/openjdk-11-nanoserver/Dockerfile)
* [adoptopenjdk-8-openj9-windowsservercore-1809](https://github.com/carlossg/docker-maven/blob/master/adoptopenjdk-8-openj9-windowsservercore/Dockerfile)
* [adoptopenjdk-11-openj9-windowsservercore-1809](https://github.com/carlossg/docker-maven/blob/master/adoptopenjdk-11-openj9-windowsservercore/Dockerfile)
* [amazoncorretto-8-windowsservercore-1809](https://github.com/carlossg/docker-maven/blob/master/amazoncorretto-8-windowsservercore/Dockerfile)
* [amazoncorretto-11-windowsservercore-1809](https://github.com/carlossg/docker-maven/blob/master/amazoncorretto-11-windowsservercore/Dockerfile)
* [amazoncorretto-15-windowsservercore-1809](https://github.com/carlossg/docker-maven/blob/master/amazoncorretto-15-windowsservercore/Dockerfile)
* [azulzulu-11-windowsservercore-1809](https://github.com/carlossg/docker-maven/blob/master/azulzulu-11-windowsservercore/Dockerfile)


# What is Maven?

[Apache Maven](http://maven.apache.org) is a software project management and comprehension tool.
Based on the concept of a project object model (POM),
Maven can manage a project's build,
reporting and documentation from a central piece of information.


# How to use this image

You can run a Maven project by using the Maven Docker image directly,
passing a Maven command to `docker run`:

### Linux

    docker run -it --rm --name my-maven-project -v "$(pwd)":/usr/src/mymaven -w /usr/src/mymaven maven:3.3-jdk-8 mvn verify

### Windows

```powershell
docker run -it --rm --name my-maven-project -v "$(Get-Location)":C:/Src -w C:/Src csanchez/maven:3.3-jdk-8-windows mvn verify
```

### Windows

```powershell
docker run -it --rm --name my-maven-project -v "$(Get-Location)":C:/Src -w C:/Src maven:3.3-jdk-8-windows mvn clean install
```

## Building local Docker image (optional)

This is a base image that you can extend, so it has the bare minimum packages needed. If you add custom package(s) to the `Dockerfile`, then you can build your local Docker image like this:

    docker build --tag my_local_maven:3.8.1-jdk-8 .


# Multi-stage Builds

You can build your application with Maven and package it in an image that does not include Maven using [multi-stage builds](https://docs.docker.com/engine/userguide/eng-image/multistage-build/).

```
# build
FROM maven
WORKDIR /usr/src/app
COPY pom.xml .
RUN mvn -B -e -C -T 1C org.apache.maven.plugins:maven-dependency-plugin:3.1.2:go-offline
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

    docker run -it --rm -v "$PWD":/usr/src/mymaven -v "$HOME/.m2":/root/.m2 -v "$PWD/target:/usr/src/mymaven/target" -w /usr/src/mymaven maven mvn package  


# Packaging a local repository with the image

The `$MAVEN_CONFIG` dir (default to `/root/.m2` or `C:\Users\ContainerUser\.m2`) could be configured as a volume so anything copied there in a Dockerfile 
at build time is lost. For that reason the dir `/usr/share/maven/ref/` (or `C:\ProgramData\Maven\Reference`) exists, and anything in that directory will be copied 
on container startup to `$MAVEN_CONFIG`.

To create a pre-packaged repository, create a `pom.xml` with the dependencies you need and use this in your `Dockerfile`.
`/usr/share/maven/ref/settings-docker.xml` (`C:\ProgramData\Maven\Reference\settings-docker.xml`) is a settings file that 
changes the local repository to `/usr/share/maven/ref/repository` (`C:\Programdata\Maven\Reference\repository`),
but you can use your own settings file as long as it uses `/usr/share/maven/ref/repository` (`C:\ProgramData\Maven\Reference\repository`) 
as local repo.

    COPY pom.xml /tmp/pom.xml
    RUN mvn -B -f /tmp/pom.xml -s /usr/share/maven/ref/settings-docker.xml dependency:resolve

To add your custom `settings.xml` file to the image use

    COPY settings.xml /usr/share/maven/ref/

For an example, check the `tests` dir


# Running as non-root (not supported on Windows)

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

Tests are written using [bats](https://github.com/sstephenson/bats) for Linux images and [pester](https://github.com/pester/Pester) for Windows images 
(requires Pester 4.x) under the `tests` dir.

Use the env var TAG to choose what image to run tests against.

### Linux
    TAG=openjdk-16 bats tests

### Windows
```powershell
$env:TAG="openjdk-11" ; Invoke-Pester -Path tests
```

or run all the tests with

### Linux
    for dir in $(/bin/ls -1 -d */ | grep -v 'tests\|windows'); do TAG=$(basename $dir) bats tests; done

### Windows
```powershell
Get-ChildItem -File -Include "*windows*" | ForEach-Object { Push-Location ; $env:TAG=$_.Name ; Invoke-Pester -Path tests ; Pop-Location }
```

Bats can be easily installed with `brew install bats` on OS X.

Note that you may first need to:

```sh
git submodule init
git submodule update
```

Pester comes with most modern Windows (Windows 10 and Windows Server 2019), but is an older version than required. You may need to follow [this tutorial](https://blog.damianflynn.com/Windows10-Pester/) on upgrading Pester to 4.x.


## Publishing to Docker Hub

In order to publish the images a PR needs to be opened against [docker-library/official-images](https://github.com/docker-library/official-images)

For that we use `publish.sh` that runs `generate-stackbrew-library.sh`

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
