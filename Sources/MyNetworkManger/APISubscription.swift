//
//  APISubscription.swift
//  
//
//  Created by Taha Hussein on 23/05/2023.
//

import Foundation
import ReactiveSwift

internal class APISubscription: APISubscriptionProtocol {
    private let disposable: AnyDisposable
    private let dataTask: URLSessionDataTask
    
    internal init(task: URLSessionDataTask){
        self.disposable = AnyDisposable{
            task.cancel()
        }
        
        self.dataTask = task
    }
    
    internal func start(){
        self.dataTask.resume()
    }
    
    internal func dispose() {
        disposable.dispose()
    }
    
    internal var isDisposed: Bool {
        get {
            return disposable.isDisposed
        }
    }
}
