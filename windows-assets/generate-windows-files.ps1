[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [String] $MavenVersion,
    [Parameter(Mandatory=$true)]
    [String] $MavenHash
)

$templates = @{
    "FROM_CORE"=@'
# escape=`
FROM @FROM@

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG USER_HOME_DIR="C:/Users/ContainerUser"
ARG MAVEN_VERSION=3.9.0
ARG SHA=564fe44bfa9c7ad3e2703cbbac59d43a11fa39e4e68875d3d1584d0a0b7b77a1352da246b875c4c15d11ceb6b4dd9a0ce7dd7a48695725dce594f34325c9c605
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
'@;

    "FROM_NANO"=@'
# escape=`
ARG JAVA_VERSION=@JAVA_VERSION@
# we use the latest stable if nothing is passed
ARG POWERSHELL_VERSION=

FROM @FROM_REPO@:${JAVA_VERSION}-windowsservercore-@REV@ as openjdk

FROM mcr.microsoft.com/powershell:${POWERSHELL_VERSION}nanoserver-1809

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

USER ContainerAdministrator

ENV JAVA_HOME=@JAVA_HOME@

COPY --from=openjdk $JAVA_HOME $JAVA_HOME

ENV ProgramFiles="C:\Program Files"
ENV WindowsPATH="C:\Windows\system32;C:\Windows"

ARG USER_HOME_DIR="C:/Users/ContainerUser"
ARG MAVEN_VERSION=@MAVEN_VERSION@
ARG SHA=@MAVEN_HASH@
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
ENV JAVA_HOME=${JAVA_HOME}

ENTRYPOINT ["pwsh", "-f", "C:/ProgramData/Maven/mvn-entrypoint.ps1"]
CMD ["mvn"]
'@;

    "URI"=@'
# escape=`
FROM mcr.microsoft.com/windows/servercore:@REV@

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG zip=@zip@
ARG uri=@uri@
ARG hash=@hash@

RUN Invoke-WebRequest -Uri $('{0}/{1}' -f $env:uri,$env:zip) -OutFile C:/$env:zip ; `
    if((Get-FileHash C:/$env:zip -Algorithm SHA256).Hash.ToLower() -ne $env:hash) { exit 1 } ; `
    Expand-Archive -Path C:/$env:zip -Destination C:/ProgramData ; `
    Remove-Item C:/${env:zip}

ARG USER_HOME_DIR="C:/Users/ContainerUser"
ARG MAVEN_VERSION=@MAVEN_VERSION@
ARG SHA=@MAVEN_HASH@
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN Invoke-WebRequest -Uri ${env:BASE_URL}/apache-maven-${env:MAVEN_VERSION}-bin.zip -OutFile ${env:TEMP}/apache-maven.zip ; `
  if((Get-FileHash -Algorithm SHA512 -Path ${env:TEMP}/apache-maven.zip).Hash.ToLower() -ne ${env:SHA}) { exit 1 } ; `
  Expand-Archive -Path ${env:TEMP}/apache-maven.zip -Destination C:/ProgramData ; `
  Move-Item C:/ProgramData/apache-maven-${env:MAVEN_VERSION} C:/ProgramData/Maven ; `
  New-Item -ItemType Directory -Path C:/ProgramData/Maven/Reference | Out-Null ; `
  Remove-Item ${env:TEMP}/apache-maven.zip

ENV MAVEN_HOME C:/ProgramData/Maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

ENV JAVA_HOME=C:/ProgramData/@JAVA_HOME_DIR@

COPY mvn-entrypoint.ps1 C:/ProgramData/Maven/mvn-entrypoint.ps1
COPY settings-docker.xml C:/ProgramData/Maven/Reference/settings-docker.xml

RUN setx /M PATH $('{0};{1}' -f $env:PATH,'C:\ProgramData\Maven\bin') | Out-Null

USER ContainerUser
ENV JAVA_HOME=${JAVA_HOME}

ENTRYPOINT ["powershell.exe", "-f", "C:/ProgramData/Maven/mvn-entrypoint.ps1"]
CMD ["mvn"]
'@;

"URI_NANO"=@'
# escape=`
# we use the latest stable if nothing is passed
ARG POWERSHELL_VERSION=

FROM mcr.microsoft.com/powershell:${POWERSHELL_VERSION}nanoserver-@REV@

SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG zip=@zip@
ARG uri=@uri@
ARG hash=@hash@

USER ContainerAdministrator

ENV ProgramFiles="C:\Program Files"
ENV WindowsPATH="C:\Windows\system32;C:\Windows"

RUN Invoke-WebRequest -Uri $('{0}/{1}' -f $env:uri,$env:zip) -OutFile C:/$env:zip ; `
    if((Get-FileHash C:/$env:zip -Algorithm SHA256).Hash.ToLower() -ne $env:hash) { exit 1 } ; `
    Expand-Archive -Path C:/$env:zip -Destination C:/ProgramData ; `
    Remove-Item C:/${env:zip}

ARG USER_HOME_DIR="C:/Users/ContainerUser"
ARG MAVEN_VERSION=@MAVEN_VERSION@
ARG SHA=@MAVEN_HASH@
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN Invoke-WebRequest -Uri ${env:BASE_URL}/apache-maven-${env:MAVEN_VERSION}-bin.zip -OutFile ${env:TEMP}/apache-maven.zip ; `
  if((Get-FileHash -Algorithm SHA512 -Path ${env:TEMP}/apache-maven.zip).Hash.ToLower() -ne ${env:SHA}) { exit 1 } ; `
  Expand-Archive -Path ${env:TEMP}/apache-maven.zip -Destination C:/ProgramData ; `
  Move-Item C:/ProgramData/apache-maven-${env:MAVEN_VERSION} C:/ProgramData/Maven ; `
  New-Item -ItemType Directory -Path C:/ProgramData/Maven/Reference | Out-Null ; `
  Remove-Item ${env:TEMP}/apache-maven.zip

ENV MAVEN_HOME C:/ProgramData/Maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

ENV JAVA_HOME=C:/ProgramData/@JAVA_HOME_DIR@

ENV PATH="${WindowsPATH};${ProgramFiles}\PowerShell;${JAVA_HOME}\bin;${MAVEN_HOME}\bin"

COPY mvn-entrypoint.ps1 C:/ProgramData/Maven/mvn-entrypoint.ps1
COPY settings-docker.xml C:/ProgramData/Maven/Reference/settings-docker.xml

RUN setx /M PATH $('{0};{1}' -f $env:PATH,'C:\ProgramData\Maven\bin') | Out-Null

USER ContainerUser
ENV JAVA_HOME=${JAVA_HOME}

ENTRYPOINT ["pwsh", "-f", "C:/ProgramData/Maven/mvn-entrypoint.ps1"]
CMD ["mvn"]
'@
}

$workflow_template = @'
name: @tag@

on:
  push:
    paths:
      - "@tag@/**"
      - "tests/**"
      - github-action.ps1
      - "!tests/*.bats"
      - "!tests/*.bash"
      - "!tests/Dockerfile"
      - .github/workflows/_template_windows.yml
  pull_request:
    paths:
      - "@tag@/**"
      - "tests/**"
      - github-action.ps1
      - "!tests/*.bash"
      - "!tests/Dockerfile"
      - .github/workflows/_template_windows.yml

env:
  DOCKER_PUSH: "true"

jobs:
  build:
    uses: ./.github/workflows/_template_windows.yml
    with:
      directory: @tag@
    secrets: inherit
'@


$workflow_directory = Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath ".." -AdditionalChildPath ".github","workflows")

$configurations = Get-Content -Raw $(Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath windows-image-configs.json)) | ConvertFrom-Json -AsHashtable
foreach($configuration in $configurations) {
    Write-Host "$($configuration['tag'])"
    if($templates.ContainsKey($configuration["template"])) {
        $template = $templates[$configuration["template"]]
        $template = $template -creplace "@MAVEN_VERSION@", $MavenVersion
        $template = $template -creplace "@MAVEN_HASH@", $MavenHash

        foreach($param in $configuration.params.Keys) {
            $template = $template -creplace "@$param@", $configuration.params[$param]
        }

        $imageDirectory = Join-Path -Path $PSScriptRoot -ChildPath ".." -AdditionalChildPath $configuration.tag
        if(-not (Test-Path $imageDirectory)) {
            New-Item -ItemType Directory -Path $imageDirectory | Out-Null
        }

        Copy-Item $(Join-Path $PSScriptRoot "mvn-entrypoint.ps1") -Destination $imageDirectory
        Copy-Item $(Join-Path $PSScriptRoot "settings-docker.xml") -Destination $imageDirectory
        Set-Content -Path (Join-Path $imageDirectory "Dockerfile") -Value $template

        $workflow_file = Join-Path $workflow_directory "$($configuration['tag']).yml"
        Set-Content -Path $workflow_file -Value ($workflow_template -creplace "@tag@",$configuration["tag"])
    }
}