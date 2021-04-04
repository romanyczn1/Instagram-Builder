//
//  LoginVCViewModel.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 3.01.21.
//
import RxSwift

final class LoginViewControllerViewModel {
    
    // MARK: -Inputs
    let loginTapeed: AnyObserver<Void>
    let registerTapped: AnyObserver<Void>
    let email: AnyObserver<String>
    let password: AnyObserver<String>
    
    //MARK: -Outputs
    let didLoginTapped: Observable<Void>
    let didRegisterTpped: Observable<Void>
    let credentials: Observable<Credentials>
    
    private let disposeBag = DisposeBag()
    
    init() {
        let _loginTapped = PublishSubject<Void>()
        loginTapeed = _loginTapped.asObserver()
        didLoginTapped = _loginTapped.asObservable()
        
        let _registerTapped = PublishSubject<Void>()
        registerTapped = _registerTapped.asObserver()
        didRegisterTpped = _registerTapped.asObservable()
        
        let emailSubject = PublishSubject<String>()
        email = emailSubject.asObserver()
        let passwordSubject = PublishSubject<String>()
        password = passwordSubject.asObserver()
        credentials = Observable.combineLatest(emailSubject.asObservable(), passwordSubject.asObservable()).map({ (email, pass) -> Credentials in
            return Credentials(email: email, password: pass)
        })
        
        didLoginTapped.withLatestFrom(credentials).map { $0 }.subscribe(onNext: { credentials in
            print(credentials)
        }).disposed(by: disposeBag)
        
        didRegisterTpped.withLatestFrom(credentials).map { $0 }.subscribe(onNext: { credentials in
            print(credentials)
        }).disposed(by: disposeBag)
    }
}
