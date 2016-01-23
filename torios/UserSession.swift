//
//  UserSession.swift
//  torios
//
//  Created by Kurt Werle on 10/1/15.
//  Copyright © 2015 Kurt Werle. All rights reserved.
//

import Foundation

import Alamofire
import SSKeychain

var _instance: UserSession?

class UserSession {

    static let loginSucceeded = "loginSucceeded"
    static let loginFailed = "loginFailed"
    
    let accountName = "TheOldReader"
    
    private var account: NSDictionary? {
        get {
            return SSKeychain.accountsForService(accountName).first as? NSDictionary
        }
    }
    
    private(set) var userName: String?
    private var password: String?
    
    var authToken: String!
    var oldReaderURLs: OldReaderURLs!
    var authenticated: Bool {
        get {
            return authToken != nil
        }
    }
    
    init(urls: OldReaderURLs) {
        oldReaderURLs = urls
        userName = account?["acct"] as? String
        if let name = userName {
            password = SSKeychain.passwordForService(accountName, account: name)
        }
        NSLog("\(account)")
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
        SSKeychain.setPassword(pass, forService: accountName, account: name)
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
    
    func autoLogin() {
        if let name = userName, pass = password {
            login(name, pass: pass)
        }
    }
}

struct OldReaderURLs {
    let login = "https://theoldreader.com/accounts/ClientLogin"
}
