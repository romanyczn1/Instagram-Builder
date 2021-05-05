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
    let mainViewScrolled: PublishSubject<CGFloat> = PublishSubject<CGFloat>()
    private var viewState: ViewState = .loaded
    
    private var scrollViewOfsset: CGFloat = 0
    private var menuBar: MenuBar!
    
    lazy var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        return scrollView
    }()
    
    let contentView = UIView()
    
    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        return view
    }()
    
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
        
        bindScrollView()
        bindMenuBar()
        bindNavBar()
        bindSlideMenu()
        setUpBarButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(mainScrollView)
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: mainScrollView.topAnchor, constant: 0),
            contentView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor, constant: 0),
            contentView.centerXAnchor.constraint(equalTo: mainScrollView.centerXAnchor)
        ])
        
        contentView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 247.5)
        ])
        
        menuBar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(menuBar)
        NSLayoutConstraint.activate([
            menuBar.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            menuBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            menuBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            menuBar.heightAnchor.constraint(equalToConstant: 47.5)
        ])
        
        mainScrollView.contentSize = CGSize(width: view.frame.width, height: 247.5 + view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        
        contentView.addSubview(collectionView)
        let bottomAnchor = collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        bottomAnchor.priority = UILayoutPriority(rawValue: 250)
        let heightAnchor = collectionView.heightAnchor.constraint(equalToConstant: view.frame.height - 47.5 - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        heightAnchor.priority = UILayoutPriority(rawValue: 999)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: menuBar.bottomAnchor, constant: 1),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heightAnchor,
            bottomAnchor
        ])
        
        if viewState == .loaded {
            slideMenuHeightConstraint = usersSlideMenu.heightAnchor.constraint(equalToConstant: 0)
            viewState = .appeared
        }
        
        contentView.addSubview(usersSlideMenu)
        NSLayoutConstraint.activate([
            usersSlideMenu.topAnchor.constraint(equalTo: menuBar.bottomAnchor),
            usersSlideMenu.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            usersSlideMenu.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            slideMenuHeightConstraint
        ])
        
        
        contentView.addSubview(blackView)
        NSLayoutConstraint.activate([
            blackView.topAnchor.constraint(equalTo: usersSlideMenu.bottomAnchor),
            blackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            blackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            blackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func bindScrollView() {
        viewModel.mainCellDidScroll.filter({ [unowned self] (offset) -> Bool in
            return offset != self.scrollViewOfsset
        }).debug().subscribe(onNext: { [unowned self] yOffset in
            if yOffset <= headerView.frame.height {
                mainScrollView.contentOffset.y = yOffset
            } else {
                mainScrollView.contentOffset.y = headerView.frame.height
            }
        }).disposed(by: disposeBag)
        
        mainViewScrolled.bind(to: viewModel.mainViewScrolled).disposed(by: disposeBag)
    }
    
    private func bindNavBar() {
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
    
    private func bindMenuBar() {
        menuBar = MenuBar(frame: .zero, viewModel: viewModel.menuBarViewModel())
        menuBar.collectionView.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            self?.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func bindSlideMenu() {
        let tap = UITapGestureRecognizer()
        blackView.addGestureRecognizer(tap)
        tap.rx.event.bind(to: viewModel.blackViewTapped).disposed(by: disposeBag)
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
    
    enum ViewState {
        case appeared
        case loaded
    }
}

extension MainScreenViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainScreenCell.reuseIdentidier, for: indexPath) as! MainScreenCell
        cell.bindCollectionView(with: viewModel.mainScreeCellViewModel(for: indexPath))
        return cell
    }
}

extension MainScreenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === mainScrollView {
            let yOffset = scrollView.contentOffset.y
            self.scrollViewOfsset = yOffset
            mainViewScrolled.onNext(yOffset)
        } else {
            menuBar.sliderLeadingConstraint.constant = scrollView.contentOffset.x/2
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x/view.frame.width)
        let indexPath = IndexPath(item: index, section: 0)
        menuBar.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
        viewModel.menuBarCellSelected.onNext(indexPath)
    }
}
