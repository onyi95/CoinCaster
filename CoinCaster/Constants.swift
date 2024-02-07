//
//  Constants.swift
//  CoinCaster
//
//  Created by Onyi Esu on 26/01/2024.
//

import Foundation

struct segues {
    static let registerSegue = "registerToTrackBTC"
    static let loginSegue = "loginToTrackBTC"
    static let welcomeSegue = "welcomeView"
}


enum RegistrationError: Error, Equatable {
    case networkError(String)
    case emailAlreadyInUse
    case other(Int)
    case noData
}

enum LoginError: Error {
    case networkError(String)
    case invalidCredentials
    case other(Int)
    case noData
}
