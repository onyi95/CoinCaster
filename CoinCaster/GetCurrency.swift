//
//  GetCurrency.swift
//  CoinCaster
//
//  Created by Onyi Esu on 08/02/2024.
//

import Foundation

import UIKit

class GetCurrency: GetCurrencyProtocol {
    
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    var currencyArray: [String] = ["AUD","BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
}
