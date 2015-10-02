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

class SubscriptionsController {
    var managedObjectContext: NSManagedObjectContext {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.managedObjectContext
        }
    }

    init(managedObjectContext: NSManagedObjectContext) {
        managedObjectContext.performBlockAndWait({ () -> Void in
            self.fetchSubscriptions()
        })
//        self.fetchSubscriptions()
    }

    var headers: [String: String] {
        get {
            return ["Authorization": UserSession.instance.authToken]
        }
    }

    func fetchSubscriptions() {
        // GET https://theoldreader.com/reader/api/0/unread-count?output=json
        let url = "https://theoldreader.com/reader/api/0/subscription/list?output=json"
        
        //        Clear out old subscriptions - they may have been deleted elsewhere
        let fetchRequest = NSFetchRequest(entityName: "Subscription")
        do {
            let subscriptions = try self.managedObjectContext.executeFetchRequest(fetchRequest) as! [Subscription]
            for s in subscriptions {
//                NSLog("deleteObject")
                self.managedObjectContext.deleteObject(s)
            }
            NSLog("deleting subs")
//            try! self.managedObjectContext.save()
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
                let s = Subscription.findOrCreate(moc: self.managedObjectContext, subscriptionData: subscriptionData)
                NSLog("sub: \(s)")
            }
            NSLog("saving subs")
            try! self.managedObjectContext.save()
//            self.fetchUnreadItems()
        }
    }

    func fetchUnreadItems() {
        // GET https://theoldreader.com/reader/api/0/unread-count?output=json
        let url = "https://theoldreader.com/reader/api/0/stream/contents?output=json&s=user/-/state/com.google/reading-list&xt=user/-/state/com.google/read"


//        We should clear out old read items.

//        let fetchRequest = NSFetchRequest(entityName: "Item")
//        do {
//            let subscriptions = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Subscription]
//            for s in subscriptions {
//                managedObjectContext.deleteObject(s)
//            }
//        } catch {
//            fatalError("Failed to fetch subscriptions: \(error)")
//        }


        Alamofire.request(.GET, url, headers: headers).validate().response { (request, response, data, error) -> Void in
            let json = JSON(data: data!)
            for (key,itemJSON):(String, JSON) in json["items"] {
                if let subscription = Subscription.withId(moc: self.managedObjectContext, id: itemJSON["origin"]["streamId"].stringValue) {
                    let itemData = ItemData(
                        crawlTimeMsec: itemJSON["crawlTimeMsec"].stringValue,
                        timestampUsec: itemJSON["timestampUsec"].stringValue,
                        id: itemJSON["id"].stringValue,
                        title: itemJSON["title"].stringValue,
                        published: itemJSON["published"].numberValue,
                        updatedTime: itemJSON["updatedTime"].numberValue,
                        canonical: itemJSON["canonical"][0]["href"].stringValue,
                        summaryContent: itemJSON["summaryContent"].stringValue,
                        author: itemJSON["author"].stringValue,
                        subscription: subscription
                    )
                    let i = Item.findOrCreate(moc: self.managedObjectContext, itemData: itemData)
                    NSLog("Item: \(i)")
                }
//                try! self.managedObjectContext.save()
            }
        }
    }
}
