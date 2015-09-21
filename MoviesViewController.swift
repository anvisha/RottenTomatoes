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
        let request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            JTProgressHUD.hide()
            if let d = data {
                let json = try! NSJSONSerialization.JSONObjectWithData(d, options: []) as? NSDictionary
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.tableView.reloadData()
                }
                onCompletion?()
            } else {
                let label = UILabel(frame: CGRectMake(0, 0, 200, 21))
                label.center = CGPointMake(160, 284)
                label.textAlignment = NSTextAlignment.Center
                label.text = "Network Error"
                self.view.addSubview(label)
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
        
        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)
        cell.posterView.setImageWithURL(url!)

        return cell
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! MovieDetailsViewController
        let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
        let data =  searchActive ? filteredMovies : movies
        vc.selectedMovie = data![indexPath!.row]
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
}
