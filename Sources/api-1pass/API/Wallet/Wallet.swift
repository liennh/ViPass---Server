//
//  Wallet.swift
//  api-1pass
//
//  Created by Ngo Lien on 7/14/18.
//

import Foundation

class Wallet: NSObject {
    public static func createNewWallet(params: [String: Any]!) -> (Bool, Any) {
        // Extract params
        var username = params[Keys.i] as! String
        username = username.lowercased()
        //let M = params[Keys.M] as! [UInt8]  // Work on Mac. But not on Linux
        let enc_password = (params[Keys.enc_password] as? [Any])?.bytes
        guard enc_password != nil else {
            return (false, ErrorMsg.please_supply_values)
        }
        
        let enc_priv = (params[Keys.enc_priv] as? [Any])?.bytes
        guard enc_priv != nil else {
            return (false, ErrorMsg.please_supply_values)
        }
        
        // Fetch user's session key
        let (found, result) = Auth.fetchSessionKey(username: username)
        guard found else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        
        let ssk = (result as? [Any])?.bytes
        let dec_password = AppEncryptor.decryptAES256(cipheredBytes: enc_password!, key: ssk!)
        guard dec_password != nil else {
            return (false, ErrorMsg.invalid_session_key)
        }
        let password = Data(bytes: dec_password!).toString()
        
        let dec_priv = AppEncryptor.decryptAES256(cipheredBytes: enc_priv!, key: ssk!)
        guard dec_priv != nil else {
            return (false, ErrorMsg.invalid_session_key)
        }
        let priv = Data(bytes: dec_priv!).toString()
        
       return WalletAPI.createNewWallet(walletPassword: password, walletPriv: priv)
       
    }
}// class
