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
    var coordinator: CoordinatorType?
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        keychain["accessToken"] = nil
        do {
            try coordinator?.popUser()
        } catch {
            print("No root VC left to pop!")
        }
    }
    
    override func viewDidLoad() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.title = "Loading user"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        api.getUser() { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.present(error.alert, animated: true, completion: nil)
            case .success(let user):
                self.navigationItem.title = user.username
            }
        }
    }
}
