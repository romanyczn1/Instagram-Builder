//
//  LolCoordinator.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 25.12.20.
//

import UIKit
import RxSwift

class AppCoordinator: BaseCoordinator<Void> {

    private let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    override func start() -> Observable<CoordinationResult> {
        
        let isUserLoggedIn = true
        if (isUserLoggedIn) {
            let mainScreenCoordinator = MainScreenCoordiantor(window: window)
            coordinate(to: mainScreenCoordinator)
        } else {
            let loginCoordinator = LoginCoordinator(window: window)
            coordinate(to: loginCoordinator)
        }
        return Observable.never()
    }
}
