//
//  MainScreenViewController.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 29.12.20.
//

import UIKit
import RxSwift
import RxCocoa

final class MainScreenViewController: UIViewController, StoryboardInitializable {
    
    var viewModel: MainScreenViewModelType!
    
    private var menuBar: MenuBar!
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.isPagingEnabled = true
        cv.dataSource = self
        cv.delegate = self
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        cv.backgroundColor = .themeColor
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.register(MainScreenCell.self, forCellWithReuseIdentifier: MainScreenCell.reuseIdentidier)
        return cv
    }()
    
    lazy var usersSlideMenu: UsersSlideMenuView = {
        let slideMenu = UsersSlideMenuView(viewModel: viewModel.usersSlideMenuViewViewModel())
        slideMenu.translatesAutoresizingMaskIntoConstraints = false
        return slideMenu
    }()
    
    private var slideMenuHeightConstraint: NSLayoutConstraint!
    
    private let blackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .themeColor
        
        setUpMenuBar()
        setUpCollectionView()
        setUpNavBar()
        setUpSlideMenu()
        setUpBarButtons()
    }
    
    private func setUpNavBar() {
        let titleView = NavBarTitleView(frame: .zero, viewModel: viewModel.navBarTitleViewViewModel())
        viewModel.didSelectTitle?.subscribe(onNext: { [unowned self] (isSelected) in
            if isSelected {
                showUsersSlideMenu()
            } else {
                hideUsersSlideMenu()
            }
        }).disposed(by: disposeBag)
        navigationItem.titleView = titleView
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.widthAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func setUpCollectionView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: menuBar.bottomAnchor, constant: 1),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setUpMenuBar() {
        menuBar = MenuBar(frame: .zero, viewModel: viewModel.menuBarViewModel())
        menuBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(menuBar)
        NSLayoutConstraint.activate([
            menuBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            menuBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuBar.heightAnchor.constraint(equalToConstant: 47.5)
        ])
        menuBar.collectionView.rx.itemSelected.distinctUntilChanged().subscribe(onNext: { [weak self] (indexPath) in
            self?.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func setUpSlideMenu() {
        view.addSubview(usersSlideMenu)
        slideMenuHeightConstraint = usersSlideMenu.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            usersSlideMenu.topAnchor.constraint(equalTo: menuBar.bottomAnchor),
            usersSlideMenu.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            usersSlideMenu.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            slideMenuHeightConstraint
        ])
        view.addSubview(blackView)
        let tap = UITapGestureRecognizer()
        blackView.addGestureRecognizer(tap)
        tap.rx.event.bind(to: viewModel.blackViewTapped).disposed(by: disposeBag)
        NSLayoutConstraint.activate([
            blackView.topAnchor.constraint(equalTo: usersSlideMenu.bottomAnchor),
            blackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setUpBarButtons() {
        let settingsImage = UIImage(named: "settings")?.withRenderingMode(.alwaysTemplate)
        
        let settingButton = UIBarButtonItem(image: settingsImage, style: .plain, target: nil, action: nil)
        settingButton.tintColor = .oppositeColor
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        addButton.tintColor = .oppositeColor
        
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)
        deleteButton.tintColor = .oppositeColor
        
        navigationItem.leftBarButtonItem = settingButton
        navigationItem.rightBarButtonItems = [addButton, deleteButton]
        
        navigationItem.leftBarButtonItem?.rx.tap.bind(to: viewModel.showSettingsTapped).disposed(by: disposeBag)
        navigationItem.rightBarButtonItem?.rx.tap.bind(to: viewModel.addPhotoTapped).disposed(by: disposeBag)
        navigationItem.rightBarButtonItems?[1].rx.tap.bind(to: viewModel.photosDeleted).disposed(by: disposeBag)
    }
    
    private func showUsersSlideMenu() {
        slideMenuHeightConstraint.constant = viewModel.getUsersSlideMenuHeight()
        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseOut]) {
            self.blackView.alpha = 0.35
            self.view.layoutIfNeeded()
        }
        
    }
    
    private func hideUsersSlideMenu() {
        slideMenuHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseOut]) {
            self.blackView.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        navigationItem.leftBarButtonItem?.tintColor = .oppositeColor
        navigationItem.rightBarButtonItems?.forEach({ (button) in
            button.tintColor = .oppositeColor
        })
    }
}

extension MainScreenViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainScreenCell.reuseIdentidier, for: indexPath) as! MainScreenCell
        print("cellForItem at \(indexPath)")
        cell.bindCollectionView(with: viewModel.mainScreeCellViewModel(for: indexPath))
        return cell
    }
}

extension MainScreenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - (menuBar.frame.height) - view.safeAreaInsets.top - 1)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.sliderLeadingConstraint.constant = scrollView.contentOffset.x/2
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x/view.frame.width)
        let indexPath = IndexPath(item: index, section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
        viewModel.menuBarCellSelected.onNext(indexPath)
    }
}
