//
//  DoorsModel.swift
//  VideoSurveillance
//
//  Created by Yury on 12/08/2023.
//

import Foundation

// MARK: - Doors
struct Doors: Codable {
    let success: Bool
    var data: [Datum]
    static let shared = Doors(success: Bool(), data: [Datum]())
}

// MARK: - Datum
struct Datum: Codable {
    let name: String
    let room: String?
    let id: Int
    var favorites: Bool
    let snapshot: String?
}

