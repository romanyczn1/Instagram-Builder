//
//  UserInfoView.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 13.04.21.
//

import UIKit

final class UserInfoView: UIView {
    
    let userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
}
