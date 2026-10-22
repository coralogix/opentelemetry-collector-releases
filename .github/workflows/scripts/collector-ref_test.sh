#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../../.."
output="$(mktemp)"
trap 'rm -f "$output"' EXIT

check_ref() {
  local binary="$1" ref="$2" expected="$3"
  : > "$output"
  BINARY="$binary" GITHUB_REF="$ref" GITHUB_OUTPUT="$output" \
    bash .github/workflows/scripts/collector-ref.sh
  [[ "$(cat "$output")" == "COLLECTOR_REF=$expected" ]]
}

check_ref opampsupervisor refs/tags/cx-opampsupervisor/v0.163.2 cx-opampsupervisor/v0.163.2
check_ref opampsupervisor refs/tags/v0.163.2 v0.163.0
check_ref builder refs/tags/v0.163.2 v0.163.0
check_ref opampsupervisor refs/tags/nightly-opampsupervisor-nightly main
check_ref builder refs/tags/cx-opampsupervisor/v0.163.2 v0.163.0
echo 'All 5 collector-ref cases passed.'
