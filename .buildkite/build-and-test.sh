#!/bin/bash -eu

# We need to use a script as opposed to calling `build_and_test_pod` inline in
# the pipeline via the `command` node because our CI-VM setup doesn't forward
# the environment in that mode.

build_and_test_pod
