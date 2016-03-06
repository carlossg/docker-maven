
# check dependencies
(
    type docker &>/dev/null || ( echo "docker is not available"; exit 1 )
)>&2

# Assert that $1 is the outputof a command $2
function assert {
    local expected_output=$1
    shift
    local actual_output=$("$@")
    if ! [ "$actual_output" = "$expected_output" ]; then
        echo "expected: \"$expected_output\""
        echo "actual:   \"$actual_output\""
        false
    fi
}

# Retry a command $1 times until it succeeds. Wait $2 seconds between retries.
function retry {
    local attempts=$1
    shift
    local delay=$1
    shift
    local i

    for ((i=0; i < attempts; i++)); do
        run "$@"
        if [ "$status" -eq 0 ]; then
            return 0
        fi
        sleep $delay
    done

    echo "Command \"$@\" failed $attempts times. Status: $status. Output: $output" >&2
    false
}

function cleanup {
    docker kill "$@" &>/dev/null ||:
    docker rm -fv "$@" &>/dev/null ||:
}
