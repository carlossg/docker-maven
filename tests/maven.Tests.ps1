$SUT_IMAGE="pester-maven"
$SUT_CONTAINER="pester-maven"
$SUT_TAG="jdk-8"
if(![System.String]::IsNullOrWhiteSpace($env:TAG)) {
  $SUT_TAG=$env:TAG
}
$SUT_TEST_IMAGE="pester-maven-test"
$SUT_TEST_CONTAINER="pester-maven-test"

Import-Module -Force -DisableNameChecking $PSScriptRoot/test_helpers.psm1

Describe "$SUT_TAG build image" {
  BeforeEach {
    Push-Location -StackName 'maven' -Path "$PSScriptRoot/../windows"
  }

  It 'builds image' {
    $exitCode, $stdout, $stderr = Build-Docker -ImageType $SUT_TAG --pull -t $SUT_IMAGE
    $lastExitCode | Should -Be 0
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
    $exitCode, $stdout, $stderr = Build-Docker -t $SUT_TEST_IMAGE
    $exitCode | Should -Be 0
  }

  AfterEach {
    Pop-Location -StackName 'maven'
  }
}

Describe "$SUT_TAG create test container" {
  It 'creates test container' {
    $version = $(Get-Content -Path "$PSScriptRoot/../windows/Dockerfile.windows-$SUT_TAG" | Select-String -Pattern 'ARG MAVEN_VERSION.*' | ForEach-Object { $_ -replace 'ARG MAVEN_VERSION=','' })
    $exitCode, $stdout, $stderr = Run-Program -Cmd "docker.exe" -Params "run --rm $SUT_IMAGE mvn -version"
    $exitCode | Should -Be 0
    $stdout | Should -Match "Apache Maven $version"
  }
}

Describe "$SUT_TAG settings.xml is setup" {
  It 'sets up settings.xml' {
    $exitCode, $stdout, $stderr = Run-Program -Cmd "docker.exe" -Params "run --rm $SUT_TEST_IMAGE Get-Content C:/Users/ContainerAdministrator/.m2/settings.xml"
    $exitCode | Should -Be 0
    "$PSScriptRoot/settings.xml" | Should -FileContentMatchMultiline $stdout
  }
}


Describe "$SUT_TAG repository is created" {
  It 'created repository' {
    $exitCode, $stdout, $stderr = Run-Program -Cmd "docker.exe" -Params "run --rm $SUT_TEST_IMAGE if(Test-Path C:/Users/ContainerAdministrator/.m2/repository/junit/junit/3.8.1/junit-3.8.1.jar) { exit 0 } else {exit 1 }"
    $exitCode | Should -Be 0
  }
}


Describe "$SUT_TAG run Maven" {
  It 'runs maven' {
    $exitCode, $stdout, $stderr = Run-Program -Cmd "docker.exe" -Params "run --rm $SUT_TEST_IMAGE mvn -B -ntp -f $env:TEMP install"
    $exitCode | Should -Be 0
  }
}

Describe "$SUT_TAG generate sample project" {
  It 'generates sample project' {
    $exitCode, $stdout, $stderr = Run-Program -Cmd "docker.exe" -Params "run --rm -it $SUT_TEST_IMAGE mvn -B archetype:generate -DgroupId=pester-testing -DartifactId=pester-test-project -DarchetypeArtifactId=maven-archetype-quickstart"
    $exitCode | Should -Be 0
  }
}
