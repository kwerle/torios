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
        var subscriptionsToDelete = try! self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Subscription] ?? [Subscription]()
        
        Alamofire.request(.GET, url, headers: headers).validate().response { (request, response, data, error) -> Void in
            let json = JSON(data: data!)
            NSLog("subscription JSON: \(json)")
            for (key, subscriptionJSON):(String, JSON) in json["subscriptions"] {
                let subscriptionData = SubscriptionData(htmlUrl: subscriptionJSON["htmlUrl"].stringValue,
                    url: subscriptionJSON["url"].stringValue,
                    sortid: subscriptionJSON["sortid"].stringValue,
                    firstitemmsec: subscriptionJSON["firstitemmsec"].stringValue,
                    title: subscriptionJSON["title"].stringValue,
                    id: subscriptionJSON["id"].stringValue,
                    iconUrl: subscriptionJSON["iconUrl"].stringValue,
                    unreadCount: subscriptionJSON["unreadCount"].intValue
                )
                let s = Subscription.findOrCreate(moc: self.managedObjectContext, subscriptionData: subscriptionData)
                subscriptionsToDelete = subscriptionsToDelete.filter({ $0.id != s.id })
//                NSLog("sub: \(s)")
            }
            for subscription in subscriptionsToDelete {
                self.managedObjectContext.deleteObject(subscription)
            }
            self.fetchCounts()
            NSLog("saving subs")
            try! self.managedObjectContext.save()
            
            let subscriptions = try! self.managedObjectContext.executeFetchRequest(fetchRequest) as? [Subscription] ?? [Subscription]()
            for subscription in subscriptions {
                self.fetchUnreadItems(subscription)
            }
        }
    }
    
    func fetchCounts() {
        let url = "https://theoldreader.com/reader/api/0/unread-count?output=json"
        
        Alamofire.request(.GET, url, headers: headers).validate().response { (request, response, data, error) -> Void in
            let json = JSON(data: data!)
            for (key,countJSON):(String, JSON) in json["unreadcounts"] {
//                NSLog("itemJSON: \(countJSON)")
                if let subscription = Subscription.withId(moc: self.managedObjectContext, subscriptionId: countJSON["id"].stringValue) {
                    subscription.unreadCount = countJSON["count"].numberValue
                    try! self.managedObjectContext.save()
                }
            }
        }
    }
    
    // MARK: - Items

    func fetchUnreadItems(subscription: Subscription) {
        // GET https://theoldreader.com/reader/api/0/unread-count?output=json
        let url = "https://theoldreader.com/reader/api/0/stream/contents?output=json&s=user/-/state/com.google/reading-list&xt=user/-/state/com.google/read&s=\(subscription.id)"

        Alamofire.request(.GET, url, headers: headers).validate().response { (request, response, data, error) -> Void in
            let json = JSON(data: data!)
            for (key, itemJSON):(String, JSON) in json["items"] {
                NSLog("itemJSON: \(itemJSON)")
                if let subscription = Subscription.withId(moc: self.managedObjectContext, subscriptionId: itemJSON["origin"]["streamId"].stringValue) {
                    let itemData = ItemData(
                        crawlTimeMsec: itemJSON["crawlTimeMsec"].stringValue,
                        timestampUsec: itemJSON["timestampUsec"].stringValue,
                        id: itemJSON["id"].stringValue,
                        title: itemJSON["title"].stringValue,
                        published: itemJSON["published"].numberValue,
                        updatedTime: itemJSON["updatedTime"].numberValue,
                        canonical: itemJSON["canonical"][0]["href"].stringValue,
                        summaryContent: itemJSON["summary"]["content"].stringValue,
                        author: itemJSON["author"].stringValue,
                        subscription: subscription
                    )
                    let i = Item.findOrCreate(moc: self.managedObjectContext, itemData: itemData)
                    NSLog("Item: \(i.title) for \(i.subscription!.title)")
                    NSLog("sub: \(subscription)")
                    NSLog("item: \(i)")
                    NSLog("item.subscription: \(i.subscription)")
                    NSLog("items: \(subscription.items)")
                } else {
                    let key = itemJSON["origin"]["streamId"]
                    NSLog("Could not find sub for \(key)")
                }
            }
            do {
                try self.managedObjectContext.save()
            } catch {
                NSLog("Bummer")
            }
        }
    }
}
