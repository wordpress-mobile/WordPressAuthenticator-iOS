#!/bin/bash -eu

echo "--- :ruby: Setup Ruby tooling"
install_gems

echo "--- :cocoapods: Install Pods"
install_cocoapods

echo "--- :calling: UI Test Demo App"
set +e
bundle exec fastlane ui_test_demo_app
TESTS_EXIT_STATUS=$?
set -e

if [[ "$TESTS_EXIT_STATUS" -ne 0 ]]; then
  # Keep the (otherwise collapsed) current "Testing" section open in Buildkite logs on error. See https://buildkite.com/do s/pipelines/managing-log-output#collapsing-output
  echo "^^^ +++"
  echo "UI Tests failed!"

  echo "--- :camera_with_flash: Extracting Screenshots"
  brew install chargepoint/xcparse/xcparse
  xcparse screenshots fastlane/test_output/UITests.xcresult .build/screenshots/
fi

echo "--- 📦 Zipping test results"
cd fastlane/test_output/ && zip -rq UITests.xcresult.zip UITests.xcresult && cd -

exit $TESTS_EXIT_STATUS
