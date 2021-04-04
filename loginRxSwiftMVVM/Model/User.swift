//
//  User.swift
//  loginRxSwiftMVVM
//
//  Created by Roman Bukh on 16.01.21.
//

import RealmSwift
import RxDataSources

class User: Object {
    @objc dynamic var userID = UUID().uuidString
    @objc dynamic var userName: String = ""
    @objc dynamic var isSelected: Bool = false
    var photos = List<Photo>()
    var markedPhotos = List<Photo>()
    
    override static func primaryKey() -> String? {
      return "userID"
    }
}

class Photo: Object, IdentifiableType, NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        return ["public.photo"]
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        return nil
    }
    
    typealias Identity = String
    
    @objc dynamic var imageName: String = UUID().uuidString
    @objc dynamic var pos: Int = 0
    
    var identity: String {
        return imageName
    }
}

enum PhotoType: Int {
    case ordinary = 0
    case userMarked = 1
}
