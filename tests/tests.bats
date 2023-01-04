#!/usr/bin/env bats

SUT_IMAGE=maven
SUT_TAG=${TAG:-openjdk-8}
SUT_TEST_IMAGE=bats-maven-test

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load test_helpers

@test "$SUT_TAG build image" {
	cd $BATS_TEST_DIRNAME/../$SUT_TAG
	docker build --pull -t $SUT_IMAGE:$SUT_TAG .
}

@test "$SUT_TAG build test image" {
	cd $BATS_TEST_DIRNAME
	local dockerfile="Dockerfile_${SUT_IMAGE}_${SUT_TAG}.tmp"
	sed -e "s/FROM TO_BE_REPLACED/FROM $SUT_IMAGE:$SUT_TAG/" Dockerfile >"${dockerfile}"
	docker build -t $SUT_TEST_IMAGE:$SUT_TAG -f "${dockerfile}" .
	rm -f "${dockerfile}"
}

@test "$SUT_TAG create test container" {
	version="$(grep 'ARG MAVEN_VERSION' $BATS_TEST_DIRNAME/../$SUT_TAG/Dockerfile | sed -e 's/ARG MAVEN_VERSION=//')"
	run docker run --rm $SUT_IMAGE:$SUT_TAG mvn -version
	assert_success
	assert_line -p "Apache Maven $version "
}

@test "$SUT_TAG create test container (-u 11337:11337)" {
	version="$(grep 'ARG MAVEN_VERSION' $BATS_TEST_DIRNAME/../$SUT_TAG/Dockerfile | sed -e 's/ARG MAVEN_VERSION=//')"
	run docker run --rm -u 11337:11337 $SUT_IMAGE:$SUT_TAG mvn -version
	assert_success
	assert_line -p "Apache Maven $version "
}

@test "$SUT_TAG settings.xml is setup" {
	run bash -c "docker run --rm $SUT_TEST_IMAGE:$SUT_TAG cat /root/.m2/settings.xml | diff $BATS_TEST_DIRNAME/settings.xml -"
	assert_success
}

@test "$SUT_TAG repository is created" {
	run docker run --rm $SUT_TEST_IMAGE:$SUT_TAG test -f /root/.m2/repository/junit/junit/3.8.1/junit-3.8.1.jar
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

# Backwards compatibility tests

@test "$SUT_TAG git is installed" {
	run docker run --rm $SUT_IMAGE:$SUT_TAG git --version
	if ! (
		[[ "$SUT_TAG" == *"-openj9" ]] ||
			[[ "$SUT_TAG" == *"-alpine" ]] ||
			[[ "$SUT_TAG" == *"-slim" ]] ||
			[[ "$SUT_TAG" == "amazoncorretto-"* ]] ||
			[[ "$SUT_TAG" == "azulzulu-"* ]] ||
			[[ "$SUT_TAG" == "ibmjava-"* ]] ||
			[[ "$SUT_TAG" == "libericaopenjdk-"* ]]
	); then
		assert_success
	else
		assert_failure
	fi
}

@test "$SUT_TAG curl is installed" {
	run docker run --rm $SUT_IMAGE:$SUT_TAG curl --version
	assert_success
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
	run docker run --rm $SUT_IMAGE:$SUT_TAG which sh
	if ! (
		[[ "$SUT_TAG" == libericaopenjdk-? ]] ||
			[[ "$SUT_TAG" == libericaopenjdk-?? ]] ||
			[[ "$SUT_TAG" == openjdk-?? ]]
	); then
		assert_success
	else
		assert_failure
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
			[[ "$SUT_TAG" == openjdk-?? ]]
	); then
		assert_success
	else
		assert_failure
	fi
}

@test "$SUT_TAG gpg is installed" {
	run docker run --rm $SUT_IMAGE:$SUT_TAG gpg --version
	if (
		[[ "$SUT_TAG" == "amazoncorretto-"* ]] ||
			[[ "$SUT_TAG" == libericaopenjdk-? ]] ||
			[[ "$SUT_TAG" == libericaopenjdk-?? ]] ||
			[[ "$SUT_TAG" == openjdk-?? ]]
	); then
		assert_success
	else
		assert_failure
	fi
}
