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
    
    @IBOutlet var profileImage: UIImageView!
    
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var followerCountLabel: UILabel!
    
    @IBOutlet var nicknameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var repoCountLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    
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
        
        self.loadUser()
    }
}

extension UserViewController {
    private func loadUser() {
        var getUserEndpoint: GithubEndpoints.UserEndpoint.GetUser
        
        do {
            getUserEndpoint = try GithubEndpoints.UserEndpoint.GetUser()
        } catch {
            if let apiError = error as? GithubAPI.APIError {
                showAlert(fromApiError: apiError)
            } else {
                assert(false, "No handling for new error yet")
            }
            return
        }
        
        api.call(endpoint: getUserEndpoint) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.showAlert(fromApiError: error)
            case .success(let user):
                self.navigationItem.title = user.username
                
                Network.instance.call(request: URLRequest(url: URL(string: user.profileImageURL)!)) { [weak self] (result) in
                    switch result {
                    case .success(let (data, _)):
                        self?.profileImage.image = UIImage(data: data)
                    case .failure(let networkError):
                        self?.present(networkError.alert, animated: true, completion: nil)
                    }
                }
                
                self.followerCountLabel.text = "Follower count: \(user.followerCount)"
                self.followingCountLabel.text = "Following count: \(user.followingCount)"
                
                self.nicknameLabel.text = "Nickname: \(user.nickname ?? "")"
                self.descriptionLabel.text = "Description: \(user.description ?? "")"
                
                self.repoCountLabel.text = "Public repo count: \(user.publicRepoCount)"
                self.emailLabel.text = "E-mail: \(user.email)"
            }
        }
    }
    
    private func showAlert(fromApiError error: GithubAPI.APIError) {
        let alert = error.alert(onAuthenticationError: {
            self.coordinator?.logout()
            self.keychain["accessToken"] = nil
        })
        self.present(alert, animated: true, completion: nil)
    }
}
