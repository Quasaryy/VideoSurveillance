//
//  RealmLockIcon.swift
//  VideoSurveillance
//
//  Created by Yury on 15/08/2023.
//

import Foundation
import RealmSwift

class LockIconRealm: Object {
    @objc dynamic var id = 0
    @objc dynamic var lockIcon: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
