//
//  DictionaryExtension.swift
//  api-1pass
//
//  Created by Ngo Lien on 5/22/18.
//

import Foundation

extension Dictionary {
    var json: String {
        let invalidJson = "" //"Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
}
