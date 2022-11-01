SWIFTLINT=./Pods/SwiftLint/swiftlint

lint:
	$(SWIFTLINT) lint --quiet

format:
	$(SWIFTLINT) lint --autocorrect --quiet
