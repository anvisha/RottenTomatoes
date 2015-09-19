//
//  MoviesViewController.swift
//  RottenTomatoes
//
//  Created by Anvisha Pai on 9/16/15.
//  Copyright © 2015 Anvisha Pai. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            if let d = data {
                let json = try! NSJSONSerialization.JSONObjectWithData(d, options: []) as? NSDictionary
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.tableView.reloadData()
                }
            } else {
                if let e = error {
                    NSLog("Error: \(e)")
                }
            }
        }
        tableView.dataSource = self
        tableView.delegate = self

    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        cell.titleLabel.text = movie["title"] as? String
        
        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)
        
        cell.posterView.setImageWithURL(url!)
        return cell
        
    }

}
