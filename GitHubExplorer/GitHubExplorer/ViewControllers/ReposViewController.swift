//
//  ReposViewController.swift
//  GitHubExplorer
//
//  Created by ts38 on 8.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit
import KeychainAccess

class ReposViewController: UIViewController, UITableViewDelegate, Storyboarded, KeychainOwner {
    
    private let api: GithubAPI = GithubAPI()
    //private let keychain = Keychain(service: "com.example.GitHubExplorer")
    
    @IBOutlet weak var reposTableView: UITableView!
    typealias CoordinatorType = MainCoordinator
    weak var coordinator: CoordinatorType?
    
    var reposURL: URL? = URL(string: "")
    
    private var repos: [Repository] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reposTableView.delegate = self
        reposTableView.dataSource = self
        
        guard let token = self.keychain["accessToken"] else {
            self.showAlert(fromApiError: GithubAPI.APIError.authentication)
            return
        }
        
        let endpoint = GithubEndpoints.UserEndpoint.ListUserRepos(accessToken: token, url: reposURL!)
        api.call(endpoint: endpoint) { [weak self] (result) in
            guard let self = self else { return }
            switch (result){
            case .success(let repos):
                self.repos = repos
                self.reposTableView.reloadData() // necessary because the task is async and initially, the table view is empty
                print(repos.count)
            case .failure(let error):
                self.present(error.alert(), animated: true, completion: nil)
            }
        }
    }
}

extension ReposViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repo = repos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "repoCell", for: indexPath) as! RepoCell
        cell.setRepo(repo: repo)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}


class RepoCell: UITableViewCell {
    
    @IBOutlet weak var repoName: UILabel!
    @IBOutlet weak var repoDescription: UILabel!
    @IBOutlet weak var repoForks: UILabel!
    @IBOutlet weak var repoStars: UILabel!
    
    let uiUtils: UIUtils = UIUtils()
    
    func setRepo(repo: Repository){
        repoName.text = repo.repoName
        
        let intRenderPredicate: (Int?) -> Bool = { value in
            guard let value = value, value > 0 else {
                return false
            }
            return true
        }
        
        uiUtils.renderOptionalLabelText(label: repoDescription, textValue: repo.repoDescription, prefix: nil)
        uiUtils.renderOptionalLabelText(label: repoForks, textValue: repo.forks, prefix: "Forks: ", renderPredicate: intRenderPredicate)
        
        uiUtils.renderOptionalLabelText(label: repoStars, textValue: repo.stars, prefix: "Stars: ", renderPredicate: intRenderPredicate)
    }
    
}

extension ReposViewController: NetworkErrorAlerting {
 
}

