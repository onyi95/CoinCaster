//
//  CoinManager.swift
//  CoinCaster
//
//  Created by Onyi Esu on 02/01/2024.
//

import Foundation
import KeychainSwift

var currentPrice: Double?
var userIdNo: Int?

class CoinManager: CoinManagerProtocol {
    weak var delegate: PriceUpdaterDelegate?
    var currencyArray: [String] = ["AUD","BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let baseURL = API.baseURL
    let apiKey = API.apiKey
    
    func updateCoinPrice(_ currency: String) {
        let fullString = "\(baseURL)/\(currency)/?apikey=\(apiKey)"
        if let url = URL(string: fullString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!) // using the delegate methods to handle the errors
                    // print(error!)
                    return
                }
                
                if let safeData = data {
                    if let bitcoinPrice = self.parseJSON(coinData: safeData){
                        
                        currentPrice = bitcoinPrice  //Assigning the parsed bitcoinprice to currentPrice, to use within sendTargetPriceToServer
                        
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        
                        self.delegate?.didUpdatePrice(price: priceString, currency: currency) // Here we pass the price and currency in, so that the main thread can be updated.
                    }
                }
            }
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
    
    func registerUser(email: String, password: String, completion: @escaping (Result<Int, RegistrationError>) -> Void) {
        let url = URL(string: "https://protected-scrubland-77734-07d1a0d3b8b2.herokuapp.com/register_user")!
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
                //check if an error occured
                if let error = error {
                    //map error ro a custom error type
                    completion(.failure(.networkError(error.localizedDescription)))
                    return
                }
                
                
                //cast the response to HTTPURLResponse to access the status codes
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.other(0)))
                    return
                }
                switch httpResponse.statusCode {
                case 201:
                    guard let data = data, !data.isEmpty else {
                        completion(.failure(.noData))
                        return
                    }
                    self.handleSuccessfulRegistration(with: data)
                    completion(.success(httpResponse.statusCode))
                case 409:
                    print("This email is already in use. Please use a different email.")
                    completion(.failure(.emailAlreadyInUse))
                default:
                    print("Failed to register user: \(httpResponse.statusCode)")
                    completion(.failure(.other(httpResponse.statusCode)))
                }
            }
            
            task.resume()
        }
    }
    
    func handleSuccessfulRegistration(with data: Data) {
        // Process the data from successful registration
        // Extracting the user ID and saving it
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let userId = json["user_id"] as? Int {
                userIdNo = userId //Assigning to use within sendTargetPriceToServer func if it was a new user
                let keychain = KeychainSwift()
                keychain.set(String(userId), forKey: "userId")
                print("Received user ID: \(userId)")
            }
        } catch {
            print("Error parsing the JSON data")
        }
        
        if let token = KeychainSwift().get("token"),let user_id = KeychainSwift().get("userId"){
            sendDeviceTokenToServer(token: token, userId: user_id)
            print(user_id)
            
        }
        
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Result<Int, LoginError>) -> Void) {
        let url = URL(string: "https://protected-scrubland-77734-07d1a0d3b8b2.herokuapp.com/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        if let jsonBody = try? JSONSerialization.data(withJSONObject: body, options: []){
            print("Sending JSON: \(String(data: jsonBody, encoding: .utf8) ?? "Invalid JSON")")
            request.httpBody = jsonBody
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    //map error ro a custom error type
                    completion(.failure(.networkError(error.localizedDescription)))
                    return
                }
                
                //cast the response to HTTPURLResponse to access the status codes
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.other(0)))
                    return
                }
                switch httpResponse.statusCode {
                case 200:
                    guard let data = data, !data.isEmpty else {
                        completion(.failure(.noData))
                        return
                    }
                    self.handleSuccessfulLogin(with: data)
                    completion(.success(httpResponse.statusCode))
                case 401:
                    print("Invalid email or password")
                    completion(.failure(.invalidCredentials))
                default:
                    print("Login failed: \(httpResponse.statusCode)")
                    completion(.failure(.other(httpResponse.statusCode)))
                }
            }
            
            task.resume()
        }
    }
    
    func handleSuccessfulLogin(with data: Data) {
        // Process the data from successful login
        // Extracting the user ID and saving it
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let userId = json["user_id"] as? Int {
                userIdNo = userId //Assigning to use within sendTargetPriceToServer func if it was an existing user that logs in
                let keychain = KeychainSwift()
                keychain.set(String(userId), forKey: "userId")
                print("Login successful. User ID: \(userId)")
            }
        } catch {
            print("Error parsing the JSON data")
        }
        
        if let token = KeychainSwift().get("token"),let user_id = KeychainSwift().get("userId"){
            sendDeviceTokenToServer(token: token, userId: user_id)
            print(user_id)
            
            UserSessionManager.shared.saveLoginState()  //Save login state on user's device
            
        }
    }
    //MARK: - Send Device Token to Server
    private func sendDeviceTokenToServer(token: String, userId: String) {
        let url = URL(string: "https://protected-scrubland-77734-07d1a0d3b8b2.herokuapp.com/register_token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: AnyHashable] = [
            "token": token,
            "user_id": Int(userId)
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
    
    //MARK: - Send Target Price to Server
    func sendTargetPriceToServer(targetPrice: Double) {
        //print(userIdNo)
        guard let userId = userIdNo else {
            print("User ID was not found")
            return
        }
        
        if currentPrice != targetPrice {
            let url = URL(string: "https://protected-scrubland-77734-07d1a0d3b8b2.herokuapp.com/update_alert")!
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
                    print("Error occurred: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Target price sent successfully")
                } else {
                    print("Failed to send target price")
                }
            }
            
            task.resume()
        }
    }
    //MARK: - Sending Logout Request to Server
    func logoutUser(withUserId userId: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://protected-scrubland-77734-07d1a0d3b8b2.herokuapp.com/logout")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["user_id": userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error occurred during logout: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Logout successful")
                completion(true)
            } else {
                print("Logout failed with response: \(String(describing: response))")
                completion(false)
            }
        }
        task.resume()
    }
    //MARK: - Sending User Selected Currency
    func userSelectedCurrency(currency: String){
        guard let userId = userIdNo else {
            print("User ID was not found")
            return
        }
        
        let url = URL(string: "https://protected-scrubland-77734-07d1a0d3b8b2.herokuapp.com/selected_currency")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let body: [String: Any] = [
            "user_id": userId,
            "selected_currency": currency
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Selected currency sent successfully")

            } else {
                print("Failed to send Selected currency")
            }
            
        }
        task.resume()
    }
    
}
