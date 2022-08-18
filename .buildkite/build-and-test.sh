#!/bin/bash -eu

# We need to use a script as opposed to calling `build_and_test_pod` inline in
# the pipeline via the `command` node because our CI-VM setup doesn't forward
# the environment in that mode.

# See https://github.com/Automattic/bash-cache-buildkite-plugin/issues/16
gem install bundler

build_and_test_pod
