FROM bats-maven

COPY settings.xml /usr/share/maven/ref/
COPY pom.xml /tmp/pom.xml
COPY src/ /tmp/src
RUN mvn -B -f /tmp/pom.xml -s /usr/share/maven/ref/settings-docker.xml dependency:resolve
