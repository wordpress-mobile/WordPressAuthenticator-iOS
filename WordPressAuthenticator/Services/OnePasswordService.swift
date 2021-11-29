//
//  OnePasswordService.swift
//  WordPressAuthenticator
//
//  Created by Hassaan El-Garem on 11/29/21.
//  Copyright © 2021 Automattic. All rights reserved.
//

import Foundation

/// Protocol that acts as a wrapper around OnePasswordExtension
protocol OnePasswordService {
    
    typealias OnePasswordServiceLoginDictionaryCompletionBlock = ([AnyHashable : Any]?, Error?) -> Void
    
    func findLogin(forURLString URLString: String, for viewController: UIViewController, sender: Any?, completion: @escaping OnePasswordServiceLoginDictionaryCompletionBlock)
    func storeLogin(forURLString URLString: String, loginDetails loginDetailsDictionary: [AnyHashable : Any]?, passwordGenerationOptions: [AnyHashable : Any]?, for viewController: UIViewController, sender: Any?, completion: @escaping OnePasswordServiceLoginDictionaryCompletionBlock)
    func isAppExtensionAvailable() -> Bool
}
