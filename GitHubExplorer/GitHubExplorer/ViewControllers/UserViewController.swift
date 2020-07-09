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
    //private let keychain = Keychain(service: "com.example.GitHubExplorer")
    
    typealias CoordinatorType = MainCoordinator
    weak var coordinator: CoordinatorType?
    
    //var user: User = User()
    
    // some button action to go to the reposViewController
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        guard let coordinator = coordinator else {
            fatalError("No coordinator")
        }
        
        // FIXME: Invalidate before resetting Issue #5
        
        do {
            let invalidateAuthenticationsEndpoint = try GithubEndpoints.ApplicationsEndpoint.InvalidateAuthentications()
            api.call(endpoint: invalidateAuthenticationsEndpoint) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success:
                    coordinator.logout()
                    self.keychain["accessToken"] = nil
                case .failure(let error):
                    self.coordinator?.logout()
                    self.showAlert(fromApiError: error)
                }
            }
        } catch {
            if let apiError = error as? GithubAPI.APIError {
                showAlert(fromApiError: apiError)
            } else {
                //FIXME: Show alert for some other error
                // No other errors are thrown at the moment
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.title = "Loading user"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        do {
            let getUserEndpoint = try GithubEndpoints.UserEndpoint.GetUser()
            api.call(endpoint: getUserEndpoint) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.coordinator?.logout()
                    self.showAlert(fromApiError: error)
                case .success(let user):
                    self.navigationItem.title = user.username
                    //self.user = user
                    let url = URL(string: user.reposURL)
                    self.coordinator?.showRepos(userURL: url!) // this should be handled in a button
                }
            }
        } catch {
            if let apiError = error as? GithubAPI.APIError {
                showAlert(fromApiError: apiError)
            } else {
                //FIXME: Show alert for some other error
                // No other errors are thrown at the moment
            }
        }
    }
    
}

extension UserViewController : Alert{
}
