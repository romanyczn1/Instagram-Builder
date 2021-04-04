//
//  UserSettingsCoordintaor.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 11.03.21.
//

import UIKit
import RxSwift

enum UserSettingsCoordinatorResult {
    case delete
    case cancel
    case done(userName: String)
}

final class UserSettingsCoordinator: BaseCoordinator<UserSettingsCoordinatorResult> {
    
    private let rootViewController: UINavigationController
    private let user: Observable<User>
    
    init(rootViewController: UINavigationController, with user: Observable<User>) {
        self.rootViewController = rootViewController
        self.user = user
    }
    
    override func start() -> Observable<UserSettingsCoordinatorResult> {
        let vc = UserSettingsViewController()
        let viewModel = UserSettingsViewModel(user: user)
        vc.viewModel = viewModel
        rootViewController.pushViewController(vc, animated: true)
        let cancel = viewModel.didTapCancelButton.map { UserSettingsCoordinatorResult.cancel }
        let delete = viewModel.didTapDeleteButton.map { UserSettingsCoordinatorResult.delete }
        let done = viewModel.didTapDoneButton.map{ UserSettingsCoordinatorResult.done(userName: $0)}
        return Observable.merge(cancel, delete, done)
                .do(onNext: { [weak self] _ in self?.rootViewController.popViewController(animated: true)
            })
    }
}

