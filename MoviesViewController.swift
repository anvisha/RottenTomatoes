//
//  MoviesViewController.swift
//  RottenTomatoes
//
//  Created by Anvisha Pai on 9/16/15.
//  Copyright © 2015 Anvisha Pai. All rights reserved.
//

import UIKit
import AFNetworking
import JTProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActive: Bool = false
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary]?
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let samplestyle = JTProgressHUDStyle.Default
        JTProgressHUD.showWithStyle(samplestyle)
        tableView.rowHeight = 200
        self.refreshControl.addTarget(self, action: "onRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        getMovies()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self

    }
    
    override func viewDidAppear(animated: Bool) {
        print(searchActive)
    }
    
    func onRefresh(sender: AnyObject) {
        getMovies(){
            self.refreshControl.endRefreshing()
        }
    }
    
    func getMovies(onCompletion: (() -> ())? = nil) {
    
        let url = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")
        let request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: NSTimeInterval(1000))
//        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            self.isConnected()
            JTProgressHUD.hide()
            if let d = data {
                let json = try! NSJSONSerialization.JSONObjectWithData(d, options: []) as? NSDictionary
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.networkErrorLabel.hidden = true
                    self.tableView.reloadData()
                    
                }
                onCompletion?()
            } else {
                print("Hi")
                self.networkErrorLabel.hidden = false
                if let e = error {
                    NSLog("Error: \(e)")
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            if searchActive {
                return filteredMovies!.count
            }
            else {
                return movies.count
            }
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let data =  searchActive ? filteredMovies : movies
        let movie = data![indexPath.row]
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        var urlText = movie.valueForKeyPath("posters.thumbnail") as! String
        var url = NSURL(string: urlText)
        let range = urlText.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            url = NSURL(string: urlText.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/"))
        }

        let urlRequest = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: NSTimeInterval(1000000))

        cell.posterView.alpha = 0.0
        cell.posterView.setImageWithURLRequest(urlRequest, placeholderImage: nil, success: nil, failure: nil)
        UIView.animateWithDuration(1.0, animations: {
            cell.posterView.alpha = 1.0
        })
        return cell
        
    }
    
    func imageFadeIn() {
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    //some of the below boilerplate taken from http://shrikar.com/swift-ios-tutorial-uisearchbar-and-uisearchbardelegate/

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = false
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchActive = false;
        searchBar.endEditing(true)
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = true;
        searchBar.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != "" {
            searchActive = true;
            filteredMovies = self.movies!.filter({ (movie) -> Bool in
                let title = movie["title"] as! NSString
                let search = title.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                return search.location != NSNotFound
            })
        } else {
            searchActive = false;
            searchBar.endEditing(true)
        }
        self.tableView.reloadData()
        
    }
    
    func isConnected(){
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
        
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock { (AFNetworkReachabilityStatus) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                switch (AFNetworkReachabilityStatus){
                case .NotReachable:
                    self.networkErrorLabel.hidden = false
                case .ReachableViaWiFi:
                    self.networkErrorLabel.hidden = true
                case .ReachableViaWWAN:
                    self.networkErrorLabel.hidden = true
                case .Unknown:
                    self.networkErrorLabel.hidden = false
                }
            })
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! MovieDetailsViewController
        let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
        let data =  searchActive ? filteredMovies : movies
        vc.selectedMovie = data![indexPath!.row]
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}
