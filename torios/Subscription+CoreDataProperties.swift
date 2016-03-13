//
//  Subscription+CoreDataProperties.swift
//  
//
//  Created by Kurt Werle on 10/2/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Subscription {

    @NSManaged var firstitemmsec: String?
    @NSManaged var htmlUrl: String?
    @NSManaged var iconUrl: String?
    @NSManaged var id: String!
    @NSManaged var sortid: String?
    @NSManaged var timeStamp: NSDate?
    @NSManaged var title: String?
    @NSManaged var unreadCount: NSNumber?
    @NSManaged var url: String?
    @NSManaged var items: NSOrderedSet?

}
