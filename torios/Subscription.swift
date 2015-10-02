//
//  Subscription.swift
//  torios
//
//  Created by Kurt Werle on 10/1/15.
//  Copyright © 2015 Kurt Werle. All rights reserved.
//

import Foundation
import CoreData

class Subscription: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    class func withId(moc moc: NSManagedObjectContext, id: String) -> Subscription? {
        let fetchRequest = NSFetchRequest(entityName: "Subscription")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            let subscriptions = try moc.executeFetchRequest(fetchRequest) as! [Subscription]
            if subscriptions.count > 0 {
                return subscriptions[0]
            }
        } catch {
            fatalError("Failed to fetch subscriptions: \(error)")
        }
        return nil
    }

    class func findOrCreate(moc moc: NSManagedObjectContext, subscriptionData: SubscriptionData) -> Subscription {
        if let existing = withId(moc: moc, id: subscriptionData.id) {
            return existing
        }
        let subscription = NSEntityDescription.insertNewObjectForEntityForName("Subscription", inManagedObjectContext: moc) as! Subscription
        subscription.htmlUrl = subscriptionData.htmlUrl
        subscription.url = subscriptionData.url
        subscription.sortid = subscriptionData.sortid
        subscription.firstitemmsec = subscriptionData.firstitemmsec
        subscription.title = subscriptionData.title
        subscription.id = subscriptionData.id
        subscription.iconUrl = subscriptionData.iconUrl
//        try! moc.save()
        return subscription
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
