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
    private var session: URLSessionProtocol
    weak var delegate: PriceUpdaterDelegate?
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    var currencyArray: [String] = ["AUD","BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let baseURL = API.baseURL
    let apiKey = API.apiKey

//MARK: - Update Bitcoin Price
    
    func updateCoinPrice(_ currency: String) {
        let fullString = "\(baseURL)/\(currency)/?apikey=\(apiKey)"
        
        guard let url = URL(string: fullString) else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
            //let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
            self.delegate?.didFailWithError(error: error) // using the delegate methods to handle the errors
            // print(error!)
            return
        }
             
            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                self.delegate?.didFailWithError(error: NSError(domain: "Invalid response", code: 0, userInfo: nil))
                return
            }
            if let safeData = data, let bitcoinPrice = self.parseJSON(coinData: safeData){
                
                currentPrice = bitcoinPrice  //Assigning the parsed bitcoinprice to currentPrice, to use within sendTargetPriceToServer
                
                let priceString = String(format: "%.2f", bitcoinPrice)
                DispatchQueue.main.async {
                    self.delegate?.didUpdatePrice(price: priceString, currency: currency) // Here we pass the price and currency in, so that the main thread can be updated.
                }
            }else {
                self.delegate?.didFailWithError(error: NSError(domain: "Data parsing eroor", code: 1, userInfo: nil))
            }
        }
        task.resume()
    }
    
   private func parseJSON(coinData: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let latestPrice = decodedData.rate
            return latestPrice
        }catch{
            print("Error parsing the JSON: \(error)")
            return nil
        }
    }
//MARK: - User Registration
    func registerUser(email: String, password: String, completion: @escaping (Result<Int, RegistrationError>) -> Void) {
        guard let url = URL(string: "https://protected-scrubland-77734-07d1a0d3b8b2.herokuapp.com/register_user") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "password": password]
        
        if let jsonBody = try? JSONSerialization.data(withJSONObject: body, options: []) {
            print("Sending JSON: \(String(data: jsonBody, encoding: .utf8) ?? "Invalid JSON")")
            request.httpBody = jsonBody
            let task = session.dataTask(with: request) { data, response, error in
                //check if an error occured
                if let error = error {
                    //map error to a custom error type
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
    
    private func handleSuccessfulRegistration(with data: Data) {
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
        
        if let token = KeychainSwift().get("token"),let user_id = KeychainSwift().get("userId") {
            sendDeviceTokenToServer(token: token, userId: user_id) { success in
                if success {
                    print("Token sent successfully to server.")
                    UserSessionManager.shared.saveLoginState()  //Save login state on user's device
                } else {
                    print("Failed to send device token to server")
                }
            }
            print(user_id)
        }
    }
//MARK: - User Login Authentication
    func loginUser(email: String, password: String, completion: @escaping (Result<Int, LoginError>) -> Void) {
        guard let url = URL(string: "https://protected-scrubland-77734-07d1a0d3b8b2.herokuapp.com/login") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "password": password]
        
        if let jsonBody = try? JSONSerialization.data(withJSONObject: body, options: []){
            print("Sending JSON: \(String(data: jsonBody, encoding: .utf8) ?? "Invalid JSON")")
            request.httpBody = jsonBody
            
            let task = session.dataTask(with: request) { data, response, error in
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
    
    private func handleSuccessfulLogin(with data: Data) {
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
        
        if let token = KeychainSwift().get("token"),let user_id = KeychainSwift().get("userId") {
            sendDeviceTokenToServer(token: token, userId: user_id) { success in
                if success {
                    print("Token sent successfully to server.")
                    UserSessionManager.shared.saveLoginState()  //Save login state on user's device
                } else {
                    print("Failed to send device token to server")
                }
            }
            print(user_id)
        }
    }
    //MARK: - Send Device Token to Server
    func sendDeviceTokenToServer(token: String, userId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://protected-scrubland-77734-07d1a0d3b8b2.herokuapp.com/register_token") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: AnyHashable] = ["token": token, "user_id": Int(userId)]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        
        let task = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                print("Error or invalid response")
                completion(false)
                return
            }
            // Handle the success response here
            print("Token successfully sent to server.")
            completion(true)
        }
        
        task.resume()
    }
    
    //MARK: - Send Target Price to Server
    func sendTargetPriceToServer(targetPrice: Double, completion: @escaping (Bool) -> Void) {
        //print(userIdNo)
        guard let userId = userIdNo else {
            print("User ID was not found")
            return
        }
        
        if currentPrice != targetPrice {
            guard let url = URL(string: "https://protected-scrubland-77734-07d1a0d3b8b2.herokuapp.com/update_alert") else {return}
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = ["user_id": userId, "target_price": targetPrice]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error occurred: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("Target price sent successfully")
                    completion(true)
                } else {
                    print("Failed to send target price")
                    completion(false)
                }
            }
            
            task.resume()
        }
    }
    //MARK: - Sending Logout Request to Server
    func logoutUser(withUserId userId: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://protected-scrubland-77734-07d1a0d3b8b2.herokuapp.com/logout") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["user_id": userId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = session.dataTask(with: request) { _, response, error in
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
    func userSelectedCurrency(currency: String, completion: @escaping (Bool) -> Void) {
        guard let userId = userIdNo else {
            print("User ID was not found")
            return
        }
        
        guard let url = URL(string: "https://protected-scrubland-77734-07d1a0d3b8b2.herokuapp.com/selected_currency") else {return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let body: [String: Any] = ["user_id": userId, "selected_currency": currency]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        let task = session.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Selected currency sent successfully")
                completion(true)

            } else {
                print("Failed to send Selected currency")
                completion(false)
            }
        }
        task.resume()
    }
}
