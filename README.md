docker-maven
============

# Supported tags and respective Dockerfile links

* [jdk-7](https://github.com/carlossg/docker-maven/blob/master/jdk-7/Dockerfile)
* [jdk-7-alpine](https://github.com/carlossg/docker-maven/blob/alpine/jdk-7/Dockerfile)
* [jdk-7-slim](https://github.com/carlossg/docker-maven/blob/master/jdk-7-slim/Dockerfile)
* [latest, jdk-8](https://github.com/carlossg/docker-maven/blob/master/jdk-8/Dockerfile)
* [alpine, jdk-8-alpine](https://github.com/carlossg/docker-maven/blob/alpine/jdk-8/Dockerfile)
* [slim, jdk-8-slim](https://github.com/carlossg/docker-maven/blob/master/jdk-8-slim/Dockerfile)
* [jdk-9](https://github.com/carlossg/docker-maven/blob/master/jdk-9/Dockerfile)
* [jdk-9-slim](https://github.com/carlossg/docker-maven/blob/master/jdk-9-slim/Dockerfile)
* [jdk-10](https://github.com/carlossg/docker-maven/blob/master/jdk-10/Dockerfile)
* [jdk-10-slim](https://github.com/carlossg/docker-maven/blob/master/jdk-10-slim/Dockerfile)
* [ibmjava-8](https://github.com/carlossg/docker-maven/blob/master/ibmjava-8/Dockerfile)
* [ibmjava-8-alpine](https://github.com/carlossg/docker-maven/blob/alpine/ibmjava-8/Dockerfile)
* [ibmjava-9](https://github.com/carlossg/docker-maven/blob/master/ibmjava-9/Dockerfile)
* [ibmjava-9-alpine](https://github.com/carlossg/docker-maven/blob/alpine/ibmjava-9/Dockerfile)


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

    docker build --tag my_local_maven:3.5.3-jdk-8 .


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

## `maven:alpine`

This image is based on the popular [Alpine Linux project](http://alpinelinux.org), available in [the `alpine` official image](https://hub.docker.com/_/alpine). Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is highly recommended when final image size being as small as possible is desired. The main caveat to note is that it does use [musl libc](http://www.musl-libc.org) instead of [glibc and friends](http://www.etalabs.net/compare_libcs.html), so certain software might run into issues depending on the depth of their libc requirements. However, most software doesn't have an issue with this, so this variant is usually a very safe choice. See [this Hacker News comment thread](https://news.ycombinator.com/item?id=10782897) for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.

To minimize image size, it's uncommon for additional related tools (such as `git` or `bash`) to be included in Alpine-based images. Using this image as a base, add the things you need in your own Dockerfile (see the [`alpine` image description](https://hub.docker.com/_/alpine/) for examples of how to install packages if you are unfamiliar).


# Building

Build with the usual

    docker build -t maven .

Tests are written using [bats](https://github.com/sstephenson/bats) under the `tests` dir.
Use the env var TAG to choose what image to run tests against.

    TAG=jdk-8 bats tests

or run all the tests with

    for dir in $(/bin/ls -1 -d */ | grep -v tests); do TAG=$(basename $dir) bats tests; done

Bats can be easily installed with `brew install bats` on OS X


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
