//
//  ViPassEncryptor.swift
//  ViPass
//
//  Created by Ngo Lien on 5/16/18.
//  Copyright © 2018 Ngo Lien. All rights reserved.
//

import Foundation
import CryptoSwift

class AppEncryptor: NSObject {
    public class func getSessionKey(bytes: [UInt8]) -> [UInt8] {
        // Generate sessionKey from 20 bytes in SRP.
        let sessionKey = try! PKCS5.PBKDF2(password: bytes, salt: bytes, iterations: 1, variant: .sha256).calculate()
        
        return sessionKey // 32 in length
    }
    
    public class func getMasterKey(password: String, secretKey: String) -> [UInt8]? {
        let secretBytes = secretKey.toData().bytes
        let thePassword = password.toData().bytes + secretBytes
        // Generate aesMasterKey from Master Password + Hash of Private Key
        let aesMasterKey = try? PKCS5.PBKDF2(password: thePassword, salt: secretBytes, iterations: 4096, variant: .sha256).calculate()
        
        return aesMasterKey
    }
    
    /*
     key: Must 32 in length.
     algorithsm: AES-256 CBC mode
     return Plain data or nil, if there is an error
     */
    public class func decryptAES256(cipheredBytes: [UInt8], key: [UInt8]) -> [UInt8]? {
        let iv = Array(cipheredBytes[0..<16])
        let encrypted = Array(cipheredBytes[16..<(cipheredBytes.count)])
        do {
            let cbc = CBC(iv: iv)
            let aes = try AES(key: key, blockMode: cbc, padding: .pkcs5)
            let decrypted = try aes.decrypt(encrypted)
            guard decrypted.count < encrypted.count  else {
                return nil
            }
            return decrypted
        } catch {
            return nil
        }
        
        /*let iv = Array(cipheredBytes[0..<12])
         let encrypted = Array(cipheredBytes[12..<(cipheredBytes.count)])
         do {
         let decGCM = GCM(iv: iv, mode: .combined)
         let aes = try AES(key: key, blockMode: decGCM, padding: .noPadding)
         return try aes.decrypt(encrypted)
         } catch {
         return nil
         }*/
    }
}

