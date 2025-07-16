# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2025

LABEL org.opencontainers.image.title="Apache Maven"
LABEL org.opencontainers.image.source=https://github.com/carlossg/docker-maven
LABEL org.opencontainers.image.url=https://github.com/carlossg/docker-maven
LABEL org.opencontainers.image.description="Apache Maven is a software project management and comprehension tool. Based on the concept of a project object model (POM), Maven can manage a project's build, reporting and documentation from a central piece of information."

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG zip=amazon-corretto-17-x64-windows-jdk.zip
ARG uri=https://corretto.aws/downloads/latest
ARG hash=64086aa7f7f6f40900b28f513b00872f1aaa1a40fe0aa6357084c97e0cd80391

RUN Invoke-WebRequest -Uri $('{0}/{1}' -f $env:uri,$env:zip) -OutFile C:/$env:zip ; `
  if((Get-FileHash C:/$env:zip -Algorithm SHA256).Hash.ToLower() -ne $env:hash) { `
  Write-Error "Checksum for $($env:zip) does not match expected value. Expected: $($env:hash) Actual: $((Get-FileHash C:/$env:zip -Algorithm SHA256).Hash.ToLower())" ; `
  exit 1 } ; `
  Expand-Archive -Path C:/$env:zip -Destination C:/ProgramData ; `
  Remove-Item C:/${env:zip}

ENV JAVA_HOME=C:/ProgramData/jdk17.0.16_8

ARG USER_HOME_DIR="C:/Users/ContainerUser"
ARG MAVEN_VERSION=4.0.0-rc-4
ARG SHA=f0fdf5078ee10f122081c581a040ee62d27e72ac203c2bb766e8898bd9848fc6a438fd261ce2a63fa0128ea8346a540ce9b753726e7978fd93a4e019c0a84168
ARG BASE_URL=https://www.apache.org/dyn/closer.lua/maven/maven-4/${MAVEN_VERSION}/binaries

RUN Invoke-WebRequest -Uri ${env:BASE_URL}/apache-maven-${env:MAVEN_VERSION}-bin.zip?action=download -OutFile ${env:TEMP}/apache-maven.zip ; `
  if((Get-FileHash -Algorithm SHA512 -Path ${env:TEMP}/apache-maven.zip).Hash.ToLower() -ne ${env:SHA}) { exit 1 } ; `
  Expand-Archive -Path ${env:TEMP}/apache-maven.zip -Destination C:/ProgramData ; `
  Move-Item C:/ProgramData/apache-maven-${env:MAVEN_VERSION} C:/ProgramData/Maven ; `
  New-Item -ItemType Directory -Path C:/ProgramData/Maven/Reference | Out-Null ; `
  Remove-Item ${env:TEMP}/apache-maven.zip

ENV MAVEN_HOME=C:/ProgramData/Maven
ENV MAVEN_CONFIG="$USER_HOME_DIR/.m2"

COPY mvn-entrypoint.ps1 C:/ProgramData/Maven/mvn-entrypoint.ps1
COPY settings-docker.xml C:/ProgramData/Maven/Reference/settings-docker.xml

RUN setx /M PATH $('{0};{1}' -f $env:PATH,'C:\ProgramData\Maven\bin') | Out-Null

USER ContainerUser
ENV JAVA_HOME=${JAVA_HOME}

ENTRYPOINT ["powershell.exe", "-f", "C:/ProgramData/Maven/mvn-entrypoint.ps1"]
CMD ["mvn"]
