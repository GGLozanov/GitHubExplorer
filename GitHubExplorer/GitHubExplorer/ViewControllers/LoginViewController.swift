//
//  LoginViewController.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 3.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit
import SafariServices

class LoginViewController: UIViewController {
    @IBOutlet var loginButton: UIButton!
    
    private let api = GithubAPI()
    private let notificationCenter = NotificationCenter.default
    
    @IBAction func login() {
        let urlString = "https://github.com/login/oauth/authorize"
        var urlComponents = URLComponents(url: URL(string: urlString)!, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: "3fed7e1efcc8b36c1336")
        ]
        
        
        UIApplication.shared.openURL(urlComponents.url!)
    }
    
    override func viewDidLoad() {
        notificationCenter.addObserver(forName: NSNotification.Name.oauthCodeExtracted, object: nil, queue: nil) { [weak self] notification in
            guard let code = notification.userInfo?["code"] as? String else {
                assert(false, "Could not get code from OAuth url")
                
                let alert = UIAlertController(title: "Internal error. Scream at your developer.", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
}
