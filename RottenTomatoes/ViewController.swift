//
//  ViewController.swift
//  RottenTomatoes
//
//  Created by Anvisha Pai on 9/14/15.
//  Copyright © 2015 Anvisha Pai. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var moviesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moviesTableView.rowHeight = 200.0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("com.example.cell") as! MyCell
        cell.myCustomLabel.text = "Row \(indexPath.row)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = DetailViewController(nibName: nil, bundle: nil)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

class MyCell : UITableViewCell {

    @IBOutlet weak var myCustomLabel: UILabel!
}

class DetailViewController : UIViewController {
    override func loadView() {
        let v = UIView(frame: CGRectZero)
        v.backgroundColor = UIColor.greenColor()
        self.view = v
    }
}