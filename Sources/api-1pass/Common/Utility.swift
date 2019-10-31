//
//  Utility.swift
//  api-1pass
//
//  Created by Ngo Lien on 5/15/18.
//

import Foundation

// Base class that is then extended by individual helper functions
public class Utility {
}

public class Utils:NSObject {
    public static func arrayFrom(jsonData:Data) -> [Any] {
        if let array =  try? JSONSerialization.jsonObject(with: jsonData, options: []) {
            return array as! [Any]
        }
        
        return []
    }
}
