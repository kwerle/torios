//
//  SubscriptionController.swift
//  torios
//
//  Created by Kurt Werle on 10/1/15.
//  Copyright © 2015 Kurt Werle. All rights reserved.
//

import Foundation
import CoreData

import Alamofire

import SwiftyJSON

class SubscriptionController {
    var userSession: UserSession

    var managedObjectContext: NSManagedObjectContext {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.managedObjectContext
        }
    }

    init(session: UserSession) {
        userSession = session
        fetchSubscriptions()
    }

    var headers: [String: String] {
        get {
            return ["Authorization": userSession.authToken]
        }
    }
    
    func fetchSubscriptions() {
        // GET https://theoldreader.com/reader/api/0/unread-count?output=json
        let url = "https://theoldreader.com/reader/api/0/subscription/list?output=json"

        let fetchRequest = NSFetchRequest(entityName: "Subscription")
        
        do {
            let subscriptions = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Subscription]
            for s in subscriptions {
                managedObjectContext.deleteObject(s)
            }
        } catch {
            fatalError("Failed to fetch subscriptions: \(error)")
        }

        
        Alamofire.request(.GET, url, headers: headers).validate().response { (request, response, data, error) -> Void in
            let json = JSON(data: data!)
            for (key,subscriptionJSON):(String, JSON) in json["subscriptions"] {
                let subscriptionData = SubscriptionData(htmlUrl: subscriptionJSON["htmlUrl"].stringValue,
                    url: subscriptionJSON["url"].stringValue,
                    sortid: subscriptionJSON["sortid"].stringValue,
                    firstitemmsec: subscriptionJSON["firstitemmsec"].stringValue,
                    title: subscriptionJSON["title"].stringValue,
                    id: subscriptionJSON["id"].stringValue,
                    iconUrl: subscriptionJSON["iconUrl"].stringValue)
                Subscription.findOrCreate(moc: self.managedObjectContext, subscriptionData: subscriptionData)
            }
            try! self.managedObjectContext.save()
        }
    }
}

/*
{
"htmlUrl" : "http:\/\/blog.okcupid.com",
"url" : "http:\/\/blog.okcupid.com\/index.php\/feed\/",
"sortid" : "51d2f0028e49d025c002481f",
"firstitemmsec" : "1410396098000",
"title" : "OkTrends",
"categories" : [

],
"id" : "feed\/51d2f0028e49d025c002481f",
"iconUrl" : "\/\/s.theoldreader.com\/system\/uploads\/feed\/picture\/50e2\/ea0b\/e721\/ec6e\/2800\/icon_0272.ico"
}
*/
struct SubscriptionData {
    let htmlUrl:       String
    let url:           String
    let sortid:        String
    let firstitemmsec: String
    let title:         String
    let id:            String
    let iconUrl:       String
//    "categories" : [
//
//    ],
}
