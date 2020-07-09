//
//  LoginViewController.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 3.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit
import SafariServices
import KeychainAccess

class LoginViewController: UIViewController, Storyboarded {
    @IBOutlet var loginButton: UIButton!
    
    typealias CoordinatorType = MainCoordinator
    weak var coordinator: CoordinatorType?
        // can't be in protocol because it has to be a weak reference
    
    private let api = GithubAPI()
    private let notificationCenter = NotificationCenter.default
    //private let keychain = Keychain(service: "com.example.GitHubExplorer")
    
    @IBAction func login() {
        let urlString = "https://github.com/login/oauth/authorize"
        var urlComponents = URLComponents(url: URL(string: urlString)!, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Secrets.clientId)
        ]
        
        UIApplication.shared.open(urlComponents.url!)
    }
    
    override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        notificationCenter.addObserver(forName: NSNotification.Name.oauthCodeExtracted, object: nil, queue: nil) { [weak self] notification in
            guard let self = self else { return }
            guard let code = notification.userInfo?["code"] as? String else {
                assert(false, "Could not get code from OAuth url")
                self.showAlert(fromApiError: GithubAPI.APIError.authentication)
            }
                        
            self.getUser(withCode: code)
        }
    }
}

extension LoginViewController {
    private func getUser(withCode code: String) {
        api.call(endpoint: GithubEndpoints.AccessTokenEndpoint.GetToken(code: code)) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                let token = response.access_token
                self.keychain["accessToken"] = token
                
                self.api.getUserFromStoredToken(completion: { result in
                    switch result {
                    case .failure(let error):
                        self.showAlert(fromApiError: error)
                    case .success(let user):
                        self.coordinator?.navigateToUser(user: user)
                    }
                })
            case .failure(let error):
                self.showAlert(fromApiError: error)
            }
        }
    }
}


extension LoginViewController: NetworkErrorAlerting{}
