#!/bin/bash -eu

echo "--- :ruby: Setup Ruby tooling"
install_gems

echo "--- :cocoapods: Install Pods"
install_cocoapods

echo "--- :calling: Build Demo App"
bundle exec fastlane build_demo_app
