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
    }
    
    // FIXME: Generalise all these methods (important)
    // and avoid repitition
    
    func navigateToRoot() {
        let vc = LoginViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func navigateToUser() {
        let vc = UserViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func popUser() {
        guard let topVC = navigationController.viewControllers.last(where: { (vc) -> Bool in
            !(vc is UserViewController) // pop all controllers until different
        }) else {
            print("No user VC left to pop!")
            return
        }
        
        navigationController.popToViewController(topVC, animated: true)
    }
    
    func popRoot() {
        guard let topVC = navigationController.viewControllers.last(where: { (vc) -> Bool in
          !(vc is LoginViewController)
        }) else {
            print("No root VC left to pop!")
            return
        }
        
        navigationController.popToViewController(topVC, animated: true)
    }
}
