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
    
    var user: User
    
    init?(coder: NSCoder, user: User) {
        self.user = user
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // some button action to go to the reposViewController

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
    
    @IBAction func repositoriesTapped() {
        guard let url = URL(string: user.reposURL) else {
            self.present(Network.NetworkError.noData.alert, animated: true, completion: nil)
            return
        }
        
        coordinator?.showRepos(userURL: url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.title = user.username
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.loadUserProfileImage()
        self.loadUserUI()
    }
}

extension UserViewController {
    enum UserViewControllerError: Error {
        case noUserError
    }
}

extension UserViewController {
    private func loadUserUI() {
        func renderOptionalLabelText(label: UILabel, text: String?, prefix: String) {
            if let text = text {
                label.text = prefix + text
            } else {
                label.isHidden = true
            }
        }
        
        self.followerCountLabel.text = "Follower count: \(user.followerCount)"
        self.followingCountLabel.text = "Following count: \(user.followingCount)"

        renderOptionalLabelText(label: self.nicknameLabel, text: self.user.nickname, prefix: "Username: ")
        
        renderOptionalLabelText(label: self.descriptionLabel, text: self.user.description, prefix: "Description: ")
        
        renderOptionalLabelText(label: self.emailLabel, text: self.user.email, prefix: "Email: ")
        
        self.repoCountLabel.text = "Public repo count: \(user.publicRepoCount)"
    }
    
    private func loadUserProfileImage() {
        if let imageURLString = user.profileImageURL, let imageURL = URL(string: imageURLString){
            Network.instance.call(request: URLRequest(url: imageURL)) { [weak self] (result) in
                switch result {
                case .success(let (data, _)):
                    self?.profileImage.image = UIImage(data: data)
                case .failure(let networkError):
                    self?.present(networkError.alert, animated: true, completion: nil)
                }
            }
        }
    }
}

extension UserViewController : NetworkErrorAlerting{
    func showAlert(fromApiError error: GithubAPI.APIError) {
        let alert = error.alert(onAuthenticationError: {
            self.coordinator?.logout()
            self.keychain["accessToken"] = nil
        })
        self.present(alert, animated: true, completion: nil)
    }
}
