//
//  DispatchWorkItemSubscription.swift
//  
//
//  Created by Taha Hussein on 23/05/2023.
//

import Foundation

internal class DispatchWorkItemSubscription: APISubscriptionProtocol {
    private let item: DispatchWorkItem
    
    deinit {
        if (!self.item.isCancelled) {
            self.item.cancel()
        }
    }
    
    internal init(item: DispatchWorkItem) {
        self.item = item
    }
    
    internal func dispose() {
        self.item.cancel()
    }
    
    internal var isDisposed: Bool {
        get {
            return self.item.isCancelled
        }
    }
}
