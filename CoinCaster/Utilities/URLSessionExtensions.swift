//
//  URLSessionExtensions.swift
//  CoinCaster
//
//  Created by Onyi Esu on 11/02/2024.
//

import Foundation

// Extension for URLSessionDataTask to conform to URLSessionDataTaskProtocol
extension URLSessionDataTask: URLSessionDataTaskProtocol {}

// Extension for URLSession to conform to URLSessionProtocol
extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        // Cast the URLSessionDataTask to URLSessionDataTaskProtocol and return
        return (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}
