//
//  UserViewController.swift
//  GitHubExplorer
//
//  Created by Dilchovski on 6.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit
import KeychainAccess

class UserViewController: UIViewController, Storyboarded {
    private let api: GithubAPI = GithubAPI()
    private let keychain = Keychain(service: "com.example.GitHubExplorer")
  
    typealias CoordinatorType = MainCoordinator
    weak var coordinator: CoordinatorType?
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        guard let coordinator = coordinator else {
            fatalError("No coordinator")
        }
        
        // FIXME: Invalidate before resetting Issue #5
        api.invalidateAccessToken { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success:
                coordinator.logout()
                self.keychain["accessToken"] = nil
            case .failure(let error):
                self.present(error.alert(), animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.title = "Loading user"
        navigationController?.navigationBar.prefersLargeTitles = true
            
        api.getUser() { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                let alert = error.alert(onAuthenticationError: {
                    self.coordinator?.logout()
                    self.keychain["accessToken"] = nil
                })
                self.present(alert, animated: true, completion: nil)
            case .success(let user):
                self.navigationItem.title = user.username
            }
        }
    }
}
