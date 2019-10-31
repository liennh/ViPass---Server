//
//  ArrayExtension.swift
//  api-1pass
//
//  Created by Ngo Lien on 5/24/18.
//

import Foundation

extension Array where Element == UInt8 {
    var data : Data{
        return Data(bytes:(self))
    }
}

extension Array where Element == Any {
    var bytes: [UInt8] {
        // Fix bug Cast Type Int: Work on Mac. But not on Linux
        var result = [UInt8]()
        for i in 0..<self.count {
            let val = UInt8("\(self[i])")
            result.append(val!)
        }
        return result
    }
}
