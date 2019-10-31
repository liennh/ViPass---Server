//
//  Constant.swift
//  api-1pass
//
//  Created by Ngo Lien on 5/14/18.
//

import Foundation

let Production = false

/***************  Closure  ***************/
/*public typealias  APICompletion = (_ succeeded: Bool, _ data: Any?) -> Void
public typealias  IdResultBlock = (_ result: Any?, _ error: Error?) -> Void
public typealias  DataBlock = (_ data: Data?, _ error: Error?) -> Void
public typealias  VoidBlock = () -> Void



struct Constant {
    static let Button_Corner_Radius:CGFloat = 4.0
}

struct Noti {
    static let Add_New_Field:String = "Add_New_Field"
    static let Delete_Field:String = "Delete_Field"
    static let Delete_Record:String = "Delete_Record"
    static let Update_Record:String = "Update_Record"
    static let Add_Record:String = "Add_Record"
}*/

enum AccountType:Int {
    case free_trial = 0
    case premium
}

class AppConfig {
    static let SpecialChars = "!@#$%^&*()_-=+{}['~`]|;:,./?><"
    static let DateTimeFormat = "yyyy-MM-dd'T'HH:mm:ssZZ" // "yyyy-MM-dd HH:mm:ss" 
    static let Max_Items_Per_Upload_Request = 100
    static let Max_Items_Per_Download_Request = 100
    static let api_Key_value = "xvEuQ2WbF2QAb9AjOiBr1HSCa1GjkqU0" // Don't change it
    static let wallet_server = "http://localhost:3000/api/v2/"
    static let wallet_api_code = "21b62c26-87a7-4b83-85ab-404332bdf287"
    static let freeTrialPeriod = 30 // days
}

struct ELASTIC_SEARCH {
    #if Production
    static let BASE_URL = "http://elasticsearch.1pass.vn:9200/"
    #else
    static let BASE_URL = "http://localhost:9200/"
    #endif
}

struct ErrorMsg {
    static let invalid_request = "invalid_request"
    static let invalid_session_key = "Invalid session key."
    static let user_does_not_exist = "User does not exist."
    static let please_supply_values = "Please supply values."
    static let invalid_parameters = "Invalid parameters."
}

struct APIs {
    //static let getRecordByID = "getRecordByID"   // not used
    //static let updateRecord = "updateRecord"    // not used
    //static let insertRecord = "insertRecord"     // not used
    static let signUp = "signUp"
    static let loginFirstStep = "loginFirstStep"
    static let loginLastStep = "loginLastStep"
    static let getLatestRecordChanges = "getLatestRecordChanges"
    static let deleteBulkRecords = "deleteBulkRecords"
    static let uploadNotSyncedRecords = "uploadNotSyncedRecords"
    static let updateBulkRecords = "updateBulkRecords"
    static let changeUserPassword = "changeUserPassword"
    static let createNewWallet = "createNewWallet"
    static let checkUserExists = "checkUserExists"
    static let updateSubscriptionExpiredAt = "updateSubscriptionExpiredAt"
    static let getSubscriptionExpiredAt = "getSubscriptionExpiredAt"
}

struct Keys {
    static let api_Key = "api-Key"
    static let status = "status"
    static let error = "error"
    static let index = "index"
    static let record = "record"
    static let s = "s" // salt
    static let v = "v" // verifier
    static let iv = "iv"
    static let authTag = "authTag"
    static let data = "data"
    static let aad = "aad"
    static let i = "i"
    static let A = "A"
    static let a = "a" // client private key
    static let B = "B"
    static let b = "b" // server private key
    static let K = "K" // Session Key
    static let M = "M"
    static let HAMK = "HAMK" // M2 message in SRP
    static let enc_ak = "enc_ak" // encrypted user account key
    //static let pubKey = "pubKey" // user public key
    //static let enc_pk = "enc_pk" // encrypted user private key
    //static let enc_sv = "enc_sv" // encrypted Salt + Verifier
    static let enc_ssk = "enc_ssk" // encrypted session key
    static let credentials = "credentials"
    static let secretKey = "secretKey" // Random UUID. stored in Keychain
    static let ts = "ts" // Date or timestamp used for syncing with server
    static let listRecords = "listRecords"
    static let bulkRecords = "bulkRecords"
    static let recordID = "recordID"
    static let enc_s = "enc_s" // Encrypted salt.
    static let enc_v = "enc_v" // Encrypted verifier
    static let exist = "exist" // Used for check if user exist
    
    // Bitcoin Wallet
    static let enc_password = "enc_password" // The password for the new wallet. Must be at least 10 characters in length.
    static let enc_priv = "enc_priv" // A private key to add to the wallet (optional)
    static let accountType = "accountType" // free_trial or premium
    static let expiredAt = "expiredAt"
    static let enc_expiredAt = "enc_expiredAt"
    static let user_accounting = "user_accounting"
}

