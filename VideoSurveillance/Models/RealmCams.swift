//
//  RealmCams.swift
//  VideoSurveillance
//
//  Created by Yury on 14/08/2023.
//

import Foundation
import RealmSwift

class CameraRealm: Object {
    @objc dynamic var id = 0
    @objc dynamic var name: String = ""
    @objc dynamic var snapshot: String = ""
    @objc dynamic var room: String?
    @objc dynamic var roomNameLabel: String?
    @objc dynamic var favorites: Bool = false
    @objc dynamic var rec: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
