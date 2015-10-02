//
//  ItemDisplayViewController.swift
//  torios
//
//  Created by Kurt Werle on 10/2/15.
//  Copyright © 2015 Kurt Werle. All rights reserved.
//

import UIKit

class ItemDisplayViewController: UIViewController {

    var item: Item! {
        didSet {
            updateWebView()
        }
    }
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateWebView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateWebView() {
        if let i = item, wv = webView {
            let url = NSURL(string: i.canonical!)
            wv.loadHTMLString(i.summaryContent!, baseURL: url)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
