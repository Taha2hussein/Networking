//
//  APIResponse.swift
//  
//
//  Created by Taha Hussein on 23/05/2023.
//

import Foundation
internal class APIResponse {
    let data: Data?
    let statusCode: Int
    let request: URLRequest
    let response: URLResponse?
    
    internal init(request: URLRequest, response: URLResponse?, data: Data?, statusCode: Int){
        self.data = data
        self.request = request
        self.response = response
        self.statusCode = statusCode
    }
}
