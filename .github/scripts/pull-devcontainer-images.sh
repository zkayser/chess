#!/usr/bin/env bash
set -euo pipefail

pull_with_retry() {
  local image="$1"
  local attempt
  for attempt in 1 2 3 4 5; do
    if docker pull "$image"; then
      return 0
    fi
    echo "Pull of $image failed (attempt $attempt); retrying..."
    sleep $((attempt * 10))
  done
  echo "Failed to pull $image after retries"
  return 1
}

pull_with_retry elixir:1.20.2-otp-29
pull_with_retry postgres:17.6
