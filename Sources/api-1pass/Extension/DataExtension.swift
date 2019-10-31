//
//  File.swift
//  api-1pass
//
//  Created by Ngo Lien on 5/15/18.
//

import Foundation
extension Data {
    func toString() -> String {
        return String(data: self, encoding: .utf8)!
    }
    
    // comment because redeclare or dulicate with CryptoSwift-0.10.0 Data extension
    var bytes : [UInt8] {
        return [UInt8](self)
    }
    
    // Input string is json string
    func toArray() -> [[String:Any]] {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            return json as! [[String:Any]]
        } catch {
            print("Something went wrong")
            return []
        }
    }
}

