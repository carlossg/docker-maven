#!/usr/bin/env bats

SUT_IMAGE=maven
SUT_TAG=${TAG:-eclipse-temurin-17}
SUT_TEST_IMAGE=bats-maven-test

bats_require_minimum_version 1.5.0

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load test_helpers

base_image=eclipse-temurin-17

@test "$SUT_TAG build base $base_image image" {
	if [ "$SUT_TAG" != "$base_image" ]; then
		cd $BATS_TEST_DIRNAME/../$base_image
		base_tag=$(grep -m 1 -o 'maven:[a-z0-9\.-]*' $BATS_TEST_DIRNAME/../$SUT_TAG/Dockerfile)
		docker build --pull -t $base_tag .
	fi
}

@test "$SUT_TAG build image" {
	cd $BATS_TEST_DIRNAME/../$SUT_TAG
	if [ "$SUT_TAG" == "$base_image" ]; then
		arg=--pull
	fi
	docker build ${arg:-} -t $SUT_IMAGE:$SUT_TAG .
}

@test "$SUT_TAG build test image" {
	cd $BATS_TEST_DIRNAME
	local dockerfile="Dockerfile_${SUT_IMAGE}_${SUT_TAG}.tmp"
	sed -e "s/FROM TO_BE_REPLACED/FROM $SUT_IMAGE:$SUT_TAG/" Dockerfile >"${dockerfile}"
	docker build -t $SUT_TEST_IMAGE:$SUT_TAG -f "${dockerfile}" .
	rm -f "${dockerfile}"
}

@test "$SUT_TAG create test container" {
	version="$(grep -m 1 'ARG MAVEN_VERSION' $BATS_TEST_DIRNAME/../$SUT_TAG/Dockerfile | sed -e 's/ARG MAVEN_VERSION=//')"
	run docker run --rm $SUT_IMAGE:$SUT_TAG mvn -version
	assert_success
	assert_line -p "Apache Maven $version "
}

@test "$SUT_TAG create test container (-u 11337:11337)" {
	version="$(grep -m 1 'ARG MAVEN_VERSION' $BATS_TEST_DIRNAME/../$SUT_TAG/Dockerfile | sed -e 's/ARG MAVEN_VERSION=//')"
	run docker run --rm -u 11337:11337 $SUT_IMAGE:$SUT_TAG mvn -version
	assert_success
	assert_line -p "Apache Maven $version "
}

@test "$SUT_TAG settings.xml is setup" {
	run bash -c "docker run --rm $SUT_TEST_IMAGE:$SUT_TAG cat /root/.m2/settings.xml | diff $BATS_TEST_DIRNAME/settings.xml -"
	assert_success
}

@test "$SUT_TAG repository is created" {
	run docker run --rm $SUT_TEST_IMAGE:$SUT_TAG test -f /root/.m2/repository/junit/junit/4.13.1/junit-4.13.1.jar
	assert_success
}

@test "$SUT_TAG run Maven" {
	run docker run --rm $SUT_TEST_IMAGE:$SUT_TAG mvn -B -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn -f /tmp install
	assert_success
}

@test "$SUT_TAG generate sample project" {
	run bash -c "docker run --rm $SUT_TEST_IMAGE:$SUT_TAG mvn -B archetype:generate -DgroupId=bats-testing -DartifactId=bats-test-project -DarchetypeArtifactId=maven-archetype-quickstart"
	assert_success
}

@test "$SUT_TAG generate sample project (-u 11337:11337 -w /tmp --tmpfs /tmp -e HOME=/tmp)" {
	run bash -c "docker run --rm -u 11337:11337 -w /tmp --tmpfs /tmp -e HOME=/tmp $SUT_TEST_IMAGE:$SUT_TAG mvn -B archetype:generate -DgroupId=bats-testing -DartifactId=bats-test-project -DarchetypeArtifactId=maven-archetype-quickstart"
	assert_success
}

# Packages installed tests
# Changes here need to be documented in the table in the README

@test "$SUT_TAG git is installed" {
	if ! (
		[[ "$SUT_TAG" == *"-alpine" ]] ||
			[[ "$SUT_TAG" == "amazoncorretto-"* ]] ||
			[[ "$SUT_TAG" == "azulzulu-"* ]] ||
			[[ "$SUT_TAG" == "ibmjava-"* ]] ||
			[[ "$SUT_TAG" == "libericaopenjdk-"* ]] ||
			[[ "$SUT_TAG" == *"graalvm"* ]]
	); then
		run docker run --rm $SUT_IMAGE:$SUT_TAG git --version
		[ $status -eq 0 ]
	else
		run -127 docker run --rm $SUT_IMAGE:$SUT_TAG git --version
	fi
}

@test "$SUT_TAG curl is installed" {
	if [[ "$SUT_TAG" == amazoncorretto-*-debian ]] ||
		[[ "$SUT_TAG" == azulzulu-*-debian ]]; then
		run -127 docker run --rm $SUT_IMAGE:$SUT_TAG curl --version
	else
		run docker run --rm $SUT_IMAGE:$SUT_TAG curl --version
		[ $status -eq 0 ]
	fi
}

@test "$SUT_TAG tar is installed" {
	run docker run --rm $SUT_IMAGE:$SUT_TAG tar --version
	assert_success
}

@test "$SUT_TAG bash is installed" {
	run docker run --rm $SUT_IMAGE:$SUT_TAG bash --version
	assert_success
}

@test "$SUT_TAG which is installed" {
	if ! (
		[[ "$SUT_TAG" == openjdk-?? ]] ||
			[[ "$SUT_TAG" == *"oracle"* ]]
	); then
		run docker run --rm $SUT_IMAGE:$SUT_TAG which sh
		[ $status -eq 0 ]
	else
		run -127 docker run --rm $SUT_IMAGE:$SUT_TAG which sh
	fi
}

@test "$SUT_TAG gzip is installed" {
	run docker run --rm $SUT_IMAGE:$SUT_TAG gzip --help
	assert_success
}

@test "$SUT_TAG SUREFIRE-1422 procps is installed for ps -p option" {
	run docker run --rm $SUT_IMAGE:$SUT_TAG sh -c "ps --help list | grep -- ' -p'"
	if ! (
		[[ "$SUT_TAG" == "amazoncorretto-"* ]] ||
			[[ "$SUT_TAG" == libericaopenjdk-*-debian ]] ||
			[[ "$SUT_TAG" == openjdk-?? ]] ||
			[[ "$SUT_TAG" == *"graalvm"* ]] ||
			[[ "$SUT_TAG" == azulzulu-*-debian ]]

	); then
		[ $status -eq 0 ]

	else
		[ $status -ne 0 ]
	fi
}

@test "$SUT_TAG gpg is installed" {
	if (
		[[ "$SUT_TAG" == amazoncorretto-? ]] ||
			[[ "$SUT_TAG" == amazoncorretto-?? ]] ||
			[[ "$SUT_TAG" == amazoncorretto-*-al2023 ]] ||
			[[ "$SUT_TAG" == openjdk-?? ]] ||
			[[ "$SUT_TAG" == *"graalvm"* ]]
	); then
		run docker run --rm $SUT_IMAGE:$SUT_TAG gpg --version
		[ $status -eq 0 ]
	else
		run -127 docker run --rm $SUT_IMAGE:$SUT_TAG gpg --version
	fi
}

@test "$SUT_TAG ssh is installed" {
	run docker run --rm $SUT_IMAGE:$SUT_TAG ssh -V
	assert_success
}
