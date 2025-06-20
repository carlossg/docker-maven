# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2019

LABEL org.opencontainers.image.title="Apache Maven"
LABEL org.opencontainers.image.source=https://github.com/carlossg/docker-maven
LABEL org.opencontainers.image.url=https://github.com/carlossg/docker-maven
LABEL org.opencontainers.image.description="Apache Maven is a software project management and comprehension tool. Based on the concept of a project object model (POM), Maven can manage a project's build, reporting and documentation from a central piece of information."

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG zip=amazon-corretto-17-x64-windows-jdk.zip
ARG uri=https://corretto.aws/downloads/latest
ARG hash=dcc796f275bd89ed5fc7a7152e2b960ed250dc1b8b4b38a4684f41b97c0b6981

RUN Invoke-WebRequest -Uri $('{0}/{1}' -f $env:uri,$env:zip) -OutFile C:/$env:zip ; `
  if((Get-FileHash C:/$env:zip -Algorithm SHA256).Hash.ToLower() -ne $env:hash) { `
  Write-Error "Checksum for $($env:zip) does not match expected value. Expected: $($env:hash) Actual: $((Get-FileHash C:/$env:zip -Algorithm SHA256).Hash.ToLower())" ; `
  exit 1 } ; `
  Expand-Archive -Path C:/$env:zip -Destination C:/ProgramData ; `
  Remove-Item C:/${env:zip}

ENV JAVA_HOME=C:/ProgramData/jdk17.0.14_7

ARG USER_HOME_DIR="C:/Users/ContainerUser"
ARG MAVEN_VERSION=4.0.0-rc-2
ARG SHA=333ff30559cb72ecc4ce40308814cdafc9d85d7311305ca66cb40e560033c939be12e6b55ad1c706de67cbf106640e8fc2f4c3a6d33a3fa4cad783d25a01bac0
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
