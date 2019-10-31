//
//  Search.swift
//  api-1pass
//
//  Created by Ngo Lien on 6/9/18.
//

import Foundation
//import BigInt

/* Contains common func for interacting with Elasticsearch
 */
class DB: NSObject {
    // MARK: Wallet
    
    // MARK: Record

    // Return (true, RecordInfo) or (false, "error msg")
    public static func getRecord(id: String) -> (Bool, Any) {
        let url = ELASTIC_SEARCH.BASE_URL + "record/default/" + id
        let result = Utility.makeRequest(.get, url)
        let exists = result["found"] ?? false

        guard (exists as! Bool) else {
            return (false, "Record does not exist.")
        }

        let attrs = result["_source"] // as! [String: Any]
        return (true, attrs!)
    }

    // API Create new record if not exists. record ID is UUID:
    /*public static func createNewRecord(uuid: String, attrs: [String: Any]) -> (Bool, Any) {
        let url = ELASTIC_SEARCH.BASE_URL + "record/default/" + uuid + "/_create"
        let result = Utility.makeRequest(.put, url, body: attrs.json)
        if result["result"] != nil {
            return (true, "Created New Record.") // created
        }
        let status = result["status"] as! Int
        if status == 409 { // Conflict
            return (false, "Record exists already.")
        }
        return (false, "Cannot connect to Database.")
    }*/

    /*public static func updateRecord(uuid: String, changes: [String: Any]) -> (Bool, String) {
        let url = ELASTIC_SEARCH.BASE_URL + "record/default/" + uuid + "/_update"
        let param = ["doc": changes]
        let result = Utility.makeRequest(.post, url, body: param.json)
     
        
        if result["result"] != nil {
            return (true, "Updated Record.") // Updated
        }
        let status = result["status"] as! Int
        if status == 404 { // Record not found
            return (false, "Record does not exist.")
        }
        return (false, "Something went wrong.")
    }*/
    
    public static func canUpdateRecord(id:String, username:String) -> Bool {
        let (success, result) = DB.getRecord(id: id)
        if success {
            let record = result as! [String: Any]
            let createdBy = record["createdBy"] ?? ""
            guard (createdBy as! String) == username else {
                return false
            }
            return true
        } else {
            return false
        }
    }

    public static func deleteRecords(bulk: [Any], username: String) {
        let url = ELASTIC_SEARCH.BASE_URL + "record/default/_bulk"
        var body = ""
        for item in bulk {
            var record = item as! [String: Any]
            let recordID = record["id"] as! String
            record["createdBy"] = username // Fix bug username is "local"
            guard DB.canUpdateRecord(id: recordID, username: username) else {
                continue
            }
            let ts = record["ts"] as! String
            body += """
            {"update":{"_id":"\(recordID)"}}
            {"doc":{"isDeleted":1,"ts":"\(ts)"}}\n
            """
        }
        if body != "" {
            _ = Utility.makeRequest(.post, url, body: body)
        }
    }


    // Return (true, List of RecordInfo) or []
    public static func getLatestRecordChanges(sinceTs: String, username:String) -> [Any] {
        let url = ELASTIC_SEARCH.BASE_URL + "record/default/_search"
        let query = """
            {
                "query": {
                    "bool": {
                        "must": [
                            { "match_phrase": {
                                  "createdBy": "\(username)"
                               }
                            },
                            {  "range": {
                                  "ts": {
                                    "gte": "\(sinceTs)"
                                  }
                                }
                            }
                        ]
                    }
                },
                "from": 0,
                "size": \(AppConfig.Max_Items_Per_Download_Request),
                "sort": [
                    { "ts": {"order":"asc"}}
                ]
            }
        """
        let result = Utility.makeRequest(.post, url, body: query)
        guard let hits1 = result["hits"] as? [String: Any] else {
            return []
        }
        let hits2 = hits1["hits"] as! [[String: Any]]
        var listRecords = [Any]()
        for item in hits2 {
            let record = item["_source"] as! [String:Any]
            let createdBy = record["createdBy"] as! String
            if createdBy == username {
                listRecords.append(record)
            }
        }
        return listRecords
    }

    public static func createRecords(bulk: [Any], username:String!) {
        let url = ELASTIC_SEARCH.BASE_URL + "record/default/_bulk"
        var body = ""
        for item in bulk {
            var record = item as! [String: Any]
            let recordID = record["id"] as! String
            record["createdBy"] = username // Fix bug username is "local"
            let recordJSON = record.json
            if recordJSON != "" {
                body += """
                {"create":{"_id":"\(recordID)"}}
                \(recordJSON)\n
                """
            }
        }
        if body != "" {
            let _ = Utility.makeRequest(.post, url, body: body)
        }
    }

    public static func updateRecords(bulk: [Any], username: String) {
        let url = ELASTIC_SEARCH.BASE_URL + "record/default/_bulk"
        var body = ""
        for item in bulk {
            var record = item as! [String: Any]
            let recordID = record["id"] as! String
            record["createdBy"] = username // Fix bug username is "local"
            guard DB.canUpdateRecord(id: recordID, username: username) else {
                continue
            }
            
            let recordJSON = record.json
            if recordJSON != "" {
                body += """
                {"update":{"_id":"\(recordID)"}}
                {"doc":\(recordJSON)}\n
                """
            }
        }
        if body != "" {
            let _ = Utility.makeRequest(.post, url, body: body)
        }
    }


}// class
