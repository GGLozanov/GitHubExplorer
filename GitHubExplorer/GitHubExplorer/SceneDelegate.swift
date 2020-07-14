//
//  SceneDelegate.swift
//  GitHubExplorer
//
//  Created by ts51 on 1.07.20.
//  Copyright © 2020 example. All rights reserved.
//

import UIKit
import KeychainAccess

class SceneDelegate: UIResponder, UIWindowSceneDelegate, KeychainOwner {

    var window: UIWindow?
    var coordinator: MainCoordinator? // main coordinator init here
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let ghOauthUrl = URLContexts.first(where: { $0.url.scheme == "ghexplorer" })?.url else { return }
         GithubAPI().extractAndAnnounceAccessCode(from: ghOauthUrl)
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.noCodeInOAuthRedirect, object: nil, queue: nil) { [weak self] _ in
            let alert = UIAlertController(title: "Could not get code from OAuth url", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
