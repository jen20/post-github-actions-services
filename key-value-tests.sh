#!/usr/bin/env bash

set -o errexit
set -o pipefail

CONSUL_URL=${CONSUL_URL:-"localhost:8500"}
CONSUL_KEY="test-key"

setKey() {
	consulUrl=$1
	consulKey=$2
	value=$3

	curl --silent \
		--show-error \
		--request PUT \
		--data "${value}" \
		"http://${consulUrl}/v1/kv/${consulKey}" > /dev/null
}

getKey() {
	consulUrl=$1
	consulKey=$2

	curl --silent \
		--show-error \
		--request GET \
		"http://${consulUrl}/v1/kv/${consulKey}" | \
		jq -r '.[0].Value' | \
		base64 -d
}

runTest() {
	current_date=$(date)
	setKey "${CONSUL_URL}" "${CONSUL_KEY}" "${current_date}"

	value=$(getKey "${CONSUL_URL}" "${CONSUL_KEY}")

	if [[ "${value}" == "${current_date}" ]] ; then
		echo "Key was read as set"
	else
		>&2 echo "Key was not read as set"
		exit 1
	fi
}

runTest
sleep 5
runTest
sleep 5
runTest
