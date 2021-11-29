//
//  MockOnePasswordService.swift
//  WordPressAuthenticatorTests
//
//  Created by Hassaan El-Garem on 11/29/21.
//  Copyright © 2021 Automattic. All rights reserved.
//

import Foundation
@testable import WordPressAuthenticator


class MockOnePasswordService: OnePasswordService {
    
    // MARK: - Private Properties
    //
    var onePasswordAvailable: Bool
    
    // MARK: - Initializer
    //
    init(onePasswordAvailable: Bool) {
        self.onePasswordAvailable = onePasswordAvailable
    }
    
    // MARK: - OnePasswordService
    //
    func findLogin(forURLString URLString: String, for viewController: UIViewController, sender: Any?, completion: @escaping OnePasswordServiceLoginDictionaryCompletionBlock) {
        // Do nothing
    }
    
    func storeLogin(forURLString URLString: String, loginDetails loginDetailsDictionary: [AnyHashable : Any]?, passwordGenerationOptions: [AnyHashable : Any]?, for viewController: UIViewController, sender: Any?, completion: @escaping OnePasswordServiceLoginDictionaryCompletionBlock) {
        // Do nothing
    }
    
    func isAppExtensionAvailable() -> Bool {
        return onePasswordAvailable
    }
}
