//
//  Item+CoreDataProperties.swift
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

extension Item {

    @NSManaged var author: String?
    @NSManaged var canonical: String?
    @NSManaged var crawlTimeMsec: String?
    @NSManaged var id: String?
    @NSManaged var published: NSNumber?
    @NSManaged var summaryContent: String?
    @NSManaged var timestampUsec: String?
    @NSManaged var title: String?
    @NSManaged var updatedTime: NSNumber?
    @NSManaged var subscription: Subscription?

}
