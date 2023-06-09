//
//  NetworkTypes.swift
//  
//
//  Created by Taha Hussein on 23/05/2023.
//

import Foundation

public typealias HTTPHeaders = [String: String]
public typealias HTTPBodyParameters = [String: Any]
public typealias HTTPQueryParameters = [String: CustomStringConvertible]

public enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

internal enum ContentType: String {
    case json = "application/json"
}

internal struct APIResponseWrapper<T> where T: CustomDecodable {
    let object: T
    let statusCode: Int
}
