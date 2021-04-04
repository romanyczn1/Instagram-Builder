//
//  LoginViewController.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 29.12.20.
//

import UIKit
import RxCocoa
import RxSwift

final class LoginViewController: UIViewController, StoryboardInitializable {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    var viewModel: LoginViewControllerViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setUpBindings()
    }
    
    private func setUpViews() {
        loginButton.layer.cornerRadius = loginButton.bounds.height/6
        registerButton.layer.cornerRadius = registerButton.bounds.height/6
    }
    
    private func setUpBindings() {
        loginButton.rx.tap.bind(to: viewModel.loginTapeed).disposed(by: disposeBag)
        registerButton.rx.tap.bind(to: viewModel.registerTapped).disposed(by: disposeBag)
        loginTextField.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: disposeBag)
        passwordTextField.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: disposeBag)
    }
}
