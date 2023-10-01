//
//  DataManagerForRealm.swift
//  VideoSurveillance
//
//  Created by Yury on 23/08/2023.
//

import RealmSwift

class DataManagerForRealm {
    
    // MARK: - Properties
    
    let realm = try! Realm()
    static let shared = DataManagerForRealm()
    
    // MARK: - Init
    
    // Закрытый инициализатор, чтобы предотвратить создание новых экземпляров класса
    private init() {}
    
    
}

// MARK: - Methods

extension DataManagerForRealm {
    
    // MARK: Loading from Realm
    // Method for loading data from Realm and converting it into models
    func loadFromRealm<T, U>(_ objectType: T.Type) -> [U] where T: Object, U: Decodable {
        let objects = realm.objects(objectType as Object.Type)
        
        var result: [U] = []
        
        for object in objects {
            if let convertedObject = convertObject(object, to: U.self) {
                result.append(convertedObject)
            }
        }
        
        return result // Returning the result as an array
    }
    
    // Method to convert Realm object to model
    private func convertObject<T: Object, U: Decodable>(_ object: T, to objectType: U.Type) -> U? {
        if objectType == Datum.self, let doorRealm = object as? DoorRealm {
            // Конвертируем DoorRealm в модель Door
            return Datum(
                name: doorRealm.name,
                room: doorRealm.room,
                id: doorRealm.id,
                favorites: doorRealm.favorites,
                snapshot: doorRealm.snapshot,
                lockIcon: doorRealm.lockIcon
            ) as? U
        } else if objectType == Camera.self, let cameraRealm = object as? CameraRealm {
            // Конвертируем CameraRealm в модель Camera
            return Camera(
                name: cameraRealm.name,
                snapshot: cameraRealm.snapshot,
                room: cameraRealm.room,
                roomNameLabel: cameraRealm.roomNameLabel,
                id: cameraRealm.id,
                favorites: cameraRealm.favorites,
                rec: cameraRealm.rec
            ) as? U
        }
        
        return nil
    }
    
    // MARK: Saving to Realm
    
    func saveCamerasToRealm(_ cameras: [Camera]) {
        do {
            try realm.write {
                realm.add(cameras.map { cameraData in
                    return CameraRealm(value: [
                        "id": cameraData.id,
                        "name": cameraData.name,
                        "snapshot": cameraData.snapshot,
                        "room": cameraData.room ?? "",
                        "roomNameLabel": cameraData.roomNameLabel ?? "",
                        "favorites": cameraData.favorites,
                        "rec": cameraData.rec
                    ] as [String : Any])
                }, update: .modified)
            }
        } catch let error {
            Logger.logRealmError(error)
        }
    }
    
    func saveDoorsToRealm(_ doors: [Datum]) {
        do {
            try realm.write {
                realm.add(doors.map { doorsData in
                    return DoorRealm(value: [
                        "id": doorsData.id,
                        "name": doorsData.name,
                        "snapshot": doorsData.snapshot ?? "",
                        "room": doorsData.room ?? "",
                        "favorites": doorsData.favorites,
                        "lockIcon": doorsData.lockIcon ?? true
                    ] as [String : Any])
                }, update: .modified)
            }
        } catch let error {
            Logger.logRealmError(error)
        }
    }
    
    // Saving any objects in Realm
    func saveObjectsToRealm<T: Object>(_ object: T?, _ updateBlock: (() -> Void)?) {
        do {
            let realm = try Realm()
            try realm.write {
                updateBlock?()
            }
        } catch let error {
            Logger.logRealmError(error)
        }
    }
    
    // MARK: Checkings
    
    // Checking if there is data in the realm for doors
    func getDoorRealms() -> Results<DoorRealm>? {
        return realm.objects(DoorRealm.self)
    }
    
    // Checking if there is data in the realm for cams
    func getCamsRealms() -> Results<CameraRealm>? {
        return realm.objects(CameraRealm.self)
    }
}
















