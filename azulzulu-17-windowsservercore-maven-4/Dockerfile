# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2019

LABEL org.opencontainers.image.title="Apache Maven"
LABEL org.opencontainers.image.source=https://github.com/carlossg/docker-maven
LABEL org.opencontainers.image.url=https://github.com/carlossg/docker-maven
LABEL org.opencontainers.image.description="Apache Maven is a software project management and comprehension tool. Based on the concept of a project object model (POM), Maven can manage a project's build, reporting and documentation from a central piece of information."

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG zip=zulu17.48.15-ca-jdk17.0.10-win_x64.zip
ARG uri=https://cdn.azul.com/zulu/bin
ARG hash=169bcb1c519a1cf18e3589bcbaea036eb8114311425660e6c919376227855be3

RUN Invoke-WebRequest -Uri $('{0}/{1}' -f $env:uri,$env:zip) -OutFile C:/$env:zip ; `
    if((Get-FileHash C:/$env:zip -Algorithm SHA256).Hash.ToLower() -ne $env:hash) { exit 1 } ; `
    Expand-Archive -Path C:/$env:zip -Destination C:/ProgramData ; `
    Remove-Item C:/${env:zip}

ARG USER_HOME_DIR="C:/Users/ContainerUser"
ARG MAVEN_VERSION=4.0.0-beta-3
ARG SHA=49d656042813ead127613da3c85e063c41ef5a25b54ec783d90b51fbc1ad7401f0c0d4c860536d6baea180ab533c84d52c8e38b0c6ab52cc699105ead0418ab4
ARG BASE_URL=https://apache.osuosl.org/maven/maven-4/${MAVEN_VERSION}/binaries

RUN Invoke-WebRequest -Uri ${env:BASE_URL}/apache-maven-${env:MAVEN_VERSION}-bin.zip -OutFile ${env:TEMP}/apache-maven.zip ; `
  if((Get-FileHash -Algorithm SHA512 -Path ${env:TEMP}/apache-maven.zip).Hash.ToLower() -ne ${env:SHA}) { exit 1 } ; `
  Expand-Archive -Path ${env:TEMP}/apache-maven.zip -Destination C:/ProgramData ; `
  Move-Item C:/ProgramData/apache-maven-${env:MAVEN_VERSION} C:/ProgramData/Maven ; `
  New-Item -ItemType Directory -Path C:/ProgramData/Maven/Reference | Out-Null ; `
  Remove-Item ${env:TEMP}/apache-maven.zip

ENV MAVEN_HOME=C:/ProgramData/Maven
ENV MAVEN_CONFIG="$USER_HOME_DIR/.m2"

ENV JAVA_HOME=C:/ProgramData/zulu17.48.15-ca-jdk17.0.10-win_x64

COPY mvn-entrypoint.ps1 C:/ProgramData/Maven/mvn-entrypoint.ps1
COPY settings-docker.xml C:/ProgramData/Maven/Reference/settings-docker.xml

RUN setx /M PATH $('{0};{1}' -f $env:PATH,'C:\ProgramData\Maven\bin') | Out-Null

USER ContainerUser
ENV JAVA_HOME=${JAVA_HOME}

ENTRYPOINT ["powershell.exe", "-f", "C:/ProgramData/Maven/mvn-entrypoint.ps1"]
CMD ["mvn"]
