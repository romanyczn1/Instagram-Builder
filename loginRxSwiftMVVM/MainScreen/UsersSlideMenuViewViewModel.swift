//
//  UsersSlideMenuViewViewModel.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 16.01.21.
//

import RxSwift
import RealmSwift
import RxDataSources

protocol UsersSlideMenuViewViewModelType: class {
    var users: Observable<[SectionOfUsers]> { get }
    var userSelected: AnyObserver<User> { get }
    var addUserTapped: AnyObserver<Void> { get }
    var didSelectUser: Observable<User> { get }
    var didTapAddUser: Observable<Void> { get }
}

final class UsersSlideMenuViewViewModel: UsersSlideMenuViewViewModelType {
    
    let users: Observable<[SectionOfUsers]>
    
    // MARK: -Inputs
    let userSelected: AnyObserver<User>
    let addUserTapped: AnyObserver<Void>
    
    //MARK: -Outputs
    var didTapAddUser: Observable<Void>
    var didSelectUser: Observable<User>
    
    let bag = DisposeBag()
    
    init(users: Observable<[User]>, addUserObserver: AnyObserver<Void>, userSelectedObserver: AnyObserver<User>) {
        self.users = users.map({ (users) -> [SectionOfUsers] in
            let usersArray = Array(users)
            var items: [UserSectionItem] = []
            usersArray.forEach { (user) in
                items.append(UserSectionItem.user(user: user))
            }
            items.append(UserSectionItem.addUser)
            
            let section = SectionOfUsers(header: "1", items: items)
            return [section]
        })
        
        let _userSelected = PublishSubject<User>()
        userSelected = _userSelected.asObserver()
        didSelectUser = _userSelected.asObservable()
        didSelectUser.bind(to: userSelectedObserver).disposed(by: bag)
        
        let _addUserTapped = PublishSubject<Void>()
        addUserTapped = _addUserTapped.asObserver()
        didTapAddUser = _addUserTapped.asObservable()
        didTapAddUser.bind(to: addUserObserver).disposed(by: bag)
    }
    
}

struct SectionOfUsers {
    
    var header: String
    var items: [Item]
    
}

enum UserSectionItem: Equatable {
        
    case user(user: User)
    case addUser
    
    func get() -> User? {
        switch self {
        case .user(let user):
            return user
        case .addUser:
            return nil
        }
    }
    
    var identity: String {
        switch self {
        case .user(let user):
            return user.userName
        case .addUser:
            return "addUser"
        }
    }
}

extension SectionOfUsers: SectionModelType {
    typealias Item = UserSectionItem
    
    init(original: SectionOfUsers, items: [Item]) {
        self = original
        self.items = items
    }
}
