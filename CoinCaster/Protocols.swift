//
//  Protocols.swift
//  CoinCaster
//
//  Created by Onyi Esu on 06/02/2024.
//

import Foundation
import UserNotifications

protocol AlertPresenterProtocol {
    func showAlert(withTitle title: String, message: String, onDismiss: (() -> Void)?)
}

protocol NavigatorProtocol {
    func navigateToCurrencySelectionViewController()
}

protocol CoinManagerProtocol {
    func registerUser(email: String, password: String, completion : @escaping (Result<Int, RegistrationError>) -> Void)
    func loginUser(email: String, password: String, completion: @escaping (Result<Int, LoginError>) -> Void)
    func logoutUser(withUserId userId: String, completion: @escaping (Bool) -> Void)
    func sendTargetPriceToServer(targetPrice: Double)
    func userSelectedCurrency(currency: String)
    func updateCoinPrice(_ currency: String)
}

protocol PriceUpdaterDelegate: AnyObject {
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

protocol NotificationCenterProtocol {
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)
}

protocol GetCurrencyProtocol {
    var currencyArray: [String] {get}
}
