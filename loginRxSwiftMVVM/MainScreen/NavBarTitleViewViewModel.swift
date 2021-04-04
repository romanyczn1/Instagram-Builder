//
//  NavBarTitleViewViewModel.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 15.01.21.
//

import RxCocoa
import RxSwift
import UIKit

protocol NavBarTitleViewViewModelType: class {
    var titleSelected: AnyObserver<Bool> { get }
    var selectedUser: Observable<User> { get }
    var blackViewDidTapped: Observable<UITapGestureRecognizer> { get }
    var addUserTapped: Observable<Void> { get }
    var userSelected: Observable<Void> { get }
}

final class NavBarTitleViewViewModel: NavBarTitleViewViewModelType {
    
    private let disposeBag: DisposeBag
        
    // MARK: -Inputs
    let titleSelected: AnyObserver<Bool>
    
    //MARK: -Outputs
    let didSelectTitle: Observable<Bool>
    let selectedUser: Observable<User>
    let blackViewDidTapped: Observable<UITapGestureRecognizer>
    var addUserTapped: Observable<Void>
    var userSelected: Observable<Void>
    
    init(user: Observable<User>, blackViewDidTapped: Observable<UITapGestureRecognizer>,
         addUserTapped: Observable<Void>, userSelected: Observable<Void>) {
        disposeBag = DisposeBag()
        
        let _titleSelected = PublishSubject<Bool>()
        titleSelected = _titleSelected.asObserver()
        didSelectTitle = _titleSelected.asObservable()
        
        selectedUser = user
        
        self.blackViewDidTapped = blackViewDidTapped
        self.addUserTapped = addUserTapped
        self.userSelected = userSelected
    }
}
