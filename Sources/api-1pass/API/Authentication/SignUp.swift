//
//  Signup.swift
//  api-1pass
//
//  Created by Ngo Lien on 5/24/18.
//

import Foundation
import BigInt

class SignUp: NSObject {

    /*
 let params = [Keys.i: username,
 Keys.A: A, // Client Public Key
 Keys.pubKey: publicKey, // User Public Key. Used for adding to TEAM
 Keys.enc_ak: encAccountKey, // Used to protect User Data
 Keys.enc_pk: encPrivateKey, // User Private Key. Used to protect TEAM Key
 Keys.enc_sv: encSaltVerifier // Used for SRC Auth
 ] as [String: Any]
 */
    public static func start(params: [String: Any]!) -> (Bool, Any) {
        var userAttrs = params
        // Extract params
        var username = params[Keys.i] as! String
        username = username.lowercased()
        //let A = params[Keys.A] as! [UInt8]  // Work on Mac. But not on Linux
        let A = (params[Keys.A] as? [Any])?.bytes
        guard A != nil else {
            return (false, ErrorMsg.please_supply_values)
        }
        
        let s = (params[Keys.s] as? [Any])?.bytes
        guard s != nil else {
            return (false, ErrorMsg.please_supply_values)
        }
        
        let v = (params[Keys.v] as? [Any])?.bytes
        guard v != nil else {
            return (false, ErrorMsg.please_supply_values)
        }
        
        //let encSaltVerifier = params[Keys.enc_sv] as! [UInt8]     // Work on Mac. But not on Linux
        /*let encSaltVerifier = (params[Keys.enc_sv] as? [Any])?.bytes
        guard encSaltVerifier != nil else {
            return (false, ErrorMsg.please_supply_values)
        }*/
        
        //userAttrs?.removeValue(forKey: Keys.enc_sv)
        userAttrs?.removeValue(forKey: Keys.A)
        userAttrs?.removeValue(forKey: Keys.i)

        if Auth.checkIfExists(username: username) {
            return (false, "Username exists already.")
        }
        /****** Continue SignUp Flow *******/

        // Decrypt RSA of Salt + Verifier
//        guard let privateKey = try? RSA.Key(fromPEMPrivateKey: Singleton.shared.privateKey) else {
//            return (false, "Cannot decrypt Salt + Verifier")
//        }

       /* guard let sv = try? RSA.decrypt(data: Data(bytes: encSaltVerifier!), withKey: privateKey, usingCipher: .aes_256_cbc) else {
            return (false, "Cannot decrypt Salt + Verifier")
        }
        
        let svBytes = sv.bytes
        let salt = Data(bytes: svBytes[0..<256])
        let verifier = Data(bytes: svBytes[256..<sv.count])
        userAttrs![Keys.s] = salt.bytes
        userAttrs![Keys.v] = verifier.bytes
        */

        // Init SRP server
        let server = Server(
            username: username,
            salt: Data(bytes: s!),
            verificationKey: Data(bytes: v!))

        // The server shares Alice's salt and its public key (the challenge).
        let (_, B) = server.getChallenge()

        // Calculate Session Key
        let (ok, KorError) = server.calculateSessionKey(clientPublicKey: Data(bytes: A!))
        if !ok {
            return (false, KorError)
        } else {
            // Update session key
            let bytes = (KorError as? [Any])?.bytes
            let ssk = AppEncryptor.getSessionKey(bytes: bytes!)
            userAttrs![Keys.K] = ssk // session key in bytes
        }
        // Init Free Trial period
        let today = Date()
        let freeTrialPeriod = AppConfig.freeTrialPeriod // days
        let expirationDate = Calendar.current.date(byAdding: .day, value: freeTrialPeriod, to: today)
        userAttrs![Keys.expiredAt] = expirationDate?.utcString() ?? today.utcString()
        userAttrs![Keys.accountType] = AccountType.free_trial.rawValue // free_trial
        
        // Create new user if not exists
        let (created, message) = Auth.createNewUser(username: username, attrs: userAttrs!)
        if !created {
            return (false, message)
        }
        return (true, B.bytes)
    }// func start

}// class SignUp
