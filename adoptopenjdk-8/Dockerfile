FROM alpine:3.10 as maven-download

RUN apk add --update curl \
    && rm -rf /var/cache/apk/*

ENV MAVEN_VERSION=3.6.3 \
    SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
ENV BASE_URL=https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven/; \
    curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz; \
    echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c -; \
    tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1

COPY settings-docker.xml /usr/share/maven/ref/

FROM adoptopenjdk/openjdk8:x86_64-alpine-jdk8u232-b09-slim

# Chose one of the smallest installed packages from this list https://pkgs.alpinelinux.org/packages?page=1&branch=edge&name=ttf-%2A for fonts
# Installing git as a lot of maven plugins require scm
RUN apk add --update git ttf-opensans  \
    && rm -rf /var/cache/apk/*

ENV USER_HOME_DIR="/root"  \
    MAVEN_HOME=/usr/share/maven \
    MAVEN_CONFIG="$USER_HOME_DIR/.m2"

COPY --from=maven-download /usr/share/maven /usr/share/maven

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh

RUN ln -s /usr/share/maven/bin/mvn /usr/bin/mvn; \
    chmod +x /usr/local/bin/mvn-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]
