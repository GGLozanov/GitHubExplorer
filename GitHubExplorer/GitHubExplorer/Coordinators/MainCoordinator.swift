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
    
    // FIXME: Generalise all these methods (important)
    // and avoid repitition
    
    func logout() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func navigateToUser(shouldAnimate: Bool = true) {
        let vc = UserViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: shouldAnimate)
    }
}
