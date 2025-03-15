BeforeAll {
  $SUT_IMAGE="maven"
  $SUT_TAG="amazoncorretto-17-windowsservercore"
  if(![System.String]::IsNullOrWhiteSpace($env:TAG)) {
    $SUT_TAG=$env:TAG
  }
  $SUT_TEST_IMAGE="pester-maven-test"
}

Import-Module -Force -DisableNameChecking $PSScriptRoot/test_helpers.psm1

Describe "$SUT_TAG build image" {
  BeforeEach {
    Push-Location -StackName 'maven' -Path "$PSScriptRoot/../$SUT_TAG"
  }

  It 'builds image' {
    $exitCode, $stdout, $stderr = Build-Docker --pull -t ${SUT_IMAGE}:${SUT_TAG}
    $exitCode | Should -Be 0
  }

  AfterEach {
    Pop-Location -StackName 'maven'
  }
}

Describe "$SUT_TAG build test image" {
  BeforeEach {
    Push-Location -StackName 'maven' -Path "$PSScriptRoot"
  }

  It 'builds image' {
    ((Get-Content -path Dockerfile.windows -Raw) -replace 'FROM TO_BE_REPLACED',"FROM ${SUT_IMAGE}:${SUT_TAG}") | Set-Content -Path Dockerfile.windows
    $exitCode, $stdout, $stderr = Build-Docker -f Dockerfile.windows -t ${SUT_TEST_IMAGE}:${SUT_TAG}
    $exitCode | Should -Be 0
  }

  AfterEach {
    Pop-Location -StackName 'maven'
  }
}

Describe "$SUT_TAG create test container" {
  It 'creates test container' {
    $version = $(Get-Content -Path "$PSScriptRoot/../$SUT_TAG/Dockerfile" | Select-String -Pattern 'ARG MAVEN_VERSION.*' | ForEach-Object { $_ -replace 'ARG MAVEN_VERSION=','' })
    $exitCode, $stdout, $stderr = Run-Program -Cmd "docker.exe" -Params "run --rm ${SUT_IMAGE}:${SUT_TAG} mvn -version"
    $exitCode | Should -Be 0
    $stdout | Should -Match "Apache Maven $version"
  }
  It 'runs as non admin user' {
    $version = $(Get-Content -Path "$PSScriptRoot/../$SUT_TAG/Dockerfile" | Select-String -Pattern 'ARG MAVEN_VERSION.*' | ForEach-Object { $_ -replace 'ARG MAVEN_VERSION=','' })
    $exitCode, $stdout, $stderr = Run-Program -Cmd "docker.exe" -Params "run --rm ${SUT_IMAGE}:${SUT_TAG} echo `$env:USERNAME"
    $exitCode | Should -Be 0
    $stdout | Should -Match "ContainerUser"
  }
}

Describe "$SUT_TAG settings.xml is setup" {
  It 'sets up settings.xml' {
    $exitCode, $stdout, $stderr = Run-Program -Cmd "docker.exe" -Params "run --rm ${SUT_TEST_IMAGE}:${SUT_TAG} Get-Content C:/Users/ContainerUser/.m2/settings.xml"
    $exitCode | Should -Be 0
    "$PSScriptRoot/settings.xml" | Should -FileContentMatchMultiline $stdout
  }
}


Describe "$SUT_TAG repository is created" {
  It 'created repository' {
    $exitCode, $stdout, $stderr = Run-Program -Cmd "docker.exe" -Params "run --rm ${SUT_TEST_IMAGE}:${SUT_TAG} if(Test-Path C:/Users/ContainerUser/.m2/repository/org/junit/junit-bom/5.7.2/junit-bom-5.7.2.pom) { exit 0 } else {exit 1 }"
    $exitCode | Should -Be 0
  }
}


Describe "$SUT_TAG run Maven" {
  It 'runs maven' {
    $exitCode, $stdout, $stderr = Run-Program -Cmd "docker.exe" -Params "run --rm ${SUT_TEST_IMAGE}:${SUT_TAG} mvn -B -ntp -f C:/Temp install"
    $exitCode | Should -Be 0
  }
}

Describe "$SUT_TAG run Surefire" {
  It 'runs maven' {
    # -Dplugin='org.apache.maven.plugins:maven-surefire-plugin' works in windowsservercore but not in nanoserver
    $exitCode, $stdout, $stderr = Run-Program -Cmd "docker.exe" -Params "run --rm ${SUT_TEST_IMAGE}:${SUT_TAG} mvn -B -ntp -f C:/Temp -Dplugin=surefire help:describe"
    $exitCode | Should -Be 0
    $stdout | Should -Match "Version: 2.19.1"
  }
}

Describe "$SUT_TAG generate sample project" {
  It 'generates sample project' {
    $exitCode, $stdout, $stderr = Run-Program -Cmd "docker.exe" -Params "run --rm ${SUT_TEST_IMAGE}:${SUT_TAG} mvn -B archetype:generate -DgroupId=pester-testing -DartifactId=pester-test-project -DarchetypeArtifactId=maven-archetype-quickstart"
    $exitCode | Should -Be 0
  }
}
