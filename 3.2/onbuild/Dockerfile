FROM csanchez/maven

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ONBUILD ADD pom.xml /usr/src/app/
ONBUILD RUN mvn install

ONBUILD ADD . /usr/src/app
