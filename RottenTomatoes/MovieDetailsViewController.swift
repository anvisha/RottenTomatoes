//
//  MovieDetailsViewController.swift
//  RottenTomatoes
//
//  Created by Anvisha Pai on 9/19/15.
//  Copyright © 2015 Anvisha Pai. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    var containerView: UIView!
    
    var selectedMovie: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    func setUpScrollView() {
        
        //suggestions taken from http://www.raywenderlich.com/76436/use-uiscrollview-scroll-zoom-content-swift
        
        scrollView.scrollEnabled = true
        scrollView.delegate = self
        
        let height = setUpDetailsView()
        
        scrollView.addSubview(containerView)
        
        scrollView.contentSize = CGSize(width: 320, height: height)
        
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        
        // 5
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale;
        
    }
    
    func setUpDetailsView() -> (CGFloat) {
        
//        let height = 0
        
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 310, height: 20))
        titleLabel.text = selectedMovie?["title"] as? String
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(16)
        
        let ratingsLabel = UILabel(frame: CGRect(x: 10, y: 40, width: 310, height: 20))
        let criticsScore = selectedMovie!.valueForKeyPath("ratings.critics_score") as! Int
        let audienceScore = selectedMovie!.valueForKeyPath("ratings.audience_score") as! Int
        let ratingsContent = "Critics Rating: \(criticsScore)%, Audience Rating: \(audienceScore)%"
        ratingsLabel.font = UIFont(name: ratingsLabel.font.fontName, size: 13)
        ratingsLabel.textColor = UIColor.whiteColor()
        ratingsLabel.text = ratingsContent
        
        let synopsisText = selectedMovie!["synopsis"] as! String
    
        let synopsisLabel = UILabel(frame: CGRect(x: 10, y: 70, width: 310, height: 100))
        synopsisLabel.preferredMaxLayoutWidth = 320
        synopsisLabel.numberOfLines = 0
        synopsisLabel.text = synopsisText
        synopsisLabel.font = UIFont(name: synopsisLabel.font.fontName, size: 13)
        synopsisLabel.textColor = UIColor.whiteColor()
        synopsisLabel.sizeToFit()
        let labelHeight = synopsisLabel.frame.height + 80
        
        let containerSize = CGSize(width: 320, height: labelHeight)
        containerView = UIView(frame: CGRect(origin: CGPoint(x:0, y:380), size: containerSize))
        containerView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(ratingsLabel)
        containerView.addSubview(synopsisLabel)
        
        return labelHeight + 380
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieDetailsCell", forIndexPath: indexPath
        ) as! MovieDetailsCell
        var url = selectedMovie!.valueForKeyPath("posters.thumbnail") as! String
        
        let range = url.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            url = url.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        cell.posterView.alpha = 0.0
        cell.posterView.setImageWithURL(NSURL(string: url)!)
        UIView.animateWithDuration(1.5, animations: {
            cell.posterView.alpha = 1.0
        })
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
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
