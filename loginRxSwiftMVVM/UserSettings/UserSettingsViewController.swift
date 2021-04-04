//
//  UserSettingsViewController.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 11.03.21.
//

import UIKit
import RxCocoa
import RxSwift

final class UserSettingsViewController: UIViewController, StoryboardInitializable {
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete User", for: .normal)
        button.setTitleColor(.red, for: .normal)
        return button
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Username:"
        return label
    }()
    
    private let userNameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.backgroundColor = UIColor.secondarySystemBackground
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    var viewModel: UserSettingsViewModelType!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        
        view.backgroundColor = UIColor.themeColor
        
        setUpUsernameTextField()
        setUpDeleteButton()
        setUpNavBar()
    }
    
    private func setUpNavBar() {
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        cancelButton.rx.tap.bind(to: viewModel.cancelButtonTapped).disposed(by: disposeBag)
        navigationItem.leftBarButtonItem = cancelButton
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: nil, action: nil)
        doneButton.rx.tap.map{ [weak self] in (self?.userNameTextField.text!)! }.bind(to: viewModel.doneButtonTapped).disposed(by: disposeBag)
        navigationItem.rightBarButtonItem = doneButton
        
        viewModel.user.subscribe(onNext: { [weak self] (user) in
            self?.navigationItem.title = user.userName
        }).disposed(by: disposeBag)
    }
    
    private func setUpDeleteButton() {
        view.addSubview(deleteButton)
        deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        deleteButton.rx.tap.bind(to: viewModel.deleteButtonTapped).disposed(by: disposeBag)
    }
    
    private func setUpUsernameTextField() {
        view.addSubview(userNameTextField)
        view.addSubview(usernameLabel)
        userNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 200).isActive = true
        userNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        userNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        usernameLabel.leadingAnchor.constraint(equalTo: userNameTextField.leadingAnchor, constant: 5).isActive = true
        usernameLabel.bottomAnchor.constraint(equalTo: userNameTextField.topAnchor, constant: -3).isActive = true
        viewModel.user.subscribe(onNext: { [weak self] user in
            self?.userNameTextField.text = user.userName
        }).disposed(by: disposeBag)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        view.backgroundColor = UIColor.themeColor
        userNameTextField.textColor = UIColor.themeColor
    }
}
