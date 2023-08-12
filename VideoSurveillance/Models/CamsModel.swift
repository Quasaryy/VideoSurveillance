//
//  CamsModel.swift
//  VideoSurveillance
//
//  Created by Yury on 13/08/2023.
//

import Foundation

struct CamerasModel {
    var success: Bool
    var data: DataClass
    var cameras: [Camera]
    
    static let shared = CamerasModel(success: Bool(), data: DataClass(room: [String](), cameras: [Camera]()), cameras: [Camera]())
}
