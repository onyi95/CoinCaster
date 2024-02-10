//
//  LoginError.swift
//  CoinCaster
//
//  Created by Onyi Esu on 10/02/2024.
//

import Foundation

enum LoginError: Error {
    case networkError(String)
    case invalidCredentials
    case other(Int)
    case noData
}
