//
//  ViewController.swift
//  CoinCaster
//
//  Created by Onyi Esu on 01/01/2024.
//

import UIKit

class ViewController: UIViewController {
    
    var coinManager = CoinManager()
    
    @IBOutlet weak var bitcoinLabel: UILabel!
    
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    @IBOutlet weak var currencyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //set the ViewController.swift as the datasource and delegate for the picker
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        coinManager.delegate = self   // 3*. the ViewController conforms to the                                                PriceUpdaterDelegate and implements the required methods by                             setting itself as the delegate of an
        
    }
}
    //MARK: - UIPickerView DataSource Methods
  
extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 //we only need one column of data in this context
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coinManager.currencyArray.count  //tell Xcode how many rows this picker should
    }
}

    //MARK: - UIPickerView Delegate Methods
// to be able to update the PickerView with some titles and detect when it is interacted with we have to set up the PickerView’s delegate methods
    
    extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coinManager.currencyArray[row]
        //When the PickerView is loading up, it will ask its delegate for a row title and call the above method once for every row.
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCurrency = coinManager.currencyArray[row]
        
        //passing the selected currency to the CoinManager
        coinManager.updateCoinPrice(selectedCurrency)
    }

}
    

//MARK: - CoinManager Delegate Methods

//2*. Creating the delegate class
extension ViewController: PriceUpdaterDelegate {
    
    func didUpdatePrice(price: String, currency: String) {
        
        DispatchQueue.main.async { //update the main thread
            self.bitcoinLabel.text = price
            self.currencyLabel.text = currency
        }
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

