//
//  Item.swift
//
//
//  Created by Kurt Werle on 10/2/15.
//
//

import Foundation
import CoreData

let updateQueue = NSOperationQueue()

class Item: NSManagedObject {
    
    var updating = false

    class func withId(moc moc: NSManagedObjectContext, id: String) -> Item? {
        let fetchRequest = NSFetchRequest(entityName: "Item")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)

        do {
            let items = try moc.executeFetchRequest(fetchRequest) as! [Item]
            if items.count > 0 {
                return items[0]
            }
        } catch {
            fatalError("Failed to fetch items: \(error)")
        }
        return nil
    }

    class func findOrCreate(moc moc: NSManagedObjectContext, itemData: ItemData) -> Item {
        if let existing = withId(moc: moc, id: itemData.id) {
            return existing
        }
        let item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: moc) as! Item

        item.crawlTimeMsec = itemData.crawlTimeMsec
        item.timestampUsec = itemData.timestampUsec
        item.id = itemData.id
        item.title = itemData.title
        item.published = itemData.published
        item.updatedTime = itemData.updatedTime
        item.summaryContent = itemData.summaryContent
        item.author = itemData.author
        item.canonical = itemData.canonical
//        item.likingUsersCount = itemData.likingUsersCount
        item.subscription = itemData.subscription

//        try! moc.save()
        return item
    }
    
    override func didChangeValueForKey(key: String) {
        switch key {
        case "read":
            checkUpdate()
        default:
            break
        }
    }
    
    private func checkUpdate() {
        updateQueue.addOperationWithBlock() { () -> Void in
//            <#code#>
        }
    }
}

struct ItemData {
    let crawlTimeMsec: String
    let timestampUsec: String
    let id: String
    let title: String
    let published: NSNumber
    let updatedTime: NSNumber
    let canonical: String
    let summaryContent: String
    let author: String
//    let likingUsersCount: NSNumber
    let subscription: Subscription
//    "origin": {
//    "streamId": "feed/53a1374ffea0e7a7500005f3",
//    "title": "Uhhh...",
//    "htmlUrl": "http://kilbert.herokuapp.com"
//    "comments": [],
//    "annotations": [],
//    "likingUsers": [],
//    "categories": [
//    "user/-/state/com.google/reading-list",
//    "user/-/state/com.google/fresh",
//    "user/-/label/Funny"
//    ],
//    "canonical": [
//    {
//    "href": "http://assets.amuniversal.com/eddcf1c03d41013306d6005056a9545d"
//    }
//    ],
//    "alternate": [
//    {
//    "href": "http://assets.amuniversal.com/eddcf1c03d41013306d6005056a9545d",
//    "type": "text/html"
//    }
//    ],
}

/*
{
"crawlTimeMsec": "1443767179380",
"timestampUsec": "1443657600000000",
"id": "tag:google.com,2005:reader/item/560e239b511dbed4440007b5",
"categories": [
"user/-/state/com.google/reading-list",
"user/-/state/com.google/fresh",
"user/-/label/Funny"
],
"title": "Dilbert 2015-10-01",
"published": 1443657600,
"updated": 1443657600,
"canonical": [
{
"href": "http://assets.amuniversal.com/eddcf1c03d41013306d6005056a9545d"
}
],
"alternate": [
{
"href": "http://assets.amuniversal.com/eddcf1c03d41013306d6005056a9545d",
"type": "text/html"
}
],
"summary": {
"direction": "ltr",
"content": "<img src=\"http://assets.amuniversal.com/eddcf1c03d41013306d6005056a9545d\">"
},
"author": "",
"annotations": [],
"likingUsers": [],
"likingUsersCount": 0,
"comments": [],
"origin": {
"streamId": "feed/53a1374ffea0e7a7500005f3",
"title": "Uhhh...",
"htmlUrl": "http://kilbert.herokuapp.com"
}
}
*/
