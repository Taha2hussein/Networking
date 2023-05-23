//
//  APIPerformer.swift
//  
//
//  Created by Taha Hussein on 23/05/2023.
//

import Foundation
import ReactiveSwift

private extension QualityOfService {
    var dispatchQualityOfService: DispatchQoS {
        switch self {
        case .default: return DispatchQoS.default
        case .utility: return DispatchQoS.utility
        case .background: return DispatchQoS.background
        case .userInitiated: return DispatchQoS.userInitiated
        case .userInteractive: return DispatchQoS.userInteractive
        @unknown default: return DispatchQoS.default
        }
    }
}

open class APIPerformer {
    public static let shared = APIPerformer()

    private let requestBuilder: APIRequestBuilder
    private let dispatchQueueRetrieverSemaphore: DispatchSemaphore
    private var memorizedDispatchQueues: [QualityOfService: DispatchQueue]
    private let requestPerformerFactory: APIRequestPerformerFactoryProtocol
    
    private init() {
        memorizedDispatchQueues = [:]
        requestBuilder = APIRequestBuilder()
        requestPerformerFactory = APIRequestPerformerFactory.shared
        dispatchQueueRetrieverSemaphore = DispatchSemaphore(value: 1)
    }
    
    //MARK: - Private Functions
    private func dispatchQueueForQoS(_ QoS: QualityOfService) -> DispatchQueue {

        var dispatcQueue: DispatchQueue

        dispatchQueueRetrieverSemaphore.wait()

        if let queue = self.memorizedDispatchQueues[QoS] {
            dispatcQueue = queue
        } else {
            let newQueue = DispatchQueue(label: "APIPerformer.\(QoS.dispatchQualityOfService.qosClass).queue", qos: QoS.dispatchQualityOfService, attributes: .concurrent)
            self.memorizedDispatchQueues[QoS] = newQueue
            dispatcQueue = newQueue
        }

        dispatchQueueRetrieverSemaphore.signal()

        return dispatcQueue
    }
    
    private func connectTo<T: Decodable>(_ endpoint: APIRequest<T>, QoS: QualityOfService, completion: @escaping (Result<(Data, Int), NSError>) -> Void) -> APISubscriptionProtocol {
        
        let item = DispatchWorkItem {
            guard let request: URLRequest = self.requestBuilder.requestFrom(endpoint) else {
                completion(Result.failure(NetworkError(errorType: .invalidRequest)))
                return
            }
            
            let processedRequest = endpoint.processRequest(request)
            
            if let requestEndpoint = processedRequest.url {
               
            }
            
            let _ = self.requestPerformerFactory.requestPerformerForQoS(QoS).performRequest(processedRequest) { (result: Result<APIResponse, NSError>) in
                
                switch result {
                case .failure(let error):
                    completion(Result.failure(error))
                case .success(let response):
                    guard let httpResponse = response.response as? HTTPURLResponse else {
                        completion(Result.failure(NetworkError(errorType: .unknownError)))
                        return
                    }
                    
                    if let validationError: NSError = endpoint.validateResponse(httpResponse) {
                        completion(Result.failure(validationError))
                        return
                    }
                    
                    guard let data: Data = response.data else {
                        completion(Result.failure(NetworkError(errorType: .missingData)))
                        return
                    }
                    
                    let statusCode = httpResponse.statusCode
                     completion(Result.success((data, statusCode)))
                    return
                }
            }
        }
        
        dispatchQueueForQoS(QoS).async(execute: item)
        
        return DispatchWorkItemSubscription(item: item)
    }
    
    private func performWrappedApi<T: CustomDecodable>(_ request: APIRequest<T>, QoS: QualityOfService, completionQueue: DispatchQueue, completion: @escaping (Result<APIResponseWrapper<T>, NSError>) -> Void) -> APISubscriptionProtocol {
        return connectTo(request, QoS: QoS) { (result: Result<(Data, Int), NSError>) in
            switch result{
            case .success(let tuple):
                guard let obj: T = T.decode(tuple.0) as? T else {
                    completionQueue.async {
                        completion(Result.failure(NetworkError(errorType: .parserError)))
                    }
                    return
                }
                
                if let error = request.validateResponseObject(obj) {
                    completionQueue.async {
                        completion(Result.failure(error))
                    }
                    return
                }
                
                completionQueue.async {
                    completion(Result.success(APIResponseWrapper(object: obj, statusCode: tuple.1)))
                }
                
            case .failure(let error):
                completionQueue.async {
                    completion(Result.failure(error))
                }
                
            }
        }
    }
    
    //MARK: - Public Functions
    public func performApi<T: CustomDecodable>(_ request: APIRequest<T>, QoS: QualityOfService, completionQueue: DispatchQueue = DispatchQueue.main, completion: @escaping (Result<T, NSError>) -> Void) -> APISubscriptionProtocol {
        
        return performWrappedApi(request, QoS: QoS, completionQueue: completionQueue) { (result: Result<APIResponseWrapper<T>, NSError>) in
            
            switch result {
            case .failure(let error):
                completion(Result.failure(error))
            case .success(let w):
                completion(Result.success(w.object))
            }
        }
    }
}
