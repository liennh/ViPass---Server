//
//  Routes.swift
//  api-1pass
//
//  Created by Ngo Lien on 5/14/18.
//

import PerfectHTTP

// This function creates the routes
// Handlers are in Handlers.swift
public func makeJSONRoutes(_ root: String = "/api/v1/") -> Routes {
    var routes = Routes()
    
    // API for Record
    
    //routes.add(method: .post, uri: root + APIs.getRecordByID, handler: Handlers.getRecordByID) //Not used
    //routes.add(method: .post, uri: root + APIs.updateRecord, handler: Handlers.updateRecord) //Not used
    //routes.add(method: .post, uri: root + APIs.insertRecord, handler: Handlers.insertRecord) //Not used
    
    routes.add(method: .post, uri: root + APIs.signUp, handler: Handlers.signUp)
    routes.add(method: .post, uri: root + APIs.loginFirstStep, handler: Handlers.loginFirstStep)
    routes.add(method: .post, uri: root + APIs.loginLastStep, handler: Handlers.loginLastStep)
    
    routes.add(method: .post, uri: root + APIs.getLatestRecordChanges, handler: Handlers.getLatestRecordChanges)
    routes.add(method: .post, uri: root + APIs.uploadNotSyncedRecords, handler: Handlers.uploadNotSyncedRecords)
    routes.add(method: .post, uri: root + APIs.updateBulkRecords, handler: Handlers.updateBulkRecords)
    routes.add(method: .post, uri: root + APIs.deleteBulkRecords, handler: Handlers.deleteBulkRecords)
    routes.add(method: .post, uri: root + APIs.changeUserPassword, handler: Handlers.changeUserPassword)
    routes.add(method: .post, uri: root + APIs.checkUserExists, handler: Handlers.checkUserExists)
    
    routes.add(method: .post, uri: root + APIs.updateSubscriptionExpiredAt, handler: Handlers.updateSubscriptionExpiredAt)
    routes.add(method: .post, uri: root + APIs.getSubscriptionExpiredAt, handler: Handlers.getSubscriptionExpiredAt)
    
    // API for Wallet
    //routes.add(method: .post, uri: root + APIs.createNewWallet, handler: Handlers.createNewWallet)
    
    return routes
}//
//
