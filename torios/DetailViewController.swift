//
//  DetailViewController.swift
//  torios
//
//  Created by Kurt Werle on 10/1/15.
//  Copyright © 2015 Kurt Werle. All rights reserved.
//

import UIKit

import CoreData

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var detailItem: Subscription! {
        didSet {
            
//            if let moc = detailItem.managedObjectContext {
////                let entity = NSEntityDescription.entityForName("Item", inManagedObjectContext: moc)
//                let fetchRequest = NSFetchRequest(entityName: "Item")
//                fetchRequest.predicate = NSPredicate(format: "subscription == %@", argumentArray: [detailItem])
//                do {
//                    items = try moc.executeFetchRequest(fetchRequest) as! [Item]
//                    NSLog("fetchItems: \(items)")
//                } catch {
//                    fatalError("Failed to fetch items: \(error)")
//                }
//            }
            
            // Update the view.
            NSLog("detailItem.items: \(detailItem.items)")
            detailItem.managedObjectContext?.refreshObject(detailItem, mergeChanges: true)
            self.configureView()
        }
    }
    
    private var _items: [Item]!
    private var items: [Item] {
        get {
            if _items == nil {
                _items = detailItem.currentItems()
            }
            return _items
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.valueForKey("title")!.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Events
    
    var selectedItem: Item?
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedItem = itemAtIndex(indexPath)
        performSegueWithIdentifier("Show Item", sender: self)
    }
    
    // MARK: UITableViewDataSource

    func itemAtIndex(indexPath: NSIndexPath) -> Item {
        NSLog("index: \(indexPath.row)/\(items.count)")
        return items[indexPath.row]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("items.count: \(items.count)")
        return items.count
    }
    
    var _cell: UITableViewCell!
    var cell: UITableViewCell {
        get {
            if _cell != nil {
                return _cell
            }
            _cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Cell")
            return _cell
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) ?? cell
        self.configureCell(c, atIndexPath: indexPath)
        return c
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let item = itemAtIndex(indexPath)
        cell.textLabel!.text = item.title
    }

    // MARK Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        if segue.identifier == "Show Item" {
            let vc = segue.destinationViewController as! ItemDisplayViewController
            vc.item = self.selectedItem
        }
    }
}

