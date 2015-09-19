//
//  MoviesViewController.swift
//  RottenTomatoes
//
//  Created by Anvisha Pai on 9/16/15.
//  Copyright © 2015 Anvisha Pai. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            if let d = data {
                let object = try! NSJSONSerialization.JSONObjectWithData(d, options: [])
                print(object)
            } else {
                if let e = error {
                    NSLog("Error: \(e)")
                }
            }
        }

    }


}
