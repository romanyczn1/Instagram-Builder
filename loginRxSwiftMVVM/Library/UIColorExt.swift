//
//  UIColorExt.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 13.03.21.
//

import UIKit

extension UIColor {
    
    static var oppositeColor: UIColor {
        return UITraitCollection.current.userInterfaceStyle == UIUserInterfaceStyle.dark ? .white : .black
    }
    
    static var themeColor: UIColor {
        return UITraitCollection.current.userInterfaceStyle == UIUserInterfaceStyle.dark ? .black : .white
    }
}
