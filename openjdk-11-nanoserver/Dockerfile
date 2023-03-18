# escape=`
ARG JAVA_VERSION=11.0.6
# we use the latest stable if nothing is passed
ARG POWERSHELL_VERSION=

FROM openjdk:${JAVA_VERSION}-windowsservercore-1809 as openjdk

FROM mcr.microsoft.com/powershell:${POWERSHELL_VERSION}nanoserver-1809 

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

USER ContainerAdministrator

ENV JAVA_HOME=C:\openjdk-11

COPY --from=openjdk $JAVA_HOME $JAVA_HOME

ENV ProgramFiles="C:\Program Files"
ENV WindowsPATH="C:\Windows\system32;C:\Windows"

ARG USER_HOME_DIR="C:/Users/ContainerUser"
ARG MAVEN_VERSION=3.9.1
ARG SHA=4ae5a0d17f9e6cbe57640c481f426a9184dfb451c2bb7cc7db324da095f616a14e7c482a79240e5286e241d8cd2805ea1cd9c95e38954101c2fa4088baad9a1a
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN Invoke-WebRequest -Uri ${env:BASE_URL}/apache-maven-${env:MAVEN_VERSION}-bin.zip -OutFile ${env:TEMP}/apache-maven.zip ; `
  if((Get-FileHash -Algorithm SHA512 -Path ${env:TEMP}/apache-maven.zip).Hash.ToLower() -ne ${env:SHA}) { exit 1 } ; `
  Expand-Archive -Path ${env:TEMP}/apache-maven.zip -Destination C:/ProgramData ; `
  Move-Item C:/ProgramData/apache-maven-${env:MAVEN_VERSION} C:/ProgramData/Maven ; `
  New-Item -ItemType Directory -Path C:/ProgramData/Maven/Reference | Out-Null ; `
  Remove-Item ${env:TEMP}/apache-maven.zip

ENV MAVEN_HOME C:/ProgramData/Maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

COPY mvn-entrypoint.ps1 C:/ProgramData/Maven/mvn-entrypoint.ps1
COPY settings-docker.xml C:/ProgramData/Maven/Reference/settings-docker.xml

USER ContainerUser

ENV PATH="${WindowsPATH};${ProgramFiles}\PowerShell;${JAVA_HOME}\bin;${MAVEN_HOME}\bin"

ENTRYPOINT ["pwsh", "-f", "C:/ProgramData/Maven/mvn-entrypoint.ps1"]
CMD ["mvn"]
