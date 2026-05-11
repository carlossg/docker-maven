FROM maven:3.9.15-eclipse-temurin-17 AS maven_upstream

FROM bellsoft/liberica-openjdk-debian:11

RUN apt-get update \
  && apt-get install -y openssh-client --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# common for all images
LABEL org.opencontainers.image.title="Apache Maven"
LABEL org.opencontainers.image.source=https://github.com/carlossg/docker-maven
LABEL org.opencontainers.image.url=https://github.com/carlossg/docker-maven
LABEL org.opencontainers.image.description="Apache Maven is a software project management and comprehension tool. Based on the concept of a project object model (POM), Maven can manage a project's build, reporting and documentation from a central piece of information."

ENV MAVEN_HOME=/usr/share/maven

COPY --from=maven_upstream ${MAVEN_HOME} ${MAVEN_HOME}
COPY --from=maven_upstream /usr/local/bin/mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh

RUN ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn
ARG USER_HOME_DIR="/root"
ENV MAVEN_CONFIG="$USER_HOME_DIR/.m2"
RUN mvn org.apache.maven.plugins:maven-toolchains-plugin:3.2.0:generate-jdk-toolchains-xml \
  && mv "$MAVEN_CONFIG/discovered-jdk-toolchains-cache.xml" "$MAVEN_CONFIG/toolchains.xml"

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]
