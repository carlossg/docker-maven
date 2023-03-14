FROM debian:stable-slim

# install corretto
RUN apt-get update \
  && apt-get install -y curl gnupg \
  && curl https://apt.corretto.aws/corretto.key | gpg --dearmor | dd of=/usr/share/keyrings/corretto.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/corretto.gpg] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list \
  && apt-get update \
  && apt-get install -y java-11-amazon-corretto-jdk \
  && rm -rf /var/lib/apt/lists/*

# common for all images
ENV MAVEN_HOME /usr/share/maven

COPY --from=maven:3.9.0-eclipse-temurin-11 ${MAVEN_HOME} ${MAVEN_HOME}
COPY --from=maven:3.9.0-eclipse-temurin-11 /usr/local/bin/mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY --from=maven:3.9.0-eclipse-temurin-11 /usr/share/maven/ref/settings-docker.xml /usr/share/maven/ref/settings-docker.xml

RUN ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn

ARG MAVEN_VERSION=3.9.0
ARG USER_HOME_DIR="/root"
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]
