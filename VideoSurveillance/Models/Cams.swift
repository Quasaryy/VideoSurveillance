//
//  CamsModel.swift
//  VideoSurveillance
//
//  Created by Yury on 12/08/2023.
//

import Foundation

// MARK: - Cameras
struct Cameras: Codable {
    let success: Bool
    var data: DataClass
    static let shared = Cameras(success: Bool(), data: DataClass(room: [String](), cameras: [Camera]()))
}

// MARK: - DataClass
struct DataClass: Codable {
    let room: [String]
    var cameras: [Camera]
}

// MARK: - Camera
struct Camera: Codable {
    let name: String
    let snapshot: String
    let room: String?
    let id: Int
    var favorites, rec: Bool
}
