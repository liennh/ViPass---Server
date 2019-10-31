//
//  User.swift
//  api-1pass
//
//  Created by Ngo Lien on 7/7/18.
//

import Foundation

class User:NSObject {
    
    /*
     let params = [Keys.i: username,
     Keys.enc_ak: encAccountKey, // encrypted by aesMasterKey
     Keys.enc_pk: encPrivateKey, // encrypted by aesMasterKey
     Keys.enc_s: encSalt, // encrypted by Session Key
     Keys.enc_v: encVerifier // encrypted by Session Key
     ] as [String: Any]
     */
    public static func changePassword(params: [String: Any]!) -> (Bool, String) {
        // Extract params
        var username = params[Keys.i] as! String
        username = username.lowercased()
        //let M = params[Keys.M] as! [UInt8]  // Work on Mac. But not on Linux
        let enc_ak = (params[Keys.enc_ak] as? [Any])?.bytes
        guard enc_ak != nil else {
            return (false, ErrorMsg.invalid_parameters)
        }
        
       /* let enc_pk = (params[Keys.enc_pk] as? [Any])?.bytes
        guard enc_pk != nil else {
            return (false, ErrorMsg.invalid_parameters)
        }*/
        
        let enc_salt = (params[Keys.enc_s] as? [Any])?.bytes
        guard enc_salt != nil else {
            return (false, ErrorMsg.invalid_parameters)
        }
        
        let enc_verifier = (params[Keys.enc_v] as? [Any])?.bytes
        guard enc_verifier != nil else {
            return (false, ErrorMsg.invalid_parameters)
        }
        
        // Fetch user's session key
        let (found, result) = Auth.fetchSessionKey(username: username)
        guard found else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        
        let ssk = (result as? [Any])?.bytes
        let salt = AppEncryptor.decryptAES256(cipheredBytes: enc_salt!, key: ssk!)
        guard salt != nil else {
            return (false, ErrorMsg.invalid_session_key)
        }
        let verifier = AppEncryptor.decryptAES256(cipheredBytes: enc_verifier!, key: ssk!)
        guard verifier != nil else {
            return (false, ErrorMsg.invalid_session_key)
        }
        var userAttrs = [String:Any]()
        userAttrs[Keys.s] = salt
        userAttrs[Keys.v] = verifier
        userAttrs[Keys.enc_ak] = enc_ak
        //userAttrs[Keys.enc_pk] = enc_pk
        
        return Auth.updateUser(username: username, changes: userAttrs)
    }
    
    // Return (true, (accountType, expiredAt)) or (false, "error msg")
    public static func fetchUserAccountStatus(username:String) -> (Bool, Any) {
        let url = ELASTIC_SEARCH.BASE_URL + "user/default/" + username + "?_source=*.id," + Keys.accountType + "," + Keys.expiredAt + ",/"
        let result = Utility.makeRequest(.get, url)
        let exists = result["found"] ?? false
        
        guard (exists as! Bool) else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        
        let attrs = result["_source"] as! [String:Any]
        let accountType = attrs[Keys.accountType]
        let expiredAt = attrs[Keys.expiredAt]
        
        return (true, (accountType, expiredAt))
    }
    
    /*
     let params = [Keys.i: username,
     Keys.enc_expiredAt: enc_expiredAt // encrypted Date String
     ] as [String: Any]
     */
    public static func updateSubscriptionExpiredAt(params: [String: Any]!) -> (Bool, String) {
        // Extract params
        var username = params[Keys.i] as! String
        username = username.lowercased()
        //let M = params[Keys.M] as! [UInt8]  // Work on Mac. But not on Linux
        let enc_expiredAt = (params[Keys.enc_expiredAt] as? [Any])?.bytes
        guard enc_expiredAt != nil else {
            return (false, ErrorMsg.invalid_parameters)
        }
        
        // Fetch user's session key
        let (found, result) = Auth.fetchSessionKey(username: username)
        guard found else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        
        let ssk = (result as? [Any])?.bytes
        let expiredAt = AppEncryptor.decryptAES256(cipheredBytes: enc_expiredAt!, key: ssk!)
        guard expiredAt != nil else {
            return (false, ErrorMsg.invalid_session_key)
        }
        
        // yyyy-MM-dd'T'HH:mm:ssZZ
        // 2018-06-09T09:06:51+0000
        let dateString = (Data(bytes: expiredAt!)).toString()
        
        var userAttrs = [String:Any]()
        userAttrs[Keys.accountType] = AccountType.premium.rawValue
        userAttrs[Keys.expiredAt] = dateString
        
        return Auth.updateUser(username: username, changes: userAttrs)
    }
    
}// class
