//
//  UserSession.swift
//  torios
//
//  Created by Kurt Werle on 10/1/15.
//  Copyright © 2015 Kurt Werle. All rights reserved.
//

import Foundation

import Alamofire
import Locksmith

var _instance: UserSession?

class UserSession {
    
    var account: AccountData
    
    var authToken: String!
    var oldReaderURLs: OldReaderURLs!
    var authenticated: Bool {
        get {
            return authToken != nil
        }
    }
    
    static let loginSucceeded = "loginSucceeded"
    static let loginFailed = "loginFailed"

    init(urls: OldReaderURLs) {
        oldReaderURLs = urls
        account = AccountData(userName: "", password: "")
        account.readFromSecureStore()
        _instance = self
    }
    
    class var instance: UserSession {
        get {
            return _instance!
        }
    }
    
    var authString: String? {
        get {
            if let token = authToken {
                return "Authorization: GoogleLogin auth=\(token)"
            }
            return nil
        }
    }
    
    func storeAuthInfo(name: String, pass: String) {
        let account = AccountData(userName: name, password: pass)
        do {
            try account.createInSecureStore()
        } catch  {
            NSLog("Failed to store in keychain \(name) \(pass) becaues \(error)")
        }
    }
    
    func login(name: String, pass: String) {
        storeAuthInfo(name, pass: pass)
        //        curl -d "client=YourAppName&accountType=HOSTED_OR_GOOGLE&service=reader&Email=test@krasnoukhov.com&Passwd=..." https://theoldreader.com/accounts/ClientLogin
        let args = [
            "client": "torios",
            "accountType": "hosted",
            "service": "reader",
            "Email": name,
            "Passwd": pass
        ]

        Alamofire.request(.POST, oldReaderURLs.login, parameters: args).validate().response { (request, response, responseData, error) -> Void in
            if response?.statusCode == 200 {
                let keyString = String.init(data: responseData!, encoding: NSUTF8StringEncoding)!
                let keyStart = keyString.rangeOfString("Auth=")?.endIndex
                let key = keyString.substringFromIndex(keyStart!)
                
                self.authToken = "Authorization: GoogleLogin auth=\(key)"
                NSNotificationCenter.defaultCenter().postNotificationName(UserSession.loginSucceeded, object: self)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(UserSession.loginFailed, object: self)
            }
        }
    }
    
}

struct AccountData: ReadableSecureStorable, CreateableSecureStorable, GenericPasswordSecureStorable {
    let userName: String
    let password: String
    
    // Required by GenericPasswordSecureStorable
    let service = "TheOldReader"
    var account: String { return userName }
    
    // Required by CreateableSecureStorable
    var data: [String: AnyObject] {
        return ["password": password]
    }
}

struct OldReaderURLs {
    let login = "https://theoldreader.com/accounts/ClientLogin"
    
}
