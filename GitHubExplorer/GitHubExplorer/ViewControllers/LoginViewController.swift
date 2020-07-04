//
//  LoginViewController.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 3.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {
    @IBOutlet var webViewContainer: UIView!
    @IBOutlet var loginButton: UIButton!
    
    private let webView = WKWebView()
    //private let api = GithubAPI()
    
    @IBAction func login() {
        let urlString = "https://github.com/login/oauth/authorize"
        var urlComponents = URLComponents(url: URL(string: urlString)!, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: "3fed7e1efcc8b36c1336"),
//            URLQueryItem(name: "redirect_uri", value: "gitexp://login_callback")
        ]
        
        
        webView.load(URLRequest(url: urlComponents.url!))
    }
    
    override func viewDidLoad() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 8),
        ])
    }
}
