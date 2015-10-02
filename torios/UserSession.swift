//
//  UserSession.swift
//  torios
//
//  Created by Kurt Werle on 10/1/15.
//  Copyright © 2015 Kurt Werle. All rights reserved.
//

import Foundation

import Alamofire

var _instance: UserSession?

class UserSession {
    var userName: String?
    var password: String?
    var authToken: String?
    var oldReaderURLs: OldReaderURLs!
    var authenticated = false
    
    init(urls: OldReaderURLs) {
        oldReaderURLs = urls
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
    
    func login(name: String, pass: String) {
        userName = name
        password = pass
        //        curl -d "client=YourAppName&accountType=HOSTED_OR_GOOGLE&service=reader&Email=test@krasnoukhov.com&Passwd=..." https://theoldreader.com/accounts/ClientLogin
        let args = [
            "client": "torios",
            "accountType": "hosted",
            "service": "reader",
            "Email": name,
            "Passwd": pass
        ]
//        let args = "client=torios&accountType=hosted&service=reader&Email=\(name)&Passwd=\(pass)"

        Alamofire.request(.POST, oldReaderURLs.login, parameters: args).validate().responseJSON { (request, response, json) -> Void in
            NSLog("request: \(request)")
            NSLog("response: \(response)")
            NSLog("json: \(json)")
            
        }
    }
    
}

struct OldReaderURLs {
    //    curl -d "client=YourAppName&accountType=HOSTED_OR_GOOGLE&service=reader&Email=test@krasnoukhov.com&Passwd=..." https://theoldreader.com/accounts/ClientLogin
    let login = "https://theoldreader.com/accounts/ClientLogin"
    
}
