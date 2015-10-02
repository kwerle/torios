//
//  DetailViewController.swift
//  torios
//
//  Created by Kurt Werle on 10/1/15.
//  Copyright © 2015 Kurt Werle. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!


    var detailItem: Subscription! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.valueForKey("title")!.description
            }
//            tableView.reloadData()
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
        return detailItem.items[indexPath.indexAtPosition(indexPath.length - 1)]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if detailItem == nil {
            return 0
        }
        return detailItem.items.count
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

