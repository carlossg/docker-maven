# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2019

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG zip=amazon-corretto-15-x64-windows-jdk.zip
ARG uri=https://corretto.aws/downloads/latest
ARG hash=fa51ddc8e388c7a34d2e1daf0bc9886aa3f93cb4f17ac9e95b685b2e30d5027b

RUN Invoke-WebRequest -Uri $('{0}/{1}' -f $env:uri,$env:zip) -OutFile C:/$env:zip ; `
    if((Get-FileHash C:/$env:zip -Algorithm SHA256).Hash.ToLower() -ne $env:hash) { exit 1 } ; `
    Expand-Archive -Path C:/$env:zip -Destination C:/ProgramData ; `
    Remove-Item C:/${env:zip}

ENV JAVA_HOME=C:/ProgramData/jdk15.0.1_9

ARG USER_HOME_DIR="C:/Users/ContainerUser"
ARG MAVEN_VERSION=3.6.3
ARG SHA=1c095ed556eda06c6d82fdf52200bc4f3437a1bab42387e801d6f4c56e833fb82b16e8bf0aab95c9708de7bfb55ec27f653a7cf0f491acebc541af234eded94d
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

RUN setx /M PATH $('{0};{1}' -f $env:PATH,'C:\ProgramData\Maven\bin') | Out-Null

USER ContainerUser
ENV JAVA_HOME=${JAVA_HOME}

ENTRYPOINT ["powershell.exe", "-f", "C:/ProgramData/Maven/mvn-entrypoint.ps1"]
CMD ["mvn"]
