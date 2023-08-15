//
//  RealmLockIcon.swift
//  VideoSurveillance
//
//  Created by Yury on 15/08/2023.
//

import Foundation
import RealmSwift

class LockIconRealm: Object {
    @Persisted var id = 0
    @Persisted var lockIcon: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
