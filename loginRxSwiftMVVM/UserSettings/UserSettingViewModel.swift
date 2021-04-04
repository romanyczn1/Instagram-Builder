//
//  UserSettingViewModel.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 12.03.21.
//

import RxSwift

protocol UserSettingsViewModelType {
    var cancelButtonTapped: AnyObserver<Void> { get }
    var doneButtonTapped: AnyObserver<String> { get }
    var deleteButtonTapped: AnyObserver<Void> { get }
    var didTapCancelButton: Observable<Void> { get }
    var didTapDoneButton: Observable<String> { get }
    var didTapDeleteButton: Observable<Void> { get }
    var user: Observable<User> { get }
}

final class UserSettingsViewModel: UserSettingsViewModelType {
    
    //MARK: -Inputs
    let cancelButtonTapped: AnyObserver<Void>
    let doneButtonTapped: AnyObserver<String>
    var deleteButtonTapped: AnyObserver<Void>
    
    //MARK: -Outputs
    let didTapCancelButton: Observable<Void>
    let didTapDoneButton: Observable<String>
    var didTapDeleteButton: Observable<Void>
    let user: Observable<User>
    
    private let disposeBag = DisposeBag()
    
    init(user: Observable<User>) {
        
        self.user = user
        
        let _cancelButtonTapped = PublishSubject<Void>()
        cancelButtonTapped = _cancelButtonTapped.asObserver()
        didTapCancelButton = _cancelButtonTapped.asObservable()
        
        let _doneButtonTapped = PublishSubject<String>()
        doneButtonTapped = _doneButtonTapped.asObserver()
        didTapDoneButton = _doneButtonTapped.asObservable()
        
        let _deleteButtonTapped = PublishSubject<Void>()
        deleteButtonTapped = _deleteButtonTapped.asObserver()
        didTapDeleteButton = _deleteButtonTapped.asObservable()
    }
}
