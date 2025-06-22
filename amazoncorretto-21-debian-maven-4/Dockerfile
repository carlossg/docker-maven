# Update EXTRA_TAG_SUFFIXES to new release when changing to next stable debian release
# EXTRA_TAG_SUFFIXES=bookworm
FROM debian:bookworm-slim

# install corretto after verifying that the key is the one we expect.
# and keep openssh client
RUN apt-get update \
  && apt-get install -y curl gnupg openssh-client \
  && export GNUPGHOME="$(mktemp -d)" \
  && curl -fL https://apt.corretto.aws/corretto.key -o corretto.key \
  && echo '5fdaed0a262b975776b1d5c0170d2e86b1be1e98b27ef97114b04ec9ac7f011d *corretto.key' | sha256sum -c - \
  && gpg --batch --import corretto.key \
  && rm corretto.key \
  && gpg --batch --export '6DC3636DAE534049C8B94623A122542AB04F24E3' > /usr/share/keyrings/corretto.gpg \
  && unset GNUPGHOME \
  && echo "deb [signed-by=/usr/share/keyrings/corretto.gpg] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list \
  && apt-get update \
  && apt-get remove --purge --autoremove -y curl gnupg \
  && apt-get install -y java-21-amazon-corretto-jdk \
  && rm -rf /var/lib/apt/lists/*

# set JAVA_HOME manually since nothing else will set it
ENV JAVA_HOME="/usr/lib/jvm/java-21-amazon-corretto"

# common for all images
LABEL org.opencontainers.image.title="Apache Maven"
LABEL org.opencontainers.image.source=https://github.com/carlossg/docker-maven
LABEL org.opencontainers.image.url=https://github.com/carlossg/docker-maven
LABEL org.opencontainers.image.description="Apache Maven is a software project management and comprehension tool. Based on the concept of a project object model (POM), Maven can manage a project's build, reporting and documentation from a central piece of information."

ENV MAVEN_HOME=/usr/share/maven

COPY --from=ghcr.io/carlossg/maven:4.0.0-rc-3-eclipse-temurin-17 ${MAVEN_HOME} ${MAVEN_HOME}
COPY --from=ghcr.io/carlossg/maven:4.0.0-rc-3-eclipse-temurin-17 /usr/local/bin/mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY --from=ghcr.io/carlossg/maven:4.0.0-rc-3-eclipse-temurin-17 /usr/share/maven/ref/settings-docker.xml /usr/share/maven/ref/settings-docker.xml

RUN ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn

ARG MAVEN_VERSION=4.0.0-rc-3
ARG USER_HOME_DIR="/root"
ENV MAVEN_CONFIG="$USER_HOME_DIR/.m2"

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]
