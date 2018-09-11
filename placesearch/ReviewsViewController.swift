//
//  ReviewsViewController.swift
//  hw9
//
//  Created by GuJiarui on 4/23/18.
//  Copyright © 2018 GuJiarui. All rights reserved.
//

import UIKit

class ReviewsViewController: UIViewController {
    
    var reviewSource = 0
    var sortType = 0
    var orderType = 0
    
    @IBOutlet weak var reviewSourceControl: UISegmentedControl!
    
    @IBOutlet weak var sortTypeControl: UISegmentedControl!
    
    @IBOutlet weak var orderTypeControl: UISegmentedControl!
    
    @IBOutlet weak var reviewsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        reviewsView.isHidden = false
        if reviewSource == 0 && placeDetail.googleReviews.isEmpty {
            reviewsView.isHidden = true
        }
        else if reviewSource == 1 && placeDetail.yelpReviews.isEmpty {
            reviewsView.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func reviewSourceChanged(_ sender: Any) {
        self.reviewSource = reviewSourceControl.selectedSegmentIndex
        let cv = childViewControllers.last as! ReviewsTableViewController
        cv.reviewSource = self.reviewSource
        reviewsView.isHidden = false
        if reviewSource == 0 && placeDetail.googleReviews.isEmpty {
            reviewsView.isHidden = true
        }
        else if reviewSource == 1 && placeDetail.yelpReviews.isEmpty {
            reviewsView.isHidden = true
        }
    }
    
    @IBAction func sortTypeChanged(_ sender: Any) {
        self.sortType = sortTypeControl.selectedSegmentIndex
        let cv = childViewControllers.last as! ReviewsTableViewController
        cv.sortType = self.sortType
    }
    
    @IBAction func ordertypeChanged(_ sender: Any) {
        self.orderType = orderTypeControl.selectedSegmentIndex
        let cv = childViewControllers.last as! ReviewsTableViewController
        cv.orderType = self.orderType
    }
}
