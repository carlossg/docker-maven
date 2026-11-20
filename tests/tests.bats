#!/usr/bin/env bats

SUT_IMAGE=maven
SUT_TAG=${TAG:-eclipse-temurin-17-resolute}
SUT_TEST_IMAGE=bats-maven-test

bats_require_minimum_version 1.5.0

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load test_helpers

# dir of the image that a dir copies maven from, empty for source-build images
# ie. FROM maven:3.10.0-eclipse-temurin-17-noble -> eclipse-temurin-17-noble
function maven_upstream_dir {
	local dir=$1
	local base
	base=$(grep -m 1 '^FROM maven:' "$BATS_TEST_DIRNAME/../$dir/Dockerfile" | sed -E -n 's|^FROM maven:[^ ]+-(eclipse-temurin-[^ ]+).*|\1|p')
	[ -n "$base" ] || return 0
	if [ ! -d "$BATS_TEST_DIRNAME/../$base" ]; then
		# unsuffixed tag, ie. eclipse-temurin-17 -> the eclipse-temurin-17-* dir marked as DEFAULT_FOR_VERSION
		base=$(basename "$(dirname "$(grep -l -m 1 '# DEFAULT_FOR_VERSION' "$BATS_TEST_DIRNAME/../$base"-*/Dockerfile | grep -v maven-4 | head -1)")")
	fi
	if [[ "$dir" == *"maven-4" ]]; then
		base="${base}-maven-4"
	fi
	echo "$base"
}

# build the chain of images that a dir copies maven from, ie. eclipse-temurin-17-noble -> eclipse-temurin-17-resolute
function build_maven_upstream {
	local dir=$1
	local base base_tag maven_version arg=
	base=$(maven_upstream_dir "$dir")
	[ -n "$base" ] || return 0
	build_maven_upstream "$base"
	base_tag=$(grep -m 1 '^FROM maven:' "$BATS_TEST_DIRNAME/../$dir/Dockerfile" | sed -E 's/^FROM ([^[:space:]]+)( AS maven_upstream)?$/\1/')
	if [[ "$base_tag" == *'${MAVEN_VERSION}'* ]]; then
		maven_version=$(grep -m 1 '^FROM maven:' "$BATS_TEST_DIRNAME/../$dir/Dockerfile" | sed -E -n 's|^FROM maven:([^ ]+)-eclipse-temurin.*|\1|p')
		base_tag="${base_tag//\$\{MAVEN_VERSION\}/$maven_version}"
	fi
	# only pull for source-build images, the others use the maven image built locally
	if [ -z "$(maven_upstream_dir "$base")" ]; then
		arg=--pull
	fi
	echo "Using base image: $base_tag (from $base)"
	retry_on_rate_limit docker build $arg -t "$base_tag" "$BATS_TEST_DIRNAME/../$base"
}

base_image=$(maven_upstream_dir "$SUT_TAG")

@test "$SUT_TAG build base ${base_image:-$SUT_TAG} image" {
	build_maven_upstream "$SUT_TAG"
}

@test "$SUT_TAG build image" {
	cd $BATS_TEST_DIRNAME/../$SUT_TAG
	if [ -z "$base_image" ]; then
		arg=--pull
	fi
	retry_on_rate_limit docker build ${arg:-} -t $SUT_IMAGE:$SUT_TAG .
}

@test "$SUT_TAG build test image" {
	# test does not work on eclipse-temurin-8-alpine due to ciphers supported
	# will fail to download packages with Received fatal alert: handshake_failure
	if [ "$SUT_TAG" == "eclipse-temurin-8-alpine" ]; then
		return
	fi
	cd $BATS_TEST_DIRNAME
	local dockerfile="Dockerfile_${SUT_IMAGE}_${SUT_TAG}.tmp"
	sed -e "s/FROM TO_BE_REPLACED/FROM $SUT_IMAGE:$SUT_TAG/" Dockerfile >"${dockerfile}"
	retry_on_rate_limit docker build -t $SUT_TEST_IMAGE:$SUT_TAG -f "${dockerfile}" .
	rm -f "${dockerfile}"
}

@test "$SUT_TAG create test container" {
    version="$(grep -m 1 '^FROM maven:' $BATS_TEST_DIRNAME/../$SUT_TAG/Dockerfile | sed -E -n 's|^FROM maven:([^ ]+)-eclipse-temurin.*|\1|p')"
	if [ -z "$version" ]; then
		version="$(grep -m 1 'ARG MAVEN_VERSION=' $BATS_TEST_DIRNAME/../$SUT_TAG/Dockerfile | cut -d'=' -f2)"
	fi
	run docker run --rm $SUT_IMAGE:$SUT_TAG mvn -version
	assert_success
	assert_line -p "Apache Maven $version "
}

# @test "$SUT_TAG create test container (-u 11337:11337)" {
# 	version="$(grep -m 1 '^FROM maven:' $BATS_TEST_DIRNAME/../$SUT_TAG/Dockerfile | sed -E 's|^FROM maven:([^ ]+)-eclipse-temurin.*|\1|')"
# 	run docker run --rm -u 11337:11337 -e HOME=/tmp $SUT_IMAGE:$SUT_TAG mvn -version
# 	assert_success
# 	assert_line -p "Apache Maven $version "
# }

@test "$SUT_TAG settings.xml is setup" {
	if [ "$SUT_TAG" == "eclipse-temurin-8-alpine" ]; then
		return
	fi
	run bash -c "docker run --rm $SUT_TEST_IMAGE:$SUT_TAG cat /root/.m2/settings.xml | diff $BATS_TEST_DIRNAME/settings.xml -"
	assert_success
}

@test "$SUT_TAG repository is created" {
	if [ "$SUT_TAG" == "eclipse-temurin-8-alpine" ]; then
		return
	fi
	run docker run --rm $SUT_TEST_IMAGE:$SUT_TAG test -f /root/.m2/repository/org/junit/junit-bom/5.7.2/junit-bom-5.7.2.pom
	assert_success
}

@test "$SUT_TAG run Maven" {
	if [ "$SUT_TAG" == "eclipse-temurin-8-alpine" ]; then
		return
	fi
	run retry_on_rate_limit docker run --rm $SUT_TEST_IMAGE:$SUT_TAG mvn -B -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn -f /tmp install
	assert_success
}

@test "$SUT_TAG generate sample project" {
	if [ "$SUT_TAG" == "eclipse-temurin-8-alpine" ]; then
		return
	fi
	run retry_on_rate_limit bash -c "docker run --rm $SUT_TEST_IMAGE:$SUT_TAG mvn -B archetype:generate -DgroupId=bats-testing -DartifactId=bats-test-project -DarchetypeArtifactId=maven-archetype-quickstart"
	assert_success
}

# @test "$SUT_TAG generate sample project (-u 11337:11337 -w /tmp --tmpfs /tmp -e HOME=/tmp)" {
# 	run bash -c "docker run --rm -u 11337:11337 -w /tmp --tmpfs /tmp -e HOME=/tmp $SUT_TEST_IMAGE:$SUT_TAG mvn -B archetype:generate -DgroupId=bats-testing -DartifactId=bats-test-project -DarchetypeArtifactId=maven-archetype-quickstart"
# 	assert_success
# }

# Packages installed tests
# Changes here need to be documented in the table in the README

@test "$SUT_TAG git is installed" {
	if ! {
		[[ "$SUT_TAG" == *"-alpine"* ]] ||
			[[ "$SUT_TAG" == "amazoncorretto-"* ]] ||
			[[ "$SUT_TAG" == "azulzulu-"* ]] ||
			[[ "$SUT_TAG" == "ibmjava-"* ]] ||
			[[ "$SUT_TAG" == "libericaopenjdk-"* ]] ||
			[[ "$SUT_TAG" == *"graalvm"* ]]
	}; then
		run docker run --rm $SUT_IMAGE:$SUT_TAG git --version
		[ $status -eq 0 ]
	else
		run -127 docker run --rm $SUT_IMAGE:$SUT_TAG git --version
	fi
}

@test "$SUT_TAG curl is installed" {
	if [[ "$SUT_TAG" == amazoncorretto-*-debian* ]] ||
		[[ "$SUT_TAG" == amazoncorretto-*-alpine ]] ||
		[[ "$SUT_TAG" == azulzulu-*-debian ]]; then
		run -127 docker run --rm $SUT_IMAGE:$SUT_TAG curl --version
	else
		run docker run --rm $SUT_IMAGE:$SUT_TAG curl --version
		[ $status -eq 0 ]
	fi
}

@test "$SUT_TAG tar is installed" {
	if {
		[[ "$SUT_TAG" != amazoncorretto-* ]] ||
			{
				[[ "$SUT_TAG" == amazoncorretto-* ]] &&
					[[ "$SUT_TAG" != amazoncorretto-??-maven-4 ]] &&
					{
						[[ "$SUT_TAG" == amazoncorretto-8* ]] ||
							[[ "$SUT_TAG" == amazoncorretto-11* ]] ||
							[[ "$SUT_TAG" == amazoncorretto-17* ]] ||
							[[ "$SUT_TAG" == amazoncorretto-21* ]] ||
							[[ "$SUT_TAG" == amazoncorretto-*-alpine ]] ||
							[[ "$SUT_TAG" == amazoncorretto-*-debian* ]]
					}
			}
	}; then
		run docker run --rm $SUT_IMAGE:$SUT_TAG tar --version
		assert_success
	else
		run -127 docker run --rm $SUT_IMAGE:$SUT_TAG tar --version
	fi
}

@test "$SUT_TAG bash is installed" {
	run docker run --rm $SUT_IMAGE:$SUT_TAG bash --version
	assert_success
}

@test "$SUT_TAG which is installed" {
	if ! {
		[[ "$SUT_TAG" == *"oracle"* ]] ||
			[[ "$SUT_TAG" == amazoncorretto-??-maven-4 ]] ||
			{
				[[ "$SUT_TAG" == amazoncorretto-* ]] &&
					[[ "$SUT_TAG" != amazoncorretto-8* ]] &&
					[[ "$SUT_TAG" != amazoncorretto-11* ]] &&
					[[ "$SUT_TAG" != amazoncorretto-17* ]] &&
					[[ "$SUT_TAG" != amazoncorretto-21* ]] &&
					[[ "$SUT_TAG" != amazoncorretto-*-alpine ]] &&
					[[ "$SUT_TAG" != amazoncorretto-*-debian* ]]
			}
	}; then
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
	if ! {
		[[ "$SUT_TAG" == "amazoncorretto-"* ]] ||
			[[ "$SUT_TAG" == libericaopenjdk-*-debian* ]] ||
			[[ "$SUT_TAG" == *"graalvm"* ]] ||
			[[ "$SUT_TAG" == azulzulu-*-debian* ]]

	}; then
		[ $status -eq 0 ]

	else
		[ $status -ne 0 ]
	fi
}

@test "$SUT_TAG gpg is installed" {
	if [[ "$SUT_TAG" == amazoncorretto-? ]] ||
		[[ "$SUT_TAG" == amazoncorretto-?? ]] ||
		[[ "$SUT_TAG" == amazoncorretto-??-maven-4 ]] ||
		[[ "$SUT_TAG" == eclipse-temurin-8-* ]] ||
		[[ "$SUT_TAG" == eclipse-temurin-11-* ]] ||
		[[ "$SUT_TAG" == eclipse-temurin-17-* ]] ||
		[[ "$SUT_TAG" == eclipse-temurin-21-* ]] ||
		[[ "$SUT_TAG" == graalvm-community-17* ]] ||
		[[ "$SUT_TAG" == graalvm-community-21* ]]; then
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
