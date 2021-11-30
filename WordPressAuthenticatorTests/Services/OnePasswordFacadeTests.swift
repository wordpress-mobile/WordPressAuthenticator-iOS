//
//  OnePasswordFacadeTests.swift
//  WordPressAuthenticatorTests
//
//  Created by Hassaan El-Garem on 11/29/21.
//  Copyright © 2021 Automattic. All rights reserved.
//

import XCTest
@testable import WordPressAuthenticator

class OnePasswordFacadeTests: XCTestCase {

    func testOnePasswordEnabled() {
        // Given
        WordPressAuthenticator.initialize(
          configuration: WordpressAuthenticatorProvider.wordPressAuthenticatorConfiguration(enableOnePassword: true),
          style: WordpressAuthenticatorProvider.wordPressAuthenticatorStyle(.random),
          unifiedStyle: WordpressAuthenticatorProvider.wordPressAuthenticatorUnifiedStyle(.random)
        )
        let mockOnePasswordService = MockOnePasswordService(onePasswordAvailable: true)
        let onePasswordFacade = OnePasswordFacade(onePasswordService: mockOnePasswordService)

        // When & Then
        XCTAssertTrue(onePasswordFacade.isOnePasswordEnabled)
    }

    func testOnePasswordDisabledIfUnAvailable() {
        // Given
        WordPressAuthenticator.initialize(
          configuration: WordpressAuthenticatorProvider.wordPressAuthenticatorConfiguration(enableOnePassword: true),
          style: WordpressAuthenticatorProvider.wordPressAuthenticatorStyle(.random),
          unifiedStyle: WordpressAuthenticatorProvider.wordPressAuthenticatorUnifiedStyle(.random)
        )
        let mockOnePasswordService = MockOnePasswordService(onePasswordAvailable: false)
        let onePasswordFacade = OnePasswordFacade(onePasswordService: mockOnePasswordService)

        // When & Then
        XCTAssertFalse(onePasswordFacade.isOnePasswordEnabled)
    }

    func testOnePasswordDisabledFromConfiguration() {
        // Given
        WordPressAuthenticator.initialize(
          configuration: WordpressAuthenticatorProvider.wordPressAuthenticatorConfiguration(enableOnePassword: false),
          style: WordpressAuthenticatorProvider.wordPressAuthenticatorStyle(.random),
          unifiedStyle: WordpressAuthenticatorProvider.wordPressAuthenticatorUnifiedStyle(.random)
        )
        let mockOnePasswordService = MockOnePasswordService(onePasswordAvailable: true)
        let onePasswordFacade = OnePasswordFacade(onePasswordService: mockOnePasswordService)

        // When & Then
        XCTAssertFalse(onePasswordFacade.isOnePasswordEnabled)
    }

}
