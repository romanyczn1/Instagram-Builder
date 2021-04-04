//
//  PhotoCell.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 20.03.21.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PhotoCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                imageView.alpha = 0.65
            } else {
                imageView.alpha = 1
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpImageView()
    }
    
    func configure(with viewModel: PhotoCellViewModelType) {
        self.imageView.image = viewModel.image
    }
    
    private func setUpImageView() {
        addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
