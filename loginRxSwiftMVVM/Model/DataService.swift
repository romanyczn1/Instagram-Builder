//
//  DataService.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 16.01.21.
//

import RxSwift
import RealmSwift

final class DataService {
    
    private var usersCount: Int?
    private let imageStoringService: ImageStoringService
    private let realm: Realm
    
    init() {
        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        realm = try! Realm(configuration: config)
        imageStoringService = ImageStoringService()
    }
    
    func addUser(user: User) {
        try! realm.write {
            realm.add(user)
        }
        selectUser(user: user)
    }
    
    func getUsers() -> [User] {
        let users = realm.objects(User.self)
        usersCount = users.count
        //if its a first app launch create an empty user
        if users.count == 0 {
            try! realm.write {
                realm.add(User(value: ["userName":"username", "isSelected": true]))
            }
            usersCount = 1
        }
        return Array(users)
        
    }
    
    func deleteUser(user: User) {
        let delUser = realm.object(ofType: User.self, forPrimaryKey: user.userID)
        try! realm.write {
            realm.delete(delUser!)
        }
        //select first user
        let firstUser = realm.objects(User.self).first
        try! realm.write {
            firstUser?.isSelected = true
        }
    }
    
    func selectUser(user: User) {
        let users = realm.objects(User.self)
        try! realm.write {
            users.forEach { (user) in
                user.isSelected = false
            }
            user.isSelected = true
        }
    }
    
    func changeUserName(for user: User, with newUserName: String) {
        let changingUser = realm.object(ofType: User.self, forPrimaryKey: user.userID)
        try! realm.write {
            changingUser!.userName = newUserName
        }
    }
    
    func getUsersCount() -> Int {
        return usersCount ?? 1
    }
    
    func addPhotos(for user: User, images: [UIImage], photoType: PhotoType) {
        try! realm.write {
            switch photoType {
            case .ordinary:
                user.photos.forEach { (photo) in
                    photo.pos += images.count
                }
            case .userMarked:
                user.markedPhotos.forEach { (photo) in
                    photo.pos += images.count
                }
            }
            
            for (index, image) in images.enumerated() {
                let photo = Photo(value: ["pos":index])
                imageStoringService.saveImage(imageName: photo.imageName, image: image)
                switch photoType {
                case .ordinary:
                    user.photos.append(photo)
                case .userMarked:
                    user.markedPhotos.append(photo)
                }
            }
        }
    }
    
    func deletePhotos(for user: User, positions: [Int], photoType: PhotoType) {
        var deletingCoeff = 0
        try! realm.write {
            switch photoType {
            case .ordinary:
                user.photos.sorted { (photo, photo1) -> Bool in
                    photo.pos < photo1.pos
                }.forEach { (photo) in
                    if positions.contains(photo.pos) {
                        imageStoringService.deleteImage(imageName: photo.imageName)
                        realm.delete(photo)
                        deletingCoeff += 1
                    } else {
                        photo.pos -= deletingCoeff
                    }
                }
            case .userMarked:
                user.markedPhotos.sorted { (photo, photo1) -> Bool in
                    photo.pos < photo1.pos
                }.forEach { (photo) in
                    if positions.contains(photo.pos) {
                        imageStoringService.deleteImage(imageName: photo.imageName)
                        realm.delete(photo)
                        deletingCoeff += 1
                    } else {
                        photo.pos -= deletingCoeff
                    }
                }
            }
            
        }
    }
    
    func changePositions(from source: Int, to destintaion: Int, photos: [Photo]) {
        try! realm.write {
            if source > destintaion {
                let movingPhotos = photos.filter { (photo) -> Bool in
                    if photo.pos != source {
                        return photo.pos < source && photo.pos >= destintaion
                    } else {
                        photo.pos = destintaion
                        return false
                    }
                }
                movingPhotos.forEach { (photo) in
                    photo.pos += 1
                }
            } else {
                
                let movingPhotos = photos.filter { (photo) -> Bool in
                    if photo.pos != source {
                        return photo.pos > source && photo.pos <= destintaion
                    } else {
                        photo.pos = destintaion
                        return false
                    }
                }
                movingPhotos.forEach { (photo) in
                    photo.pos -= 1
                }
                
            }
        }
    }
}
