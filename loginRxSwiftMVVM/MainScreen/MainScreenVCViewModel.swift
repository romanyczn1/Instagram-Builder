//
//  MainScreenVCViewModel.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 12.01.21.
//

import RxSwift
import RxCocoa
import RealmSwift

protocol MainScreenViewModelType: class {
    var menuBarCellSelected: BehaviorSubject<IndexPath> { get }
    var didSelectTitle: Observable<Bool>? { get }
    var blackViewTapped: AnyObserver<UITapGestureRecognizer> { get }
    var addUserTapped: AnyObserver<Void> { get }
    var showSettingsTapped: AnyObserver<Void> { get }
    var userEdited: AnyObserver<UserSettingsEditResult?> { get }
    var addPhotoTapped: AnyObserver<Void> { get }
    var didTapAddPhoto: Observable<Void> { get }
    var imagesAdded: AnyObserver<[UIImage]?> { get }
    var photosDeleted: AnyObserver<Void> { get }
    var mainCellDidScroll: Observable<CGFloat> { get }
    var mainViewScrolled: AnyObserver<CGFloat> { get }
    
    func getUsersSlideMenuHeight() -> CGFloat
    func menuBarViewModel() -> MenuBarViewModelType
    func navBarTitleViewViewModel() -> NavBarTitleViewViewModelType
    func usersSlideMenuViewViewModel() -> UsersSlideMenuViewViewModel
    func mainScreeCellViewModel(for indexPath: IndexPath) -> MainScreenCellViewModelType
}

final class MainScreenViewModel: MainScreenViewModelType {
    
    private let database: DataService
    private let bag: DisposeBag
    
    //MARK: -Inputs
    var blackViewTapped: AnyObserver<UITapGestureRecognizer>
    var addUserTapped: AnyObserver<Void>
    let userSelected: AnyObserver<User>
    var addPhotoTapped: AnyObserver<Void>
    let showSettingsTapped: AnyObserver<Void>
    let userEdited: AnyObserver<UserSettingsEditResult?>
    var imagesAdded: AnyObserver<[UIImage]?>
    let photosDeleted: AnyObserver<Void>
    let mainCellScrolled: AnyObserver<CGFloat>
    let mainViewScrolled: AnyObserver<CGFloat>
    
    //MARK: -Outputs
    private let users: BehaviorSubject<[User]>
    var menuBarCellSelected: BehaviorSubject<IndexPath>
    let selectedUser: Observable<User>
    var didSelectTitle: Observable<Bool>?
    var didTapBlackView: Observable<UITapGestureRecognizer>
    let didTapAddUser: Observable<Void>
    let didSelectUser: Observable<User>
    var didTapAddPhoto: Observable<Void>
    let didShowSettingsTapped: Observable<Void>
    let didEditUser: Observable<UserSettingsEditResult?>
    let didAddImages: Observable<[UIImage]?>
    let deletePhotosTapped: Observable<Void>
    let mainCellDidScroll: Observable<CGFloat>
    let mainViewDidScroll: Observable<CGFloat>
    
    private var usersCount: Int = 0
    
    init() {
        self.database = DataService()
        bag = DisposeBag()
        
        users = BehaviorSubject<[User]>(value: database.getUsers())
        
        selectedUser = users.map({ (users) -> User in
            return users.first { (user) -> Bool in
                user.isSelected == true
            }!
        })
        
        let _blackViewTapped = PublishSubject<UITapGestureRecognizer>()
        blackViewTapped = _blackViewTapped.asObserver()
        didTapBlackView = _blackViewTapped.asObservable()
        
        let _addUserTapped = PublishSubject<Void>()
        addUserTapped = _addUserTapped.asObserver()
        didTapAddUser = _addUserTapped.asObservable()
        
        let _userSelected = PublishSubject<User>()
        userSelected = _userSelected.asObserver()
        didSelectUser = _userSelected.asObservable()
        
        let _showSettingsTapped = PublishSubject<Void>()
        showSettingsTapped = _showSettingsTapped.asObserver()
        didShowSettingsTapped = _showSettingsTapped.asObservable()
        
        let _userEdited = PublishSubject<UserSettingsEditResult?>()
        userEdited = _userEdited.asObserver()
        didEditUser = _userEdited.asObservable()
        
        let _addPhotoTapped = PublishSubject<Void>()
        addPhotoTapped = _addPhotoTapped.asObserver()
        didTapAddPhoto = _addPhotoTapped.asObservable()
        
        let _imagesAdded = PublishSubject<[UIImage]?>()
        imagesAdded = _imagesAdded.asObserver()
        didAddImages = _imagesAdded.asObservable()
        
        let _photosDeleted = PublishSubject<Void>()
        photosDeleted = _photosDeleted.asObserver()
        deletePhotosTapped = _photosDeleted.asObservable()
        
        let _mainCellScrolled = PublishSubject<CGFloat>()
        mainCellScrolled = _mainCellScrolled.asObserver()
        mainCellDidScroll = _mainCellScrolled.asObservable()
        
        let _mainViewScrolled = PublishSubject<CGFloat>()
        mainViewScrolled = _mainViewScrolled.asObserver()
        mainViewDidScroll = _mainViewScrolled.asObservable()
        
        menuBarCellSelected = BehaviorSubject<IndexPath>(value: IndexPath(item: 0, section: 0))
        
        users.subscribe(onNext: { (users) in
            self.usersCount = users.count
        }).disposed(by: bag)
        
        didTapAddUser.subscribe(onNext: {
            self.addNewUser()
            let newUsers = self.database.getUsers()
            self.users.onNext(newUsers)
        }).disposed(by: bag)
        
        didSelectUser.distinctUntilChanged().subscribe(onNext: { (user) in
            self.database.selectUser(user: user)
            self.users.onNext(self.database.getUsers())
        }).disposed(by: bag)
    
        didEditUser.withLatestFrom(selectedUser) { res,user in
            return (res,user)
        }.subscribe(onNext: { (res, user) in
            if res != nil {
                switch res! {
                case .changeUsername(userName: let userName):
                    self.database.changeUserName(for: user, with: userName)
                    self.users.onNext(self.database.getUsers())
                case .delete:
                    self.database.deleteUser(user: user)
                    self.users.onNext(self.database.getUsers())
                }
            }
        }).disposed(by: bag)
    }
    
    private func addNewUser() {
        database.addUser(user: User(value: ["userName": "username\(usersCount)"]))
    }
    
    func getUsersSlideMenuHeight() -> CGFloat {
        return UsersTableViewCell.cellHeight * CGFloat((usersCount + 1))
    }
    
    func menuBarViewModel() -> MenuBarViewModelType {
        let vm = MainScreenMenuBarViewModel(cellSelectedObserver: menuBarCellSelected.asObserver())
        return vm
    }
    
    func navBarTitleViewViewModel() -> NavBarTitleViewViewModelType {
        let viewModel = NavBarTitleViewViewModel(user: selectedUser, blackViewDidTapped: didTapBlackView, addUserTapped: didTapAddUser, userSelected: didSelectUser.map{_ in ()})
        didSelectTitle = viewModel.didSelectTitle
        return viewModel
    }
    
    func usersSlideMenuViewViewModel() -> UsersSlideMenuViewViewModel {
        return UsersSlideMenuViewViewModel(users: users.asObservable(), addUserObserver: addUserTapped, userSelectedObserver: userSelected)
    }
    
    func mainScreeCellViewModel(for indexPath: IndexPath) -> MainScreenCellViewModelType {
        let photoType: PhotoType = indexPath.row == 0 ? .ordinary : .userMarked
        
        let deletePhotosTapped = self.deletePhotosTapped.withLatestFrom(menuBarCellSelected.asObservable()).filter { (index) -> Bool in
            if photoType.rawValue == index.item {
                return true
            } else {
                return false
            }
        }.map{ _ in ()}
        
        let didAddImages = self.didAddImages.withLatestFrom(menuBarCellSelected.asObservable()){ images, index in
            return (images,index)
        }.filter { (images, index) -> Bool in
            if photoType.rawValue == index.item {
                return true
            } else {
                return false
            }
        }.map { (images, _) -> [UIImage]? in
            return images
        }.debug()
        let vm = MainScreenCellViewModel(database: database, photoType: photoType, deletePhotosTapped: deletePhotosTapped,
                                         imagesAdded: didAddImages, selectedUser: selectedUser, mainViewScrolled: mainViewDidScroll)
        vm.scrollViewDidScroll.bind(to: mainCellScrolled).disposed(by: bag)
        return vm
    }
}
