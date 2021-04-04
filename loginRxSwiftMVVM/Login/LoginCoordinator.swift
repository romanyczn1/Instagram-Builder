//
//  LoginCoordinator.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 29.12.20.
//

import UIKit
import RxSwift

enum LoginResult {
    case success
    case loginError
}

final class LoginCoordinator: BaseCoordinator<LoginResult> {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<LoginResult> {
        
        let viewModel = LoginViewControllerViewModel()
        let loginVC = LoginViewController.initFromStoryboard(name: "Main")
        loginVC.viewModel = viewModel
        let nc = UINavigationController(rootViewController: loginVC)
        
        window.rootViewController = nc
        window.makeKeyAndVisible()
        
        return Observable.never()
    }
}
