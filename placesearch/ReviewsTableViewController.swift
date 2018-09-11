//
//  ReviewsTableViewController.swift
//  hw9
//
//  Created by GuJiarui on 4/24/18.
//  Copyright © 2018 GuJiarui. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import McPicker
import SwiftyJSON
import Alamofire
import AlamofireSwiftyJSON
import AlamofireImage
import GooglePlaces
import GoogleMaps
import SwiftPhotoGallery
import Cosmos

class ReviewsTableViewController: UITableViewController {
    
    var reviewSource: Int = 0 {
        didSet {
            self.tableView.reloadData()
        }
    }
    var sortType:Int = 0 {
        didSet {
            self.tableView.reloadData()
        }
    }
    var orderType: Int = 0{
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if reviewSource == 0{
            return placeDetail.googleReviews.count
        }
        else{
            return placeDetail.yelpReviews.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewTableViewCell", for: indexPath) as? ReviewTableViewCell else {
            fatalError("The dequeued cell is not an instance of ReviewTableViewCell.")
        }
        // Configure the cell...
        var reviews = [PlaceDetail.Review]()
        if reviewSource == 0 {
            reviews = placeDetail.googleReviews
        }
        else{
            reviews = placeDetail.yelpReviews
        }
        let sortedReviews = sortReviews(reviews: reviews)
        cell.authorNameField.text = sortedReviews[indexPath.row].author_name
        cell.starControl.rating = sortedReviews[indexPath.row].rating
        cell.reviewContentField.text = sortedReviews[indexPath.row].text
        cell.timeField.text = sortedReviews[indexPath.row].time
        if sortedReviews[indexPath.row].profile_photo_url == "" {
            cell.profilePhotoView.image = UIImage(named: "unknown_person")
        }
        else{
            Alamofire.request(sortedReviews[indexPath.row].profile_photo_url, method: .get).responseImage { response in
                guard let image = response.result.value else {
                    // Handle error
                    return
                }
                // Do stuff with your image
                cell.profilePhotoView.image = image
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if reviewSource == 0{
            if let url = URL(string: placeDetail.googleReviews[indexPath.row].author_url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        else{
            if let url = URL(string: placeDetail.yelpReviews[indexPath.row].author_url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func sortReviews(reviews: [PlaceDetail.Review]) -> [PlaceDetail.Review]{
        var sortedReviews = reviews
        if sortType == 0{
            if orderType == 0{
            }
            else{
                sortedReviews.reverse()
            }
        }
        else if sortType == 1 {
            if orderType == 0 {
                sortedReviews = sortedReviews.sorted(by: { $0.rating < $1.rating })
            }
            else{
                sortedReviews = sortedReviews.sorted(by: { $0.rating > $1.rating })
            }
        }
        else {
            if orderType == 0{
                sortedReviews = sortedReviews.sorted(by: { $0.time < $1.time })
            }
            else{
                sortedReviews = sortedReviews.sorted(by: { $0.time > $1.time })
            }
        }
        return sortedReviews
    }
}
