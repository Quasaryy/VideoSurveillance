//
//  Loger.swift
//  VideoSurveillance
//
//  Created by Yury on 23/08/2023.
//

import Foundation
import RealmSwift

struct Logger {
    
    // MARK: - Properties
    
    static var isLoggingEnabled = true // Flag to enable/disable logging
    
}

// MARK: - Methods

extension Logger {
    
    // Method for logging Realm location information
    static func logRealmLocation(_ realm: Realm) {
        guard isLoggingEnabled else { return }
        
        if let realmURL = realm.configuration.fileURL {
            log("Realm is located at: \(realmURL)")
        }
    }
    
    // Method for logging Realm initializing error
    static func logRealmInitializationError(_ error: Error) {
        print("Error initializing Realm: \(error)")
    }
    
    // Method for logging Realm errors
    static func logRealmError(_ error: Error) {
        guard isLoggingEnabled else { return }
        print("Error with Realm: \(error)")
    }
    
    
    // Method for logging response information
    static func logResponse(_ response: URLResponse) {
        guard isLoggingEnabled else { return }
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            log("HTTP Status Code: \(statusCode)")
        } else {
            log("URL Response: \(response)")
        }
    }
    
    // Method for logging URLSession error with description
    static func logErrorDescription(_ error: Error) {
        guard isLoggingEnabled else { return }
        
        print(error.localizedDescription)
    }
    
    static func logLockStatus(_ lockStatus: Bool) {
        guard isLoggingEnabled else { return }
        
        print("Lock Status: \(lockStatus)")
    }
    
    // General method for logging
    static func log(_ message: String) {
        guard isLoggingEnabled else { return }
        
        print(message)
    }
    
}
