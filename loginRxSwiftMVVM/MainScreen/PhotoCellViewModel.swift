//
//  PhotoCellViewModel.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 20.03.21.
//

import UIKit

protocol PhotoCellViewModelType {
    var image: UIImage { get }
}

final class PhotoCellViewModel: PhotoCellViewModelType {
    
    let image: UIImage
    
    init(with image: UIImage) {
        self.image = image
    }
}
