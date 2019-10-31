//
//  Record.swift
//  api-1pass
//
//  Created by Ngo Lien on 6/8/18.
//

import Foundation

class Record:NSObject {
    /*public static func getRecordByID(params: [String: Any]!) -> (Bool, Any) {
        // Extract params
        var username = params[Keys.i] as! String
        username = username.lowercased()
        //let M = params[Keys.M] as! [UInt8]  // Work on Mac. But not on Linux
        let enc_recordID = (params[Keys.recordID] as? [Any])?.bytes
         guard enc_recordID != nil else {
            return (false, ErrorMsg.please_supply_values)
         }
     
        // Fetch user's session key
        let (found, result) = Auth.fetchSessionKey(username: username)
        guard found else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        
        let ssk = (result as? [Any])?.bytes
        let decrypted = AppEncryptor.decryptAES256(cipheredBytes: enc_recordID!, key: ssk!)
        guard decrypted != nil else {
            return (false, ErrorMsg.invalid_session_key)
        }
        let recordID = (Data(bytes: decrypted!)).toString()
        return DB.getRecord(id:recordID)
    }// func getRecordByID
    */
    
   /* public static func insertRecord(params: [String: Any]!) -> (Bool, Any) {
        // Extract params
        var username = params[Keys.i] as! String
        username = username.lowercased()
        //let M = params[Keys.M] as! [UInt8]  // Work on Mac. But not on Linux
        let enc_record = (params[Keys.record] as? [Any])?.bytes
         guard enc_record != nil else {
            return (false, ErrorMsg.please_supply_values)
         }
     
        // Fetch user's session key
        let (found, result) = Auth.fetchSessionKey(username: username)
        guard found else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        
        let ssk = (result as? [Any])?.bytes
        let decrypted = AppEncryptor.decryptAES256(cipheredBytes: enc_record!, key: ssk!)
        guard decrypted != nil else {
            return (false, ErrorMsg.invalid_session_key)
        }
        let recordData = Data(bytes: decrypted!)
        let recordDict = try! JSONSerialization.jsonObject(with: recordData, options: []) as! [String: Any]
        let recordId = recordDict["id"] as! String
        return DB.createNewRecord(uuid:recordId, attrs: recordDict)
    }// func insertRecord
 
 */
    
    /*public static func updateRecord(params: [String: Any]!) -> (Bool, String) {
        // Extract params
        var username = params[Keys.i] as! String
        username = username.lowercased()
        //let M = params[Keys.M] as! [UInt8]  // Work on Mac. But not on Linux
        let enc_record = (params[Keys.record] as? [Any])?.bytes
         guard enc_record != nil else {
            return (false, ErrorMsg.please_supply_values)
         }
        
        // Fetch user's session key
        let (found, result) = Auth.fetchSessionKey(username: username)
        guard found else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        
        let ssk = (result as? [Any])?.bytes
        let decrypted = AppEncryptor.decryptAES256(cipheredBytes: enc_record!, key: ssk!)
        guard decrypted != nil else {
            return (false, ErrorMsg.invalid_session_key)
        }
        let recordData = Data(bytes: decrypted!)
        let recordDict = try! JSONSerialization.jsonObject(with: recordData, options: []) as! [String: Any]
        let recordId = recordDict["id"] as! String
        return DB.updateRecord(uuid:recordId, changes: recordDict)
    }// func updateRecord
    */
    
    public static func deleteBulkRecords(params: [String: Any]!) -> (Bool, Any) {
        // Extract params
        var username = params[Keys.i] as! String
        username = username.lowercased()
        //let M = params[Keys.M] as! [UInt8]  // Work on Mac. But not on Linux
        let enc_bulk_records = (params[Keys.bulkRecords] as? [Any])?.bytes
        guard enc_bulk_records != nil else {
            return (false, ErrorMsg.please_supply_values)
        }
        
        // Fetch user's session key
        let (found, result) = Auth.fetchSessionKey(username: username)
        guard found else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        
        let ssk = (result as? [Any])?.bytes
        let decrypted = AppEncryptor.decryptAES256(cipheredBytes: enc_bulk_records!, key: ssk!)
        guard decrypted != nil else {
            return (false, ErrorMsg.invalid_session_key)
        }
        let data = Data(bytes: decrypted!)
        let bulkRecords = Utils.arrayFrom(jsonData: data)
        guard !bulkRecords.isEmpty else {
            return (false, ErrorMsg.invalid_parameters)
        }
        DB.deleteRecords(bulk: bulkRecords, username: username)
        return (true, "Deleted Them.")
    }// func deleteBulkRecords
    
    public static func getLatestRecordChanges(params: [String: Any]!) -> (Bool, Any) {
        // Extract params
        var username = params[Keys.i] as! String
        username = username.lowercased()
        //let M = params[Keys.M] as! [UInt8]  // Work on Mac. But not on Linux
        let enc_sinceTs = (params[Keys.ts] as? [Any])?.bytes
        guard enc_sinceTs != nil else {
            return (false, ErrorMsg.please_supply_values)
        }
        
        // Fetch user's session key
        let (found, result) = Auth.fetchSessionKey(username: username)
        guard found else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        
        let ssk = (result as? [Any])?.bytes
        let decrypted = AppEncryptor.decryptAES256(cipheredBytes: enc_sinceTs!, key: ssk!)
        guard decrypted != nil else {
            return (false, ErrorMsg.invalid_session_key)
        }
        
        // yyyy-MM-dd'T'HH:mm:ssZZ
        // 2018-06-09T09:06:51+0000
        let dateString = (Data(bytes: decrypted!)).toString()
        return (true, DB.getLatestRecordChanges(sinceTs:dateString, username: username))
    }// func getLatestRecordChanges
    
    public static func uploadNotSyncedRecords(params: [String: Any]!) -> (Bool, Any) {
        // Extract params
        var username = params[Keys.i] as! String
        username = username.lowercased()
        //let M = params[Keys.M] as! [UInt8]  // Work on Mac. But not on Linux
        let enc_bulk_records = (params[Keys.bulkRecords] as? [Any])?.bytes
        guard enc_bulk_records != nil else {
            return (false, ErrorMsg.please_supply_values)
        }
        
        // Fetch user's session key
        let (found, result) = Auth.fetchSessionKey(username: username)
        guard found else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        
        let ssk = (result as? [Any])?.bytes
        let decrypted = AppEncryptor.decryptAES256(cipheredBytes: enc_bulk_records!, key: ssk!)
        guard decrypted != nil else {
            return (false, ErrorMsg.invalid_session_key)
        }
        let data = Data(bytes: decrypted!)
        let bulkRecords = Utils.arrayFrom(jsonData: data)
        guard !bulkRecords.isEmpty else {
            return (false, ErrorMsg.invalid_parameters)
        }
        DB.createRecords(bulk:bulkRecords, username: username)
        return (true, "Upload Done.")
    }// func uploadNotSyncedRecords
    
    public static func updateBulkRecords(params: [String: Any]!) -> (Bool, Any) {
        // Extract params
        var username = params[Keys.i] as! String
        username = username.lowercased()
        //let M = params[Keys.M] as! [UInt8]  // Work on Mac. But not on Linux
        let enc_bulk_records = (params[Keys.bulkRecords] as? [Any])?.bytes
        guard enc_bulk_records != nil else {
            return (false, ErrorMsg.please_supply_values)
        }
        
        // Fetch user's session key
        let (found, result) = Auth.fetchSessionKey(username: username)
        guard found else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        
        let ssk = (result as? [Any])?.bytes
        let decrypted = AppEncryptor.decryptAES256(cipheredBytes: enc_bulk_records!, key: ssk!)
        guard decrypted != nil else {
            return (false, ErrorMsg.invalid_session_key)
        }
        let data = Data(bytes: decrypted!)
        let bulkRecords = Utils.arrayFrom(jsonData: data)
        guard !bulkRecords.isEmpty else {
            return (false, ErrorMsg.invalid_parameters)
        }
        DB.updateRecords(bulk:bulkRecords, username: username)
        return (true, "Update Done.")
    }// func uploadNotSyncedRecords
    
}// class
