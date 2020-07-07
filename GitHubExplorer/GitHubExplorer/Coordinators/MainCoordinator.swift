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
    
    func navigateToRoot(shouldAnimate: Bool = true) {
        let vc = LoginViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: shouldAnimate)
    }
    
    func navigateToUser(shouldAnimate: Bool = true) {
        let vc = UserViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: shouldAnimate)
    }
    
    func popUser(shouldAnimate: Bool = true) throws {
        guard let topVC = navigationController.viewControllers.last(where: { (vc) -> Bool in
            !(vc is UserViewController) // pop all controllers until different
        }) else {
            throw NoViewControllerError.noSecondaryViewControllerError(type: UserViewController.self)
        }
        
        navigationController.popToViewController(topVC, animated: shouldAnimate)
    }
    
    func popRoot(shouldAnimate: Bool = true) throws {
        guard let topVC = navigationController.viewControllers.last(where: { (vc) -> Bool in
          !(vc is LoginViewController)
        }) else {
            throw NoViewControllerError.noRootViewController
        }
        
        navigationController.popToViewController(topVC, animated: shouldAnimate)
    }
}
