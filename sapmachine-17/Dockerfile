FROM sapmachine:17

RUN apt-get update \
  && apt-get install -y ca-certificates curl git --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# common for all images
LABEL org.opencontainers.image.title "Apache Maven"
LABEL org.opencontainers.image.source https://github.com/carlossg/docker-maven
LABEL org.opencontainers.image.url https://github.com/carlossg/docker-maven
LABEL org.opencontainers.image.description "Apache Maven is a software project management and comprehension tool. Based on the concept of a project object model (POM), Maven can manage a project's build, reporting and documentation from a central piece of information."

ENV MAVEN_HOME /usr/share/maven

COPY --from=ghcr.io/carlossg/maven:4.0.0-beta-3-eclipse-temurin-17 ${MAVEN_HOME} ${MAVEN_HOME}
COPY --from=ghcr.io/carlossg/maven:4.0.0-beta-3-eclipse-temurin-17 /usr/local/bin/mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY --from=ghcr.io/carlossg/maven:4.0.0-beta-3-eclipse-temurin-17 /usr/share/maven/ref/settings-docker.xml /usr/share/maven/ref/settings-docker.xml

RUN ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn

ARG MAVEN_VERSION=4.0.0-beta-3
ARG USER_HOME_DIR="/root"
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]
