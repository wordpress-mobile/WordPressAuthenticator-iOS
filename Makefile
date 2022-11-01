# Why is there a `Makefile` when we already have a `Fastfile` in this project?
#
# Because when running Ruby code (i.e. `bundle exec fastlane <lane>`) from
# within an Xcode build phase, Xcode will use a shell different from the user's
# and with system Ruby where Bundler and Fastlane may or may not be available.
# `make` on the other hand, is always available, therefore `make lint` can be
# reliably called from both the user's terminal, Xcode, and CI.
SWIFTLINT=./Pods/SwiftLint/swiftlint

lint:
	$(SWIFTLINT) lint --quiet

format:
	$(SWIFTLINT) lint --autocorrect --quiet
