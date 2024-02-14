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

protocol CoinManagerProtocol: AnyObject  {
    func updateCoinPrice(_ currency: String)
    func registerUser(email: String, password: String, completion : @escaping (Result<Int, RegistrationError>) -> Void)
    func loginUser(email: String, password: String, completion: @escaping (Result<Int, LoginError>) -> Void)
    func logoutUser(withUserId userId: String, completion: @escaping (Bool) -> Void)
    func sendTargetPriceToServer(targetPrice: Double, completion: @escaping (Bool) -> Void)
    func userSelectedCurrency(currency: String, completion: @escaping (Bool) -> Void)
    var currencyArray: [String] {get}
    var delegate: PriceUpdaterDelegate? { get set }
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

// decouple networking code from URLSession directly to enable mock network calls in unit tests without making actual HTTP requests.
protocol URLSessionDataTaskProtocol {
    func resume()
}

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
    
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void

}

