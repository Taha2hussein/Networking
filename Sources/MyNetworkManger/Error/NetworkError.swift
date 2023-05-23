//
//  NetworkError.swift
//  
//
//  Created by Taha Hussein on 23/05/2023.
//

import Foundation

private let NetworkManagerDomain: String = "package.networkManager"
public class NetworkError: NSError {
    public convenience init(errorType: ErrorType) {
        self.init(domain: NetworkManagerDomain, code: errorType.rawValue, userInfo: [NSLocalizedDescriptionKey : String(describing: errorType)])
    }
}
