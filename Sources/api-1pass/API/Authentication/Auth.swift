//
//  AuthCommon.swift
//  api-1pass
//
//  Created by Ngo Lien on 5/24/18.
//

import Foundation
import BigInt

/* Contains common func for SignUp and Login
 */

class Auth:NSObject {
    
    public static func checkIfExists(username: String) -> Bool {
        let url = ELASTIC_SEARCH.BASE_URL + "user/default/" + username
        let result = Utility.makeRequest(.get, url)
        let exists = result["found"] ?? false
        return exists as! Bool
    }
    
    // API Create new user if not exists. User ID is username:
    public static func createNewUser(username: String, attrs:[String:Any]) -> (Bool, String) {
        let url = ELASTIC_SEARCH.BASE_URL + "user/default/" + username + "/_create"
        let result = Utility.makeRequest(.put, url, body: attrs.json)
        if result["result"] != nil {
            return (true, "Created New User.") // created
        }
        let status = result["status"] as! Int
        if status == 409 { // Conflict
            return (false, "Username exists already.")
        }
        return (false, "Cannot connect to Database.")
    }
    
    public static func updateUser(username:String, changes:[String:Any]) -> (Bool, String) {
        let url = ELASTIC_SEARCH.BASE_URL + "user/default/" + username + "/_update"
        let param = ["doc": changes]
        let result = Utility.makeRequest(.post, url, body: param.json)
        if result["result"] != nil {
            return (true, "Updated User.") // Updated
        }
        let status = result["status"] as! Int
        if status == 404 { // User not found
            return (false, ErrorMsg.user_does_not_exist)
        }
        return (false, "Something went wrong.")
    }
    
    // Return (true, (salt, verifier)) or (false, "error msg")
    public static func fetchSaltVerifier(username:String) -> (Bool, Any) {
        let url = ELASTIC_SEARCH.BASE_URL + "user/default/" + username + "?_source=*.id,s,v,/"
        let result = Utility.makeRequest(.get, url)
        let exists = result["found"] ?? false
        
        guard (exists as! Bool) else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        
        let attrs = result["_source"] as! [String:Any]
        let v = attrs[Keys.v]
        let s = attrs[Keys.s]
        
        return (true, (s, v))
    }
    
    // Return (true, K) or (false, "error msg")
    public static func fetchSessionKey(username:String) -> (Bool, Any) {
        let url = ELASTIC_SEARCH.BASE_URL + "user/default/" + username + "?_source=*.id,K,/"
        let result = Utility.makeRequest(.get, url)
        let exists = result["found"] ?? false
        
        guard (exists as! Bool) else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        
        let attrs = result["_source"] as! [String:Any]
        let K = attrs[Keys.K]
        return (true, K!)
    }
    
    public static func fetchUserCredentials(username:String) -> (Bool, Any) {
        let url = ELASTIC_SEARCH.BASE_URL + "user/default/" + username + "?_source_exclude=K,/"
        let result = Utility.makeRequest(.get, url)
        let exists = result["found"] ?? false
        
        guard (exists as! Bool) else {
            return (false, ErrorMsg.user_does_not_exist)
        }
        let attrs = result["_source"] as! [String:Any]
        
        return (true, attrs)
    }
}
