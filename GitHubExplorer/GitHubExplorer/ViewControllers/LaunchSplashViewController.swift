//
//  LaunchSplashViewController.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 14.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit

class LaunchSplashViewController: UIViewController, KeychainOwner {
    var coordinator: MainCoordinator! // main coordinator init here
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let hasLoggedUser = keychain["accessToken"] != nil
        
        let userNavigationVC = UINavigationController()
        userNavigationVC.modalPresentationStyle = .fullScreen
        
        self.coordinator = MainCoordinator(navigationController: userNavigationVC)
        
        guard let coordinator = self.coordinator else {
            fatalError("No coordinator")
        }
        
        if(hasLoggedUser) {
            GithubAPI().getUser(accessToken: keychain["accessToken"]!) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .failure:
                    break
                case .success(let user):
                    coordinator.navigateToUser(user: user, shouldAnimate: false)
                }
            }
        }
        
        self.present(userNavigationVC, animated: false, completion: nil)
    }
}
