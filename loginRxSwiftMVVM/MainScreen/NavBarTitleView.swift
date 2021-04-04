//
//  NavBarTitleView.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 15.01.21.
//

import UIKit
import RxCocoa
import RxSwift

final class NavBarTitleView: UIView {
    
    private let viewModel: NavBarTitleViewViewModelType
    private var isTitleSelected: Bool = false
    private let disposeBag: DisposeBag
        
    private let namelabel: UILabel = {
        let label = UILabel()
        label.font = UIFont (name: "HelveticaNeue-Medium", size: 20)
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "arrow")?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = UITraitCollection.current.userInterfaceStyle == UIUserInterfaceStyle.dark ? .white : .black
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    init(frame: CGRect, viewModel: NavBarTitleViewViewModelType) {
        
        self.disposeBag = DisposeBag()
        self.viewModel = viewModel
        super.init(frame: frame)
                
        setUpBindings()
        setUpViews()
    }
    
    private func setUpBindings() {
        let tapGesture = UITapGestureRecognizer()
        namelabel.addGestureRecognizer(tapGesture)

        let imageTapGesture = UITapGestureRecognizer()
        arrowImage.addGestureRecognizer(imageTapGesture)
        
        let addUserTap = viewModel.addUserTapped.map { () -> UITapGestureRecognizer in
            return UITapGestureRecognizer()
        }
        
        let userSelected = viewModel.userSelected.map { () -> UITapGestureRecognizer in
            return UITapGestureRecognizer()
        }
        
        Observable.of(tapGesture.rx.event.asObservable(), imageTapGesture.rx.event.asObservable(), viewModel.blackViewDidTapped, addUserTap, userSelected).merge().map({ _ -> Bool in
            self.isTitleSelected = !self.isTitleSelected
            return self.isTitleSelected
        })
        .do(onNext: { isSelected in
            if isSelected {
                self.rotateImage(for: .pi)
            } else {
                self.rotateImage(for: -2 * CGFloat.pi)
            }
        })
        .bind(to: viewModel.titleSelected).disposed(by: disposeBag)
        
        viewModel.selectedUser.map({ (user) -> String in
            return user.userName
        }).bind(to: namelabel.rx.text).disposed(by: disposeBag)
    }
    
    private func setUpViews() {
        addSubview(namelabel)
        namelabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
        namelabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        namelabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 5).isActive = true
        namelabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        addSubview(arrowImage)
        arrowImage.leadingAnchor.constraint(equalTo: namelabel.trailingAnchor, constant: 0).isActive = true
        arrowImage.centerYAnchor.constraint(equalTo: namelabel.centerYAnchor).isActive = true
        arrowImage.widthAnchor.constraint(greaterThanOrEqualToConstant: 5).isActive = true
        arrowImage.heightAnchor.constraint(greaterThanOrEqualToConstant: 5).isActive = true
        arrowImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func rotateImage(for rotationAngle: CGFloat) {
        UIView.animate(withDuration: 0.2) { [self] in
            arrowImage.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        arrowImage.tintColor = .oppositeColor
    }
}
