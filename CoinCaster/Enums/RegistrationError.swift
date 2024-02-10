//
//  RegistrationError.swift
//  CoinCaster
//
//  Created by Onyi Esu on 10/02/2024.
//

import Foundation

enum RegistrationError: Error, Equatable {
    case networkError(String)
    case emailAlreadyInUse
    case other(Int)
    case noData
}
