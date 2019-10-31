//
//  WalletAPI.swift
//  api-1pass
//
//  Created by Ngo Lien on 7/14/18.
//

import Foundation

class WalletAPI: NSObject {
    public static func createNewWallet(walletPassword: String, walletPriv:String) -> (Bool, Any) {
        let url = AppConfig.wallet_server + "create"
        let params = ["password": walletPassword,
                    "api_code": AppConfig.wallet_api_code,
                    "hd": true
            ] as [String : Any] // "priv": walletPriv
        
//        print("walletPassword: \(walletPassword)")
//        print("walletPriv: \(walletPriv)")
        
        let result = Utility.makeRequest(.post, url, body: params.json)

        //print("result of creating new wallet: \(result)")
        
        return (false, "Cannot connect to Database.")
    }
}
