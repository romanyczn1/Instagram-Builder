//
//  MainPhotosCell.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 14.01.21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class MainScreenCell: UICollectionViewCell {
    
    static let reuseIdentidier = "MainScreenCell"
    
    private let viewScrolled: PublishSubject<CGFloat>
    private var viewModel: MainScreenCellViewModelType?
    private let disposeBag: DisposeBag
     
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .themeColor
        cv.allowsMultipleSelection = true
        //cv.isScrollEnabled = false
        cv.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        return cv
    }()
    
    override init(frame: CGRect) {
        self.disposeBag = DisposeBag()
        self.viewScrolled = PublishSubject<CGFloat>()
        
        super.init(frame: frame)
        
        setUpCollectionView()
    }
    
    func bindCollectionView(with viewModel: MainScreenCellViewModelType) {
        self.viewModel = viewModel
        
        viewScrolled.bind(to: viewModel.viewScrolled).disposed(by: disposeBag)
        collectionView.dataSource = nil
        let dataSource = RxCollectionViewSectionedReloadDataSource<PhotosSection> { [weak viewModel] (dataSource, cv, index, photo) -> UICollectionViewCell in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: index) as! PhotoCell
            cell.configure(with: viewModel!.photoCellViewModel(for: index))
            return cell
        }
        viewModel.sections.bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        Observable.of(collectionView.rx.modelDeselected(Photo.self), collectionView.rx.modelSelected(Photo.self))
            .merge().map { _ -> [IndexPath]? in
                return self.collectionView.indexPathsForSelectedItems
            }.bind(to: viewModel.selectedPhotos).disposed(by: disposeBag)
    }
    
    private func setUpCollectionView() {
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        collectionView.dragInteractionEnabled = true
        collectionView.delegate = self
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        collectionView.backgroundColor = .themeColor
    }
}

extension MainScreenCell: UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewScrolled.onNext(scrollView.contentOffset.y)
        scrollView.bounces = (scrollView.contentOffset.y > 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: ((collectionView.frame.width-2)/3), height: ((collectionView.frame.width-2)/3))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}

extension MainScreenCell: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = viewModel?.getPhoto(at: indexPath)
        let itemProvider = NSItemProvider(object: item!)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    
}

extension MainScreenCell: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row-1, section: 0)
        }
        if coordinator.proposal.operation == .move {
            self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        }
    }
    
    fileprivate func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath {
            collectionView.performBatchUpdates ({
                viewModel?.reorderPhotos(from: sourceIndexPath, to: destinationIndexPath)
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
                collectionView.indexPathsForSelectedItems?.forEach({ (index) in
                    collectionView.deselectItem(at: index, animated: true)
                })
               viewModel?.selectedPhotos.onNext(nil)
            }, completion: nil)
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            
        }
        
    }
    
}
