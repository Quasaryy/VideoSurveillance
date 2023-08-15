//
//  RealmCams.swift
//  VideoSurveillance
//
//  Created by Yury on 14/08/2023.
//

import Foundation
import RealmSwift

class CameraRealm: Object {
    @Persisted var id = 0
    @Persisted var name: String = ""
    @Persisted var room: String?
    @Persisted var snapshot: String = ""
    @Persisted var roomNameLabel: String?
    @Persisted var favorites: Bool = false
    @Persisted var rec: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
