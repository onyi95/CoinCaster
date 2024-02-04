//
//  UserSessionManager.swift
//  CoinCaster
//
//  Created by Onyi Esu on 31/01/2024.
//

import Foundation

class UserSessionManager {
    
    static let shared = UserSessionManager()

    private init() {}

    func saveLoginState() {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.synchronize()
    }

    func isUserLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.synchronize()
        // Additional logout actions like clearing stored data, etc.
    }
}

