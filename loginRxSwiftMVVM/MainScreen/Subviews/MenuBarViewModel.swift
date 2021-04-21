//
//  MenuBarViewModel.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 13.01.21.
//

import UIKit
import RxSwift

final class MainScreenMenuBarViewModel: MenuBarViewModelType {
    
    
    private let disposeBag: DisposeBag
    //MARK: -Inputs
    var cellSelected: AnyObserver<IndexPath>
    
    //Outputs: -Outputs
    var didSelectCell: Observable<IndexPath>
    
    private var iconImages: [UIImage?]
    
    init(cellSelectedObserver: AnyObserver<IndexPath>) {
        let firstIcon = UIImage(named: "grid")
        let secIcon = UIImage(named: "userMarked")
        iconImages = [firstIcon, secIcon]
        
        self.disposeBag = DisposeBag()
        
        let _cellSelected = PublishSubject<IndexPath>()
        cellSelected = _cellSelected.asObserver()
        didSelectCell = _cellSelected.asObservable()
        didSelectCell.bind(to: cellSelectedObserver).disposed(by: disposeBag)
    }
    
    func getNumberOfItems() -> Int {
        return iconImages.count
    }
    
    func viewModelForCell(at indexPath: IndexPath) -> MenuBarCellViewModelType {
        return MenuBarCellViewModel(image: iconImages[indexPath.item]!)
    }
    
}
