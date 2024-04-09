FROM amazoncorretto:21

RUN yum install -y tar which gzip # TODO remove

# common for all images
ENV MAVEN_HOME /usr/share/maven

COPY --from=ghcr.io/carlossg/maven:4.0.0-alpha-13-eclipse-temurin-17 ${MAVEN_HOME} ${MAVEN_HOME}
COPY --from=ghcr.io/carlossg/maven:4.0.0-alpha-13-eclipse-temurin-17 /usr/local/bin/mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY --from=ghcr.io/carlossg/maven:4.0.0-alpha-13-eclipse-temurin-17 /usr/share/maven/ref/settings-docker.xml /usr/share/maven/ref/settings-docker.xml

RUN ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn

ARG MAVEN_VERSION=4.0.0-alpha-13
ARG USER_HOME_DIR="/root"
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]
