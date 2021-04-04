//
//  MainScreenCoordinator.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 29.12.20.
//

import UIKit
import RxSwift

enum MainScreenCoordinationReuslt {
    case logOut
}

enum UserSettingsEditResult {
    case delete
    case changeUsername(userName: String)
}

final class MainScreenCoordiantor: BaseCoordinator<MainScreenCoordinationReuslt> {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<MainScreenCoordinationReuslt> {
        
        let vc = MainScreenViewController()
        let viewModel = MainScreenViewModel()
        vc.viewModel = viewModel
        let nc = UINavigationController(rootViewController: vc)
        nc.navigationBar.backgroundColor = UITraitCollection.current.userInterfaceStyle == UIUserInterfaceStyle.dark ? .black : .white
        nc.navigationBar.isTranslucent = false
        viewModel.didShowSettingsTapped.flatMapLatest{
            self.showUserSettings(on: nc, with: viewModel.selectedUser)
        }.bind(to: viewModel.userEdited).disposed(by: disposeBag)
        viewModel.didTapAddPhoto.flatMapLatest{
            self.showImagePicker(on: nc).map { (res) -> [UIImage]? in
                switch res {
                case .cancel:
                    return nil
                case .imageAdded(images: let image):
                    return image
                }
            }
        }.bind(to: viewModel.imagesAdded).disposed(by: disposeBag)
        window.rootViewController = nc
        window.makeKeyAndVisible()
        
        return Observable.never()
    }
    
    private func showImagePicker(on rootViewController: UINavigationController) -> Observable<ImagePickerCoordinationResult> {
        let imagePickerCoordinator = ImagePickerCoordinator(rootViewController: rootViewController)
        return coordinate(to: imagePickerCoordinator)
    }
    
    private func showUserSettings(on rootViewController: UINavigationController, with user: Observable<User>) -> Observable<UserSettingsEditResult?> {
        let userSettingsCoordinator = UserSettingsCoordinator(rootViewController: rootViewController, with: user)
        return coordinate(to: userSettingsCoordinator).map { (coordinationResult) -> UserSettingsEditResult? in
            switch coordinationResult {
            case .delete:
                return .delete
            case .cancel:
                return nil
            case .done(userName: let userName):
                return .changeUsername(userName: userName)
            }
        }
    }
}
