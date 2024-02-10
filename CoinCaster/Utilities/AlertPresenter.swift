//
//  AlertPresenter.swift
//  CoinCaster
//
//  Created by Onyi Esu on 08/02/2024.
//

import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    weak var viewController: UIViewController?
    var onAlertDismissed: (() -> Void)?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showAlert(withTitle title: String, message: String, onDismiss: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // Call the onDismiss closure when the OK action is triggered
            onDismiss?()
        })
        viewController?.present(alert, animated: true, completion: nil)

        // Set the onAlertDismissed closure to be called later if needed
        self.onAlertDismissed = onDismiss
    }
}
