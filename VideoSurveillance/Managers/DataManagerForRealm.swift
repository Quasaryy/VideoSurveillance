//
//  DataManagerForRealm.swift
//  VideoSurveillance
//
//  Created by Yury on 23/08/2023.
//

import RealmSwift

class DataManagerForRealm {
    // MARK: - Properties
    static let shared = DataManagerForRealm()
    
    // MARK: - Init
    private init() {}

}

// MARK: - Methods
extension DataManagerForRealm {
    
    func loadCameras() -> [Camera] {
        let realm = try! Realm()
        let cameraRealms = realm.objects(CameraRealm.self)
        let cameras = Array(cameraRealms).map { cameraRealm in
            return Camera(
                name: cameraRealm.name,
                snapshot: cameraRealm.snapshot,
                room: cameraRealm.room,
                roomNameLabel: cameraRealm.roomNameLabel,
                id: cameraRealm.id,
                favorites: cameraRealm.favorites,
                rec: cameraRealm.rec
            )
        }
        return cameras
    }
}
