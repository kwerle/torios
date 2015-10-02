//
//  UserSession.swift
//  torios
//
//  Created by Kurt Werle on 10/1/15.
//  Copyright © 2015 Kurt Werle. All rights reserved.
//

import Foundation

class UserSession {
    var userName: String?
    var password: String?
    var authToken: String?
    
    var authString: String? {
        get {
            if let token = authToken {
                return "Authorization: GoogleLogin auth=\(token)"
            }
            return nil
        }
    }
    
    func login(name: String, password: String) -> Bool {
        
    }
    
}