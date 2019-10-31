//
//  Authentication.swift
//  api-1pass
//
//  Created by Ngo Lien on 5/14/18.
//

import Foundation
import BigInt

class Login: NSObject {
    
    public static func doFirstStep(params: [String: Any]!) -> (Bool, Any) {
        // Extract params
        var username = params[Keys.i] as! String
        username = username.lowercased()
        //let A = params[Keys.A] as! [UInt8]  // Work on Mac. But not on Linux
        let A = (params[Keys.A] as? [Any])?.bytes
        guard A != nil else {
            return (false, ErrorMsg.please_supply_values)
        }
        
        // Fetch s(salt), v(verifier) of User
        let (found, result) = Auth.fetchSaltVerifier(username: username)
        guard found else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        let (sVal, vVal) = result as! ([Any], [Any])
        // Fix bug Cast Type Int: Work on Mac. But not on Linux
        let s = sVal.bytes

        // Fix bug Cast Type Int: Work on Mac. But not on Linux
        let v = vVal.bytes
        
        let salt = Data(bytes: s)
        let verifier = Data(bytes: v)
        
        // Init SRP server
        let server = Server(
            username: username,
            salt: salt,
            verificationKey: verifier)
        
        // The server shares Alice's salt and its public key (the challenge).
        let (_, B) = server.getChallenge()
        
        // Save A, B, b to Database temporarily for calculating server M1, M2 later
        let tempData = [Keys.A: A,
                     Keys.b: server.b.serialize().bytes,
                     Keys.B: B.bytes]
        let (updated, msg) = Auth.updateUser(username: username, changes: tempData)
        guard updated else {
            return (false, msg)
        }
        return (true, [Keys.B: B.bytes, Keys.s: s])
    }// func doFirstStep
    
    public static func doLastStep(params: [String: Any]!) -> (Bool, Any) {
        // Extract params
        var username = params[Keys.i] as! String
        username = username.lowercased()
        //let M = params[Keys.M] as! [UInt8]  // Work on Mac. But not on Linux
        let M = (params[Keys.M] as? [Any])?.bytes
        guard M != nil else {
            return (false, ErrorMsg.please_supply_values)
        }
        
        // Fetch user credentials: A, B, b, s, v, pubKey, enc_ak, enc_pk
        let (found, result) = Auth.fetchUserCredentials(username: username)
        guard found else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        let attrs = result as! [String:Any]
        let A = (attrs[Keys.A] as? [Any])?.bytes
        let B = (attrs[Keys.B] as? [Any])?.bytes
        let b = (attrs[Keys.b] as? [Any])?.bytes
        let s = (attrs[Keys.s] as? [Any])?.bytes
        let v = (attrs[Keys.v] as? [Any])?.bytes
        
        let salt = Data(bytes: s!)
        let verifier = Data(bytes: v!)
        
        // Init SRP server
        let server = Server(
            username: username,
            salt: salt,
            verificationKey: verifier)
        
        server.b = BigUInt(Data(bytes: b!))
        server.B = BigUInt(Data(bytes: B!))
        
        let (ok, HAMKorError) = server.verifySession(publicKey: Data(bytes: A!), keyProof: Data(bytes: M!))
        guard ok else {
            return (false, HAMKorError) // error
        }
        
//        let pubKey = (attrs[Keys.pubKey] as? [Any])?.bytes
//        let enc_pk = (attrs[Keys.enc_pk] as? [Any])?.bytes
        let enc_ak = (attrs[Keys.enc_ak] as? [Any])?.bytes
        let HAMK = (HAMKorError as! Data).bytes
        let ssk = AppEncryptor.getSessionKey(bytes: (server.sessionKey?.bytes)!) // 32 bytes session key
        
        // Remove A, B, b in Database. Save session key (K) to database
        let updateData = [Keys.A: [],
                        Keys.b: [],
                        Keys.B: [],
                        Keys.K: ssk
        ]
        let (updated, msg) = Auth.updateUser(username: username, changes: updateData)
        guard updated else {
            return (false, msg)
        }
        var dict:[String:Any] = [
            Keys.enc_ak: enc_ak!,
//                    Keys.pubKey: pubKey,
//                    Keys.enc_pk: enc_pk,
                    Keys.HAMK: HAMK]
        
        let (isOK, accountStatus) = User.fetchUserAccountStatus(username: username)
        if isOK {
            let (accountType, expiredAt) = accountStatus as! (Int, String)
            dict[Keys.accountType] = accountType
            dict[Keys.expiredAt] = expiredAt
        }
        
        return (true, dict)
    }// func doLastStep

}// class Login


