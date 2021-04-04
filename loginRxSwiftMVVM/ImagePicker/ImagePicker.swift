//
//  ImagePicker.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 17.03.21.
//

import UIKit
import RxSwift
import BSImagePicker
import Photos

final class ImagePicker: NSObject {

    private weak var presentationController: UIViewController?
    let images: PublishSubject<[UIImage]?>

    public init(presentationController: UIViewController) {
        self.images = PublishSubject<[UIImage]?>()

        super.init()

        self.presentationController = presentationController
        }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            switch type {
            case .camera:
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                imagePicker.allowsEditing = true
                self.presentationController?.present(imagePicker, animated: true, completion: nil)
            case .photoLibrary:
                let pickerController = ImagePickerController()
                self.presentationController?.presentImagePicker(pickerController, select: nil, deselect: nil,
                cancel: { [weak self] (assets) in
                    self?.images.onNext(nil)
                }, finish: { [weak self] (assets) in
                    let images = getImages(from: assets)
                    if images != nil {
                        self?.images.onNext(images)
                    } else {
                        self?.images.onNext(nil)
                    }
                })
            case .savedPhotosAlbum:
                print("will never been executed")
            }
        }
    }
    
    private func getImages(from assets: [PHAsset]) -> [UIImage]? {
        var images: [UIImage] = []
        assets.forEach { (asset) in
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            option.isNetworkAccessAllowed = true
            option.resizeMode = .none
            option.deliveryMode = .opportunistic

            manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize,
                contentMode: .default, options: option,
                resultHandler: {(image, info) in
                    if image != nil {
                        images.append(image!)
                    }
            })
        }
        if images != [] {
            return images
        } else {
            return nil
        }
    }

    public func present() {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.pruneNegativeWidthConstraints()

        self.presentationController?.present(alertController, animated: true)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        images.onNext(nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            images.onNext([pickedImage])
        }

    }
}

//fixes bug with actionSheet alertController constarints error log
extension UIAlertController {
    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}
