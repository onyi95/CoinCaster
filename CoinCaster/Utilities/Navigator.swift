//
//  Navigator.swift
//  CoinCaster
//
//  Created by Onyi Esu on 08/02/2024.
//

import UIKit

class Navigator: NavigatorProtocol {
    weak var viewController: UIViewController?
    var coinManager: CoinManagerProtocol = CoinManager()
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func navigateToCurrencySelectionViewController() {
        //Dismiss Registration or Login VC and embed CurrencySelectionViewController in Navigation Controller
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let currencySelectionViewController = storyboard.instantiateViewController(withIdentifier: "CurrencySelectionViewController") as? CurrencySelectionViewController {
                let navigationController = UINavigationController(rootViewController: currencySelectionViewController)
                sceneDelegate.window?.rootViewController = navigationController
                currencySelectionViewController.coinManager = coinManager
            }
        }
    }
    
}
