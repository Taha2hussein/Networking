//
//  ResponseProtocols.swift
//  
//
//  Created by Taha Hussein on 23/05/2023.
//

import Foundation
public protocol CustomDecodable: Decodable {
    static func decode(_ data: Data) -> CustomDecodable?
}
