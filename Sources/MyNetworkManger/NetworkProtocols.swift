//
//  NetworkProtocols.swift
//  
//
//  Created by Taha Hussein on 23/05/2023.
//

import Foundation
public protocol APISubscriptionProtocol {
    var isDisposed: Bool { get }
    func dispose()
}
