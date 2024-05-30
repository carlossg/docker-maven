docker-maven
============

# Supported tags and respective Dockerfile links

Images are published under:

* [`csanchez/maven`](https://hub.docker.com/r/csanchez/maven)
* [`maven`](https://hub.docker.com/_/maven) (linux and extending Docker official images only)
* [`ghcr.io/carlossg/maven`](https://github.com/carlossg/docker-maven/pkgs/container/maven) (linux only)

## Linux Based Images

See Docker Hub or GitHub Container Registry for an updated list of tags

* [eclipse-temurin-16](https://github.com/carlossg/docker-maven/blob/main/eclipse-temurin-16/Dockerfile)
* [eclipse-temurin-16-alpine](https://github.com/carlossg/docker-maven/blob/main/eclipse-temurin-16-alpine/Dockerfile)
* [eclipse-temurin-17](https://github.com/carlossg/docker-maven/blob/main/eclipse-temurin-17/Dockerfile)
* [eclipse-temurin-17-alpine](https://github.com/carlossg/docker-maven/blob/main/eclipse-temurin-17-alpine/Dockerfile)
* [eclipse-temurin-17-focal](https://github.com/carlossg/docker-maven/blob/main/eclipse-temurin-17-focal/Dockerfile)
* [eclipse-temurin-21](https://github.com/carlossg/docker-maven/blob/main/eclipse-temurin-21/Dockerfile)
* [eclipse-temurin-21-alpine](https://github.com/carlossg/docker-maven/blob/main/eclipse-temurin-21-alpine/Dockerfile)
* [eclipse-temurin-21-jammy](https://github.com/carlossg/docker-maven/blob/main/eclipse-temurin-21-jammy/Dockerfile)
* [eclipse-temurin-22](https://github.com/carlossg/docker-maven/blob/main/eclipse-temurin-22/Dockerfile)
* [eclipse-temurin-22-alpine](https://github.com/carlossg/docker-maven/blob/main/eclipse-temurin-22-alpine/Dockerfile)
* [eclipse-temurin-22-jammy](https://github.com/carlossg/docker-maven/blob/main/eclipse-temurin-22-jammy/Dockerfile)
* [ibm-semeru-17-focal](https://github.com/carlossg/docker-maven/blob/main/ibm-semeru-17-focal/Dockerfile)
* [ibm-semeru-21-jammy](https://github.com/carlossg/docker-maven/blob/main/ibm-semeru-21-jammy/Dockerfile)
* [amazoncorretto-17](https://github.com/carlossg/docker-maven/blob/main/amazoncorretto-17/)
* [amazoncorretto-17-al2023](https://github.com/carlossg/docker-maven/blob/main/amazoncorretto-17-al2023/Dockerfile)
* [amazoncorretto-17-debian](https://github.com/carlossg/docker-maven/blob/main/amazoncorretto-17-debian/Dockerfile)
* [amazoncorretto-21](https://github.com/carlossg/docker-maven/blob/main/amazoncorretto-21/)
* [amazoncorretto-21-al2023](https://github.com/carlossg/docker-maven/blob/main/amazoncorretto-21-al2023/)
* [amazoncorretto-21-debian](https://github.com/carlossg/docker-maven/blob/main/amazoncorretto-21-debian/Dockerfile)
* [sapmachine-17](https://github.com/carlossg/docker-maven/blob/main/sapmachine-17/)
* [sapmachine-21](https://github.com/carlossg/docker-maven/blob/main/sapmachine-21/)
* [sapmachine-22](https://github.com/carlossg/docker-maven/blob/main/sapmachine-22/)

Only under `csanchez/maven` and `ghcr.io/carlossg/maven`:
* [azulzulu-17](https://github.com/carlossg/docker-maven/blob/main/azulzulu-17/Dockerfile)
* [azulzulu-17-alpine](https://github.com/carlossg/docker-maven/blob/main/azulzulu-17-alpine/Dockerfile)
* [azulzulu-21](https://github.com/carlossg/docker-maven/blob/main/azulzulu-21/Dockerfile)
* [azulzulu-21-alpine](https://github.com/carlossg/docker-maven/blob/main/azulzulu-21-alpine/Dockerfile)
* [graalvm-community-17](https://github.com/carlossg/docker-maven/blob/main/graalvm-community-17/)
* [graalvm-community-21](https://github.com/carlossg/docker-maven/blob/main/graalvm-community-21/)
* [libericaopenjdk-17](https://github.com/carlossg/docker-maven/blob/main/libericaopenjdk-17/Dockerfile)
* [libericaopenjdk-17-alpine](https://github.com/carlossg/docker-maven/blob/main/libericaopenjdk-17-alpine/Dockerfile)
* [microsoft-openjdk-17-ubuntu](https://github.com/carlossg/docker-maven/blob/main/microsoft-openjdk-17-ubuntu/Dockerfile)
* [microsoft-openjdk-21-ubuntu](https://github.com/carlossg/docker-maven/blob/main/microsoft-openjdk-21-ubuntu/Dockerfile)
* [oracle-graalvm-17](https://github.com/carlossg/docker-maven/blob/main/oracle-graalvm-17/)
* [oracle-graalvm-21](https://github.com/carlossg/docker-maven/blob/main/oracle-graalvm-21/)

## Windows Based Images

See Docker Hub [`csanchez/maven`](https://hub.docker.com/r/csanchez/maven) for an updated list of tags

* [amazoncorretto-17-windowsservercore-1809](https://github.com/carlossg/docker-maven/blob/main/amazoncorretto-17-windowsservercore/Dockerfile)
* [azulzulu-17-windowsservercore-1809](https://github.com/carlossg/docker-maven/blob/main/azulzulu-17-windowsservercore/Dockerfile)


# What is Maven?

[Apache Maven](http://maven.apache.org) is a software project management and comprehension tool.
Based on the concept of a project object model (POM),
Maven can manage a project's build,
reporting and documentation from a central piece of information.


# How to use this image

You can run a Maven project by using the Maven Docker image directly,
passing a Maven command to `docker run`:

### Linux

    docker run -it --rm --name my-maven-project -v "$(pwd)":/usr/src/mymaven -w /usr/src/mymaven maven:3.3-jdk-17 mvn verify

### Windows

```powershell
docker run -it --rm --name my-maven-project -v "$(Get-Location)":C:/Src -w C:/Src csanchez/maven:3.3-jdk-17-windows mvn verify
```

### Windows

```powershell
docker run -it --rm --name my-maven-project -v "$(Get-Location)":C:/Src -w C:/Src maven:3.3-jdk-17-windows mvn clean install
```

## Building local Docker image (optional)

This is a base image that you can extend, so it has the bare minimum packages needed. If you add custom package(s) to the `Dockerfile`, then you can build your local Docker image like this:

    docker build --tag my_local_maven:4.0.0-beta-3-jdk-8 .


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
FROM eclipse-temurin:17-jdk
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

For example, to run as the current user (instead of root), mounting the host Maven repo (at `~/.m2`)

    docker run -v ~/.m2:/var/maven/.m2 -it --rm -u $(id -u) -e MAVEN_CONFIG=/var/maven/.m2 maven mvn -Duser.home=/var/maven archetype:generate


# Image Variants

The `maven` images come in many flavors, each designed for a specific use case.

## `maven:<version>`

This is the defacto image. If you are unsure about what your needs are, you probably want to use this one. It is designed to be used both as a throw away container (mount your source code and start the container to start your app), as well as the base to build other images off of.

# Installed Packages

The following packages are currently installed in each variant.
Some come from the parent images and some are installed in this image for backwards compatibility.

|                               | git | curl | tar | bash | which | gzip | procps | gpg | ssh |
|-------------------------------|-----|------|-----|------|-------|------|--------|-----|-----|
| amazoncorretto-17             |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    |        | ✔️   |     |
| amazoncorretto-17-al2023      |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    |        | ✔️   |     |
| amazoncorretto-17-debian      |     |      | ✔️   | ✔️    | ✔️     | ✔️    |        |     |     |
| amazoncorretto-21             |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    |        | ✔️   |     |
| amazoncorretto-21-al2023      |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    |        | ✔️   |     |
| amazoncorretto-21-debian      |     |      | ✔️   | ✔️    | ✔️     | ✔️    |        |     |     |
| azulzulu-17                   |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| azulzulu-17-alpine            |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| azulzulu-21                   |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| azulzulu-21-alpine            |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| eclipse-temurin-17            | ✔️   | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| eclipse-temurin-17-alpine     |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| eclipse-temurin-17-focal      | ✔️   | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| eclipse-temurin-21            | ✔️   | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| eclipse-temurin-21-alpine     |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| eclipse-temurin-22-jammy      | ✔️   | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| eclipse-temurin-22            | ✔️   | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| eclipse-temurin-22-alpine     |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| eclipse-temurin-22-jammy      | ✔️   | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| graalvm-community-17          |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    |        | ✔️   |     |
| graalvm-community-21          |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    |        | ✔️   |     |
| ibm-semeru-17-focal           | ✔️   | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| ibm-semeru-21-jammy           | ✔️   | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| libericaopenjdk-17            |     | ✔️    | ✔️   | ✔️    |       | ✔️    | ✔️      | ✔️   |     |
| libericaopenjdk-17-alpine     |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| libericaopenjdk-17-debian     |     | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    |        |     |     |
| microsoft-openjdk-17-ubuntu   | ✔️   | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      | ✔️   |     |
| microsoft-openjdk-21-ubuntu   | ✔️   | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      | ✔️   |     |
| oracle-graalvm-17             |     | ✔️    | ✔️   | ✔️    |       | ✔️    |        | ✔️   |     |
| oracle-graalvm-21             |     | ✔️    | ✔️   | ✔️    |       | ✔️    |        | ✔️   |     |
| sapmachine-11                 | ✔️   | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| sapmachine-17                 | ✔️   | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| sapmachine-21                 | ✔️   | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |
| sapmachine-22                 | ✔️   | ✔️    | ✔️   | ✔️    | ✔️     | ✔️    | ✔️      |     |     |



# Image Verification

Images under `csanchez/maven` and `ghcr.io/carlossg/maven` are signed with [sigstore/cosign](https://github.com/sigstore/cosign)
using GitHub OIDC

Verification can be done with `cosign verify`

Example:

```
COSIGN_EXPERIMENTAL=true cosign verify csanchez/maven:3-eclipse-temurin-17
```

# Building

Build with the usual

    docker build -t maven .

Tests are written using [bats](https://github.com/sstephenson/bats) for Linux images and [pester](https://github.com/pester/Pester) for Windows images
(requires Pester 4.x) under the `tests` dir.

Use the env var TAG to choose what image to run tests against.

### Linux
    TAG=eclipse-temurin-17 bats tests

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

Bats can be easily installed with `brew install bats-core` on OS X.

Note that you may first need to:

```sh
git submodule init
git submodule update
```

Pester comes with most modern Windows (Windows 10 and Windows Server 2019), but is an older version than required. You may need to follow [this tutorial](https://blog.damianflynn.com/Windows10-Pester/) on upgrading Pester to 4.x.


## Adding New Images

* Copy an existing dir (other than `eclipse-temurin-11`) to the new name and update `Dockerfile` as needed.
* Update `README.md` to include the new image and table with packages installed in that image.
* When adding a new JDK then it also needs to be added to the beginning of `common.sh`
* Run `github-action-generation.sh` to generate new GitHub Actions for the new image
* When a parent image changes the `latest` tag to a new JDK version it can be updated in `common.sh`

## Updating Maven version

* Search and replace all references to the previous version by the new version.
* Update environment variable SHA in `eclipse-temurin-17/Dockerfile` with value found in [maven download page](https://maven.apache.org/download.cgi) for the binary tar.gz archive.
* Update environment variable SHA in `*-{nanoserver,windowsservercore}/Dockerfile` with value found in [maven download page](https://maven.apache.org/download.cgi) for the binary zip archive.

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
