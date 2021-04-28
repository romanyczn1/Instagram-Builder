//
//  MainPhotosCellViewModel.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 21.01.21.
//

import RxSwift
import RxDataSources

protocol MainScreenCellViewModelType: class {
    var photos: BehaviorSubject<[Photo]> { get }
    var sections: Observable<[PhotosSection]> { get }
    var selectedPhotos: BehaviorSubject<[IndexPath]?> { get }
    var viewScrolled: AnyObserver<CGFloat> { get }
    var scrollViewDidScroll: Observable<CGFloat> { get }
    var mainViewScrolled: Observable<CGFloat> { get }
    func photoCellViewModel(for indexPath: IndexPath) -> PhotoCellViewModelType
    func reorderPhotos(from source: IndexPath, to destination: IndexPath)
    func getPhoto(at indexPath: IndexPath) -> Photo
}

final class MainScreenCellViewModel: MainScreenCellViewModelType {
    
    private let disposeBag: DisposeBag
    var photoType: PhotoType
    var photos: BehaviorSubject<[Photo]>
    let sections: Observable<[PhotosSection]>
    let selectedPhotos: BehaviorSubject<[IndexPath]?>
    private let imageStoringService: ImageStoringService
    private let database: DataService
    let didReorderPhotos: PublishSubject<Void>
    let viewScrolled: AnyObserver<CGFloat>
    let scrollViewDidScroll: Observable<CGFloat>
    let mainViewScrolled: Observable<CGFloat>
    
    init(database: DataService, photoType: PhotoType,
         deletePhotosTapped: Observable<Void>, imagesAdded: Observable<[UIImage]?>,
         selectedUser: Observable<User>, mainViewScrolled: Observable<CGFloat>) {
        
        self.database = database
        self.disposeBag = DisposeBag()
        self.photoType = photoType
        self.imageStoringService = ImageStoringService()
        self.photos = BehaviorSubject<[Photo]>(value: [])
        self.selectedPhotos = BehaviorSubject<[IndexPath]?>(value: [])
        self.didReorderPhotos = PublishSubject<Void>()
        self.mainViewScrolled = mainViewScrolled
        
        let _viewScrolled = PublishSubject<CGFloat>()
        viewScrolled = _viewScrolled.asObserver()
        scrollViewDidScroll = _viewScrolled.asObservable()
        
        sections = photos.map({ photos in
            let section = PhotosSection(header: "0", items: photos)
            return [section]
        })

        selectedUser.subscribe(onNext: { [weak self] user in
            switch photoType {
            case .ordinary:
                let sortedPhotos = user.photos.sorted { (photo, photo1) -> Bool in
                    photo.pos < photo1.pos
                }
                self?.photos.onNext(Array(sortedPhotos))
            case .userMarked:
                let sortedPhotos = user.markedPhotos.sorted { (photo, photo1) -> Bool in
                    photo.pos < photo1.pos
                }
                self?.photos.onNext(Array(sortedPhotos))
            }
        }).disposed(by: disposeBag)

        didReorderPhotos.withLatestFrom(selectedUser).subscribe(onNext: { [weak self] user in
            let sortedPhotos = user.photos.sorted { (photo, photo1) -> Bool in
                photo.pos < photo1.pos
            }
            self?.photos.onNext(Array(sortedPhotos))
        }).disposed(by: disposeBag)

        imagesAdded.withLatestFrom(selectedUser) { images,user in
            return (images,user)
        }.subscribe(onNext: { [weak self] (images, user) in
            if images != nil {
                self?.database.addPhotos(for: user, images: images!, photoType: self!.photoType)
                switch photoType {
                case .ordinary:
                    let sortedPhotos = user.photos.sorted { (photo, photo1) -> Bool in
                        photo.pos < photo1.pos
                    }
                    self?.photos.onNext(Array(sortedPhotos))
                case .userMarked:
                    let sortedPhotos = user.markedPhotos.sorted { (photo, photo1) -> Bool in
                        photo.pos < photo1.pos
                    }
                    self?.photos.onNext(Array(sortedPhotos))
                }
            }
        }).disposed(by: disposeBag)

        let selections = selectedPhotos.withLatestFrom(selectedUser) { (indexes, user) in
            return (indexes, user)
        }
        deletePhotosTapped.withLatestFrom(selections).subscribe(onNext: { [weak self] (indexes, user) in
            if indexes != nil {
                let positions: [Int] = indexes!.map { $0.row }
                self?.database.deletePhotos(for: user, positions: positions, photoType: photoType)
                switch photoType {
                case .ordinary:
                    let sortedPhotos = user.photos.sorted { (photo, photo1) -> Bool in
                        photo.pos < photo1.pos
                    }
                    self?.photos.onNext(Array(sortedPhotos))
                case .userMarked:
                    let sortedPhotos = user.markedPhotos.sorted { (photo, photo1) -> Bool in
                        photo.pos < photo1.pos
                    }
                    self?.photos.onNext(Array(sortedPhotos))
                }
                self?.selectedPhotos.onNext(nil)
            }
        }).disposed(by: disposeBag)
    }
    
    func getPhoto(at indexPath: IndexPath) -> Photo {
        do {
            let photo = try photos.value()[indexPath.row]
            return photo
        } catch  {
            return Photo()
        }
    }
    
    func photoCellViewModel(for indexPath: IndexPath) -> PhotoCellViewModelType {
        do {
            let imageName = try photos.value()[indexPath.row].imageName
            let image = imageStoringService.loadImageFromDiskWith(fileName: imageName)
            return PhotoCellViewModel(with: image!)
        } catch {
            return PhotoCellViewModel(with: UIImage())
        }
    }
    
    func reorderPhotos(from source: IndexPath, to destination: IndexPath) {
        database.changePositions(from: source.row, to: destination.row, photos: try! photos.value())
        didReorderPhotos.onNext(())
    }
}

struct PhotosSection {
    var header: String
    var items: [Item]
    
}

extension PhotosSection: AnimatableSectionModelType {
    
    typealias Identity = String
    typealias Item = Photo
    
    init(original: PhotosSection, items: [Item]) {
        self = original
        self.items = items
    }
    
    var identity: String {
        return "photoSection"
    }
}

