//
//  Subscription+CoreDataProperties.swift
//  torios
//
//  Created by Kurt Werle on 10/1/15.
//  Copyright © 2015 Kurt Werle. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Subscription {

    @NSManaged var timeStamp: NSDate?
    @NSManaged var id: String
    @NSManaged var title: String
    @NSManaged var sortid: String
    @NSManaged var firstitemmsec: String
    @NSManaged var url: String
    @NSManaged var htmlUrl: String
    @NSManaged var iconUrl: String
    @NSManaged var items: [Item]

}
