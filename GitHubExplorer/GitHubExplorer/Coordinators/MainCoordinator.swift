//
//  MainCoordinator.swift
//  GitHubExplorer
//
//  Created by ts51 on 6.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = [Coordinator]()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
        
        if navigationController.viewControllers.count == 0 {
            let vc = LoginViewController.instantiate()
            vc.coordinator = self
            navigationController.viewControllers = [vc]
        }
    }
    
    func logout() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func navigateToUser(shouldAnimate: Bool = true) {
        let vc = UserViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: shouldAnimate)
    }
    
    func showRepos(userURL: URL) {
        let vc = ReposViewController.instantiate()
        vc.coordinator = self
        vc.reposURL = userURL
        navigationController.pushViewController(vc, animated: true)
    }
    
}
