//
//  Protocols.swift
//  CoinCaster
//
//  Created by Onyi Esu on 06/02/2024.
//

import Foundation

protocol AlertPresenterProtocol {
    func showAlert(withTitle title: String, message: String)
}

protocol NavigatorProtocol {
    func navigateToMainViewController()
}

protocol CoinManagerProtocol {
    func registerUser(email: String, password: String, completion : @escaping (Result<Int, RegistrationError>) -> Void)
    func loginUser(email: String, password: String, completion: @escaping (Result<Int, LoginError>) -> Void)
}

protocol PriceUpdaterDelegate {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}
