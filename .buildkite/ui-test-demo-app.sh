#!/bin/bash -eu

echo "--- :ruby: Setup Ruby tooling"
install_gems

echo "--- :cocoapods: Install Pods"
install_cocoapods

echo "--- :calling: UI Test Demo App"
bundle exec fastlane ui_test_demo_app
