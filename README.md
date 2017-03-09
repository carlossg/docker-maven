docker-maven
============

# Supported tags and respective Dockerfile links

* [jdk-7](https://github.com/carlossg/docker-maven/blob/master/jdk-7/Dockerfile)
* [jdk-7-onbuild](https://github.com/carlossg/docker-maven/blob/master/jdk-7/onbuild/Dockerfile)
* [latest, jdk-8](https://github.com/carlossg/docker-maven/blob/master/jdk-8/Dockerfile)
* [onbuild, jdk-8-onbuild](https://github.com/carlossg/docker-maven/blob/master/jdk-8/onbuild/Dockerfile)
* [jdk-9](https://github.com/carlossg/docker-maven/blob/master/jdk-9/Dockerfile)
* [jdk-9-onbuild](https://github.com/carlossg/docker-maven/blob/master/jdk-9/onbuild/Dockerfile)

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
The build will `COPY . /usr/src/app` and `RUN mvn install`.

You can then build and run the image:

    docker build -t my-maven .
    docker run -it --name my-maven-script my-maven


## Run a single Maven command

For many simple projects, you may find it inconvenient to write a complete `Dockerfile`.
In such cases, you can run a Maven project by using the Maven Docker image directly,
passing a Maven command to `docker run`:

    docker run -it --rm --name my-maven-project -v "$(pwd)":/usr/src/mymaven -w /usr/src/mymaven maven:3.3-jdk-7 mvn clean install


# Reusing the Maven local repository

The local Maven repository can be reused across containers by creating a volume and mounting it in `/root/.m2`.

    docker volume create --name maven-repo
    docker run -it -v maven-repo:/root/.m2 maven mvn archetype:generate # will download artifacts
    docker run -it -v maven-repo:/root/.m2 maven mvn archetype:generate # will reuse downloaded artifacts

Or you can just use your home .m2 cache directory that you share e.g. with your Eclipse/IDEA:

    docker run -it --rm -v "$PWD":/usr/src/mymaven -v "$HOME/.m2":/root/.m2 -v "$PWD/target:/usr/srv/mymaven/target" -w /usr/src/mymaven maven mvn clean package  
    
# Packaging a local repository with the image

The `$MAVEN_CONFIG` dir (default to `/root/.m2`) is configured as a volume so anything copied there in a Dockerfile at build time is lost.
For that the dir `/usr/share/maven/ref/` is created, and anything in there will be copied on container startup to `$MAVEN_CONFIG`.

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

# Building

Build with the usual

    docker build -t maven .

Tests are written using [bats](https://github.com/sstephenson/bats) under the `tests` dir.
Use the env var TAG to choose what image to run tests against.

    TAG=jdk-8 bats tests

or run all the tests with

    for tag in jdk-7 jdk-8 jdk-9; do TAG=$tag bats tests; done

Bats can be easily installed with `brew install bats` on OS X


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
