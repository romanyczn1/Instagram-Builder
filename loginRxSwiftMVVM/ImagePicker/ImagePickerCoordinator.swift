//
//  ImagePickerCoordinator.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 17.03.21.
//

import UIKit
import RxSwift
import BSImagePicker

enum ImagePickerCoordinationResult {
    case cancel
    case imageAdded(images: [UIImage])
}

final class ImagePickerCoordinator: BaseCoordinator<ImagePickerCoordinationResult> {
    
    private let rootViewController: UINavigationController
    private var imagePicker: ImagePicker?
    
    init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }
    
    override func start() -> Observable<ImagePickerCoordinationResult> {
        imagePicker = ImagePicker(presentationController: rootViewController)
        imagePicker!.present()
        return imagePicker!.images.asObservable().map({ (images) -> ImagePickerCoordinationResult in
            if images != nil {
                return ImagePickerCoordinationResult.imageAdded(images: images!)
            } else {
                return ImagePickerCoordinationResult.cancel
            }
        }).do(onNext: { _ in
            self.rootViewController.dismiss(animated: true, completion: nil)
        })
    }
}
