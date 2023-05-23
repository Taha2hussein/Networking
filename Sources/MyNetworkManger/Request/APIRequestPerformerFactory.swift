//
//  APIRequestPerformerFactory.swift
//  
//
//  Created by Taha Hussein on 23/05/2023.
//

import Foundation
internal class APIRequestPerformerFactory: APIRequestPerformerFactoryProtocol {
    internal static let shared = APIRequestPerformerFactory()
    
    private var requestPerformerMemorizer: [QualityOfService: APIRequestPerformerProtocol]
    
    private init() {
        requestPerformerMemorizer = [:]
    }
    
    internal func requestPerformerForQoS(_ QoS: QualityOfService) -> APIRequestPerformerProtocol {
        lock()
        
        defer{
            unlock()
        }
        
        if let existingPerformer = requestPerformerMemorizer[QoS] {
            return existingPerformer
        }
        
        let newPerformer = APIRequestPerformer(QoS: QoS)
        requestPerformerMemorizer[QoS] = newPerformer
        return newPerformer
    }
    
    private func lock() {
        objc_sync_enter(self)
    }
    
    private func unlock() {
        objc_sync_exit(self)
    }
}
