FROM mcr.microsoft.com/openjdk/jdk:17-ubuntu

ARG MAVEN_VERSION=3.9.0
ARG USER_HOME_DIR="/root"
ARG SHA=1ea149f4e48bc7b34d554aef86f948eca7df4e7874e30caf449f3708e4f8487c71a5e5c072a05f17c60406176ebeeaf56b5f895090c7346f8238e2da06cf6ecd
ARG BASE_URL=https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

RUN set -x \
  && apt-get update \
  && apt-get install -y ca-certificates curl git gnupg dirmngr --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && curl -fsSLO --compressed ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA} *apache-maven-${MAVEN_VERSION}-bin.tar.gz" | sha512sum -c - \
  && curl -fsSLO --compressed ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz.asc \
  && export GNUPGHOME="$(mktemp -d)" \
  && for key in \
  6A814B1F869C2BBEAB7CB7271A2A1C94BDE89688 \
  29BEA2A645F2D6CED7FB12E02B172E3E156466E8 \
  ; do \
  gpg --batch --keyserver hkps://keyserver.ubuntu.com --recv-keys "$key" ; \
  done \
  && mkdir -p ${MAVEN_HOME} ${MAVEN_HOME}/ref \
  && tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C ${MAVEN_HOME} --strip-components=1 \
  # GNUPGHOME may fail to delete even with -rf
  && (rm -rf "$GNUPGHOME" apache-maven-${MAVEN_VERSION}-bin.tar.gz.asc apache-maven-${MAVEN_VERSION}-bin.tar.gz || true) \
  && ln -s ${MAVEN_HOME}/bin/mvn /usr/bin/mvn \
  && apt-get remove --purge --autoremove -y gnupg dirmngr \
  # smoke test
  && mvn --version

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY settings-docker.xml /usr/share/maven/ref/

ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
CMD ["mvn"]
