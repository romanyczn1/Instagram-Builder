//
//  UsersSlideMenuView.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 16.01.21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class UsersSlideMenuView: UIView, UIScrollViewDelegate {
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.register(UsersTableViewCell.self, forCellReuseIdentifier: UsersTableViewCell.reuseIdentifier)
        tv.rowHeight = UsersTableViewCell.cellHeight
        return tv
    }()
    
    private let viewModel: UsersSlideMenuViewViewModelType
    private let bag = DisposeBag()
    
    init(viewModel: UsersSlideMenuViewViewModelType) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        
        bindTableView()
        setUpViews()
    }
    
    private func setUpViews() {
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func bindTableView() { 
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfUsers>(
            configureCell: { dataSource, tableView, indexPath, item in
                let viewModel: UsersTableViewCellViewModel
                switch item {
                case .user(user: let user):
                    viewModel = UsersTableViewCellViewModel(user: user, cellType: .user)
                case .addUser:
                    viewModel = UsersTableViewCellViewModel(user: User(value: ["userName": "Add user"]), cellType: .addUser)
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: UsersTableViewCell.reuseIdentifier, for: indexPath) as! UsersTableViewCell
                cell.configure(with: viewModel)
                return cell
            })
        	
        viewModel.users.bind(to: tableView.rx.items(dataSource: dataSource)).disposed(by: bag)
                
        tableView.rx.modelSelected(UserSectionItem.self).filter { (item) -> Bool in
            if case UserSectionItem.user(user: _) = item {
                return true
            } else {
                return false
            }
        }.map({ (item) -> User in
            return item.get()!
        }).bind(to: viewModel.userSelected)
        .disposed(by: bag)
        
        tableView.rx.modelSelected(UserSectionItem.self).filter { (item) -> Bool in
            return UserSectionItem.addUser == item
        }.map({ (item) -> Void in
            return
        }).bind(to: viewModel.addUserTapped)
        .disposed(by: bag)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum UsersTableViewCellType {
    case user
    case addUser
}

final class UsersTableViewCell: UITableViewCell {
    static let reuseIdentifier: String = "UsersTableViewCell"
    static let cellHeight: CGFloat = 64
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    func configure(with viewModel: UsersTableViewCellViewModelType) {
        textLabel!.text = viewModel.userName
        textLabel?.textColor = viewModel.textColor
        switch viewModel.cellType {
        case .addUser:
            imageView!.image = UIImage(named: "plusIcon")?.withRenderingMode(.alwaysTemplate)
        case .user:
            imageView!.image = UIImage(named: "user")?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView?.tintColor = .oppositeColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        print("разбораться с цветом при изменении темы")
    }
}

protocol UsersTableViewCellViewModelType: class {
    var userName: String { get }
    var textColor: UIColor { get }
    var cellType: UsersTableViewCellType { get }
}

class UsersTableViewCellViewModel: UsersTableViewCellViewModelType {
    var user: User
    var cellType: UsersTableViewCellType
    
    init(user: User, cellType: UsersTableViewCellType) {
        self.user = user
        self.cellType = cellType
    }
    
    var textColor: UIColor {
        return user.isSelected ? #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1) : UIColor.oppositeColor
    }
    
    var userName: String {
        return user.userName
    }
}
