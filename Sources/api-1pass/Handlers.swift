//
//  Handlers.swift
//  api-1pass
//
//  Created by Ngo Lien on 5/14/18.
//
// Refer to https://github.com/PerfectExamples/PerfectArcade/blob/master/Sources/Handlers.swift

import Foundation
import PerfectHTTP

class Handlers: NSObject {
    public static func returnToClient(result: [String: Any], _ response: HTTPResponse) {
        do {
            try response.setBody(json: result)
        } catch {
            print(error)
        }
        response.completed()
    }
    /*
     Params: username, A(client public key), user public key, encrypted user private key, encrypted account key, encrypted RSA of salt+verifier
     Return: B so that client can calculate its K(session key)
    */
    public static func signUp(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func signUp")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()

        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary() else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
        
        let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
        guard let api_Key = request.header(headerName),
            api_Key == AppConfig.api_Key_value else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.invalid_request
                Handlers.returnToClient(result: resp, response)
                return
        }
       
        guard let _ = inputParams[Keys.i] as? String,
            let _ = inputParams[Keys.A],
//            let _ = inputParams[Keys.pubKey],
//            let _ = inputParams[Keys.enc_pk],
//            let _ = inputParams[Keys.enc_sv],
            let _ = inputParams[Keys.enc_ak],
            let _ = inputParams[Keys.s],
            let _ = inputParams[Keys.v] else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }

        let (status, result) = SignUp.start(params: inputParams)
        resp[Keys.status] = status
        if status == true {
            resp[Keys.B] = result // B in bytes
        } else {
            resp[Keys.error] = result
        }
        
        print("Finish func signUp")
        Handlers.returnToClient(result: resp, response)
    }// func signUp

    /*
     Params: username, A(client public key)
     Return: s(salt), B(server public key)
    */
    public static func loginFirstStep(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func loginFirstStep")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()
        
        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary() else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
        
        let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
        guard let api_Key = request.header(headerName),
            api_Key == AppConfig.api_Key_value else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.invalid_request
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        guard let _ = inputParams[Keys.i] as? String,
            let _ = inputParams[Keys.A] else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        let (status, result) = Login.doFirstStep(params:inputParams)
        
        if status == true {
            resp = result as! [String: Any] // s, B in bytes
            resp[Keys.status] = status
        } else {
            resp[Keys.status] = status
            resp[Keys.error] = result
        }
        print("Finish func loginFirstStep")
        Handlers.returnToClient(result: resp, response)
    }// func loginFirstStep
    
    /*
     Params: username, M(client Message)
     Return: HAMK, pubKey, enc_ak, enc_pk
     */
    public static func loginLastStep(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func loginLastStep")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()
        
        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary() else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
        
        let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
        guard let api_Key = request.header(headerName),
            api_Key == AppConfig.api_Key_value else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.invalid_request
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        guard let _ = inputParams[Keys.i] as? String,
            let _ = inputParams[Keys.M] else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        let (status, result) = Login.doLastStep(params:inputParams)
        resp[Keys.status] = status
        if status == true {
            resp[Keys.credentials] = result // [String:Any]
        } else {
            resp[Keys.error] = result
        }
        
        print("Finish func loginLastStep")
        Handlers.returnToClient(result: resp, response)
    }
    
    /*
     Params: username, enc_recordID
     Return: Record info
     */
    /*public static func getRecordByID(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func getRecordByID")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()
        
        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary()  else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
     
         let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
         guard let api_Key = request.header(headerName),
         api_Key == AppConfig.api_Key_value else {
         // set an error response to be returned
         response.status = .badRequest
         resp[Keys.error] = ErrorMsg.invalid_request
         Handlers.returnToClient(result: resp, response)
         return
         }
        guard let _ = inputParams[Keys.i] as? String,
            let _ = inputParams[Keys.recordID] else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        let (status, result) = Record.getRecordByID(params: inputParams)
        resp[Keys.status] = status
        if status == true {
            resp[Keys.record] = result // [String:Any]
        } else {
            resp[Keys.error] = result
        }
        print("Finish func getRecordByID")
        Handlers.returnToClient(result: resp, response)
    }*/
    
    /*
     Params: username, enc_record
     Return: inserted record
     */
    /*public static func insertRecord(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func insertRecord")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()
        
        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary()  else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
     
         let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
         guard let api_Key = request.header(headerName),
         api_Key == AppConfig.api_Key_value else {
         // set an error response to be returned
         response.status = .badRequest
         resp[Keys.error] = ErrorMsg.invalid_request
         Handlers.returnToClient(result: resp, response)
         return
         }
        
        guard let _ = inputParams[Keys.i] as? String,
            let _ = inputParams[Keys.record] else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        let (status, result) = Record.insertRecord(params: inputParams)
        resp[Keys.status] = status
        if status == false {
            resp[Keys.error] = result // String
        }
        print("Finish func insertRecord")
        Handlers.returnToClient(result: resp, response)
    }
    */
    
    /*
     Params: username, enc_record
     Return: updated record
     */
    /*public static func updateRecord(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func updateRecord")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()
        
        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary()  else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
     
     let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
     guard let api_Key = request.header(headerName),
     api_Key == AppConfig.api_Key_value else {
     // set an error response to be returned
     response.status = .badRequest
     resp[Keys.error] = ErrorMsg.invalid_request
     Handlers.returnToClient(result: resp, response)
     return
     }
        
        guard let _ = inputParams[Keys.i] as? String,
            let _ = inputParams[Keys.record] else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        let (status, result) = Record.updateRecord(params: inputParams)
        resp[Keys.status] = status
        if status == false {
            resp[Keys.error] = result // String
        }
        print("Finish func updateRecord")
        Handlers.returnToClient(result: resp, response)
    }*/
    
    /*
     Params: username, enc_ts
     Return: List of Record info
     */
    public static func getLatestRecordChanges(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func getLatestRecordChanges")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()
        
        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary()  else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
        
        let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
        guard let api_Key = request.header(headerName),
            api_Key == AppConfig.api_Key_value else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.invalid_request
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        guard let _ = inputParams[Keys.i] as? String,
            let _ = inputParams[Keys.ts] else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        let (status, result) = Record.getLatestRecordChanges(params: inputParams)
        resp[Keys.status] = status
        if status == true {
            resp[Keys.listRecords] = result // [[String:Any]]
        } else {
            resp[Keys.error] = result
        }
        print("Finish func getLatestRecordChanges")
        Handlers.returnToClient(result: resp, response)
    }
    
    /*
     Params: username, enc_bulk_records
     Return: inserted record
     */
    public static func uploadNotSyncedRecords(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func uploadNotSyncedRecords")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()
        
        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary()  else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
        
        let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
        guard let api_Key = request.header(headerName),
            api_Key == AppConfig.api_Key_value else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.invalid_request
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        guard let _ = inputParams[Keys.i] as? String,
            let _ = inputParams[Keys.bulkRecords] else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        let (status, result) = Record.uploadNotSyncedRecords(params: inputParams)
        resp[Keys.status] = status
        if status == false {
            resp[Keys.error] = result // String
        }
        print("Finish func uploadNotSyncedRecords")
        Handlers.returnToClient(result: resp, response)
    }
    
    /*
     Params: username, enc_bulk_records
     Return: deleted record
     */
    public static func deleteBulkRecords(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func deleteBulkRecords")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()
        
        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary()  else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
        
        let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
        guard let api_Key = request.header(headerName),
            api_Key == AppConfig.api_Key_value else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.invalid_request
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        guard let _ = inputParams[Keys.i] as? String,
            let _ = inputParams[Keys.bulkRecords] else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        let (status, result) = Record.deleteBulkRecords(params: inputParams)
        resp[Keys.status] = status
        if status == false {
            resp[Keys.error] = result // String
        }
        print("Finish func deleteBulkRecords")
        Handlers.returnToClient(result: resp, response)
    }
    
    /*
     Params: username, enc_bulk_records
     Return: updated record
     */
    public static func updateBulkRecords(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func updateBulkRecords")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()
        
        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary()  else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
        
        let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
        guard let api_Key = request.header(headerName),
            api_Key == AppConfig.api_Key_value else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.invalid_request
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        guard let _ = inputParams[Keys.i] as? String,
            let _ = inputParams[Keys.bulkRecords] else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        let (status, result) = Record.updateBulkRecords(params: inputParams)
        resp[Keys.status] = status
        if status == false {
            resp[Keys.error] = result // String
        }
        print("Finish func updateBulkRecords")
        Handlers.returnToClient(result: resp, response)
    }
    
    /*
     let params = [Keys.i: username,
     Keys.enc_ak: encAccountKey, // encrypted by aesMasterKey
     Keys.enc_pk: encPrivateKey, // encrypted by aesMasterKey
     Keys.enc_s: encSalt, // encrypted by Session Key
     Keys.enc_v: encVerifier // encrypted by Session Key
     ] as [String: Any]
     */
    public static func changeUserPassword(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func changeUserPassword")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()
        
        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary()  else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
        
        let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
        guard let api_Key = request.header(headerName),
            api_Key == AppConfig.api_Key_value else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.invalid_request
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        guard let _ = inputParams[Keys.i] as? String,
            let _ = inputParams[Keys.enc_v],
            let _ = inputParams[Keys.enc_s],
           // let _ = inputParams[Keys.enc_pk],
            let _ = inputParams[Keys.enc_ak] else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }
        let (status, result) = User.changePassword(params: inputParams)
        resp[Keys.status] = status
        if status == false {
            resp[Keys.error] = result // String
        }
        print("Finish func changeUserPassword")
        Handlers.returnToClient(result: resp, response)
    }
    
    
    /*
     let params = [Keys.i: username
     ] as [String: Any]
     
     response: true or false
     */
    public static func checkUserExists(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func checkUserExists")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()
        
        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary()  else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
        
        let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
        guard let api_Key = request.header(headerName),
            api_Key == AppConfig.api_Key_value else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.invalid_request
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        guard let username = inputParams[Keys.i] as? String else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }
        let exist = Auth.checkIfExists(username: username)
        resp[Keys.status] = true
        resp[Keys.exist] = exist
        
        print("Finish func checkUserExists")
        Handlers.returnToClient(result: resp, response)
    }
    
    /*
     let params = [Keys.i: username,
     Keys.enc_password: enc_password, // encrypted wallet password
     Keys.enc_priv: enc_priv // encrypted wallet private key
     ] as [String: Any]
     */
    public static func createNewWallet(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func createNewWallet")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()
        
        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary()  else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
        
        let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
        guard let api_Key = request.header(headerName),
            api_Key == AppConfig.api_Key_value else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.invalid_request
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        guard let _ = inputParams[Keys.i] as? String,
            let _ = inputParams[Keys.enc_password],
            let _ = inputParams[Keys.enc_priv] else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }
        let (status, result) = Wallet.createNewWallet(params: inputParams)
        resp[Keys.status] = status
        if status == false {
            resp[Keys.error] = result // String
        }
        print("Finish func createNewWallet")
        Handlers.returnToClient(result: resp, response)
    }
    
    /*
     let params = [Keys.i: username,
     Keys.enc_expiredAt: enc_expiredAt // encrypted Date String
     ] as [String: Any]
     */
    public static func updateSubscriptionExpiredAt(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func updateSubscriptionExpiredAt")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()
        
        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary()  else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
        
        let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
        guard let api_Key = request.header(headerName),
            api_Key == AppConfig.api_Key_value else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.invalid_request
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        guard let _ = inputParams[Keys.i] as? String,
            let _ = inputParams[Keys.enc_expiredAt] else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }
        let (status, result) = User.updateSubscriptionExpiredAt(params: inputParams)
        resp[Keys.status] = status
        if status == false {
            resp[Keys.error] = result // String
        }

        print("Finish func updateSubscriptionExpiredAt")
        Handlers.returnToClient(result: resp, response)
    }
    
    /*
     let params = [Keys.i: username]
     */
    public static func getSubscriptionExpiredAt(request: HTTPRequest, _ response: HTTPResponse) {
        print("Start func getSubscriptionExpiredAt")
        // Set the response type
        response.setHeader(.contentType, value: "application/json")
        // Container for response data
        var resp = [String: Any]()
        
        // process incoming data, with protections in case the params are not supplied
        guard let inputParams = request.postBodyString?.toDictionary()  else {
            // set an error response to be returned
            response.status = .badRequest
            resp[Keys.error] = ErrorMsg.please_supply_values
            Handlers.returnToClient(result: resp, response)
            return
        }
        
        let  headerName = HTTPRequestHeader.Name.custom(name: Keys.api_Key)
        guard let api_Key = request.header(headerName),
            api_Key == AppConfig.api_Key_value else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.invalid_request
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        guard let _ = inputParams[Keys.i] as? String else {
                // set an error response to be returned
                response.status = .badRequest
                resp[Keys.error] = ErrorMsg.please_supply_values
                Handlers.returnToClient(result: resp, response)
                return
        }
        
        var username = inputParams[Keys.i] as! String
        username = username.lowercased()
        let (status, accountStatus) = User.fetchUserAccountStatus(username: username)
        resp[Keys.status] = status
        if status == true {
            let (accountType, expiredAt) = accountStatus as! (Int, String)
            let result = [Keys.accountType: accountType,
                          Keys.expiredAt: expiredAt] as [String : Any]
            resp[Keys.user_accounting] = result // [[String:Any]]
        } else {
            resp[Keys.error] = accountStatus
        }
        print("Finish func getSubscriptionExpiredAt")
        Handlers.returnToClient(result: resp, response)
    }

}// class Handlers
