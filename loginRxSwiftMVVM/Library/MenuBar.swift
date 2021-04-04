//
//  MenuBar.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 13.01.21.
//

import UIKit
import RxCocoa
import RxSwift

final class MenuBar: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let disposeBag: DisposeBag
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.register(MenuBarCell.self, forCellWithReuseIdentifier: MenuBarCell.reuseIdentidier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private let slider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .oppositeColor
        return view
    }()
    
    private let dividingStrip: UIView = {
        let view = UIView()
        view.backgroundColor = .gray	
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var sliderLeadingConstraint: NSLayoutConstraint!
    var viewModel: MenuBarViewModelType
    
    init(frame: CGRect, viewModel: MenuBarViewModelType) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        super.init(frame: frame)
        
        setUpViews()
        setUpBindings()
    }
    
    private func setUpBindings() {
        collectionView.rx.itemSelected.bind(to: viewModel.cellSelected).disposed(by: disposeBag)
    }
    
    private func setUpViews() {
        backgroundColor = .themeColor
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 45)
        ])
        let item = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: item, animated: false, scrollPosition: .bottom)
        addSubview(slider)
        sliderLeadingConstraint = slider.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            sliderLeadingConstraint,
            slider.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1/2),
            slider.heightAnchor.constraint(equalToConstant: 2)
        ])
        addSubview(dividingStrip)
        NSLayoutConstraint.activate([
            dividingStrip.topAnchor.constraint(equalTo: slider.bottomAnchor),
            dividingStrip.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dividingStrip.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            dividingStrip.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getNumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuBarCell.reuseIdentidier, for: indexPath) as! MenuBarCell
        let cellViewModel = viewModel.viewModelForCell(at: indexPath)
        cell.configure(with: cellViewModel)
        cell.backgroundColor = .systemBackground
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width/2, height: 45)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        backgroundColor = .themeColor
        slider.backgroundColor = .oppositeColor
    }
}

protocol MenuBarViewModelType: class {
    var cellSelected: AnyObserver<IndexPath> { get }
    func getNumberOfItems() -> Int
    func viewModelForCell(at indexPath: IndexPath) -> MenuBarCellViewModelType
}

final class MenuBarCell: UICollectionViewCell {
    
    private var imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    static let reuseIdentidier = "MenuBarCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        
    }
    
    func configure(with viewModel: MenuBarCellViewModelType) {
        imageView.image = viewModel.image.withRenderingMode(.alwaysTemplate)
    }
    
    override var isSelected: Bool {
        didSet {
            let color: UIColor = .oppositeColor
            imageView.tintColor = isSelected ? color : .systemGray
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        imageView.tintColor = isSelected ? .oppositeColor : .systemGray
    }
}

protocol MenuBarCellViewModelType: class {
    var image: UIImage { get set }
}

final class MenuBarCellViewModel: MenuBarCellViewModelType {
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
}

 
