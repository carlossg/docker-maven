
# check dependencies
(
    type docker &>/dev/null || ( echo "docker is not available"; exit 1 )
)>&2

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

# Run a command, retrying it when it fails due to rate limiting by Docker Hub or Maven Central
# (HTTP 429 Too Many Requests, or 403 Forbidden from Maven Central).
# Retries $RETRY_RATE_LIMIT_ATTEMPTS times (default 5), waiting $RETRY_RATE_LIMIT_DELAY seconds (default 60) between attempts.
RATE_LIMIT_PATTERN='429 Too Many Requests|toomanyrequests|Status: 429|status code: 429|HTTP Status: 403|status code: 403'
function retry_on_rate_limit {
    local attempts=${RETRY_RATE_LIMIT_ATTEMPTS:-5}
    local delay=${RETRY_RATE_LIMIT_DELAY:-60}
    local i out rc

    for ((i=1; ; i++)); do
        out=$("$@" 2>&1) && rc=0 || rc=$?
        echo "$out"
        if [ "$rc" -eq 0 ] || [ "$i" -ge "$attempts" ] || ! grep -qE "$RATE_LIMIT_PATTERN" <<<"$out"; then
            return $rc
        fi
        echo "Rate limited, retrying in ${delay}s (attempt $i/$attempts)" >&2
        sleep $delay
    done
}
