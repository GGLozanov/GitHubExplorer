//
//  Coordinator.swift
//  GitHubExplorer
//
//  Created by ts51 on 6.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func navigateToRoot(shouldAnimate: Bool)
    func popRoot(shouldAnimate: Bool) throws
}

enum NoViewError: Error {
    case noRootView
    case noSecondaryViewError(viewControllerType: UIViewController.Type)
}
