//
//  AlertProtocol.swift
//  GitHubExplorer
//
//  Created by ts38 on 8.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit
import KeychainAccess

protocol NetworkErrorAlerting{
    func showAlert(fromApiError apiError: GithubAPI.APIError)
}

protocol KeychainOwner {
    var keychain: Keychain { get }
}

extension UIViewController: KeychainOwner{
    
    var keychain: Keychain {
        Keychain(service: "com.example.GitHubExplorer")
    }
}

extension NetworkErrorAlerting where Self: UIViewController {
    func showAlert(fromApiError apiError: GithubAPI.APIError){
        self.present(apiError.alert(onAuthenticationError: {
            self.keychain["accessToken"] = nil
        }), animated: true, completion: nil)
    }
}

