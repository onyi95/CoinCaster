//
//  CoinManager.swift
//  CoinCaster
//
//  Created by Onyi Esu on 02/01/2024.
//

import Foundation
import KeychainSwift

//1*. Define the protocols for updating the UI and dealing with errors (in other words, these are the responsibilities of the delegate
protocol PriceUpdaterDelegate {
    
    func didUpdatePrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

//why do we use a struct here instead of a class?
//Structs are simpler and support immutability, as we dont want to accidentally change the data in our array from another view controller for example. We also don't need any inheritance, we simply want to store bits of information in the same location for a cleaner code and easy access to

struct CoinManager {
    
    static let shared = CoinManager() //shared instance
    
    //3*. Declaring a property for the delegate created above, so that it can be used within the struct
    var delegate: PriceUpdaterDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "763B4CBF-261D-47FD-B510-242F8BFC1784"
    
    func updateCoinPrice(_ currency: String) {
        
        let fullString = "\(baseURL)/\(currency)/?apikey=\(apiKey)"
        
        //1. Create a URL
        
        if let url = URL(string: fullString) {
            
            //2. Create a URL session
            
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                
                if error != nil {
                    delegate?.didFailWithError(error: error!) // using the delegate methods to handle the errors
                    // print(error!)
                    return
                }
                
                if let safeData = data {
                    if let bitcoinPrice = parseJSON(coinData: safeData){
                        
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency) // Here we pass the price and currency in, so that the main thread can be updated.
                    }
                }
            }
            
            //4. Start the task
            task.resume()
            
        }
        
        
    }
    
    func parseJSON(coinData: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let latestPrice = decodedData.rate
            return latestPrice
        }catch{
            delegate?.didFailWithError(error: error) // we use the delegate methods to handle the errors here again, which is one of its benefits.
            return nil
        }
        
    }
    
    func registerUser(email: String, password: String) {
        let url = URL(string: "https://protected-scrubland-77734.herokuapp.com/register_user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        if let jsonBody = try? JSONSerialization.data(withJSONObject: body, options: []) {
            print("Sending JSON: \(String(data: jsonBody, encoding: .utf8) ?? "Invalid JSON")")
            request.httpBody = jsonBody
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error occurred during registration: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                           let userId = json["user_id"] as? Int {
                            let keychain = KeychainSwift()
                            keychain.set(String(userId), forKey: "userId")
                            print("Received user ID: \(userId)")
                        }
                    } catch {
                        print("Error parsing the JSON data")
                    }
                } else {
                    print("Failed to register user")
                }
            }
            
            task.resume()
        }
    }
        
        
        func sendDeviceTokenToServer(token: String) {
            let url = URL(string: "https://protected-scrubland-77734.herokuapp.com/register_token")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: AnyHashable] = [
                "token": token,
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error sending token to server: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("HTTP Error: \(httpResponse.statusCode)")
                    return
                }
                
                // Handle the success response here
                print("Token successfully sent to server.")
            }
            
            task.resume()
        }
        
        func sendTargetPriceToServer(userId: String, targetPrice: Double) {
            let url = URL(string: "https://protected-scrubland-77734.herokuapp.com/update_alert")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "user_id": userId,
                "target_price": targetPrice
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error occurred: \(error)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Target price sent successfully")
                    // Handle successful response
                } else {
                    print("Failed to send target price")
                    // Handle failure
                }
            }
            
            task.resume()
        }
        
    }

