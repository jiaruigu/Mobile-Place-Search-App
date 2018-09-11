//
//  InfoViewController.swift
//  hw9
//
//  Created by GuJiarui on 4/22/18.
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
import Cosmos
import SwiftSpinner

class InfoViewController: UIViewController {
    @IBOutlet var infoView: UIView!
    
    @IBOutlet weak var addressText: UITextView!
    
    @IBOutlet weak var phoneNumberText: UITextView!
    
    @IBOutlet weak var priceLevelText: UITextView!
    
    @IBOutlet weak var starControl: CosmosView!
    
    @IBOutlet weak var websiteButton: UIButton!
    
    @IBOutlet weak var googlePageButton: UIButton!
    
    var name = String(), addr = String(), phoneNumber = String(), priceLevel = 0, rating = 0.0, website = String(), googlePage = String(), imgUrls = [String](), latitude = 0.0, longitude = 0.0, googleReviews = [PlaceDetail.Review](), yelpReviews = [PlaceDetail.Review](), city = String(), state = String(), country = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftSpinner.show("Loading place detail")
        websiteButton.contentHorizontalAlignment = .left
        googlePageButton.contentHorizontalAlignment = .left
        if detailUrl != ""{
            Alamofire.request(detailUrl, method: .post, parameters: [:], encoding:JSONEncoding.default).responseJSON{   response in
                let placesResultsJsonObj = JSON(response.data!)
                if placesResultsJsonObj["status"].string! == "ZERO_RESULTS" {
                    //no results
                }
                else{
                    self.name = placesResultsJsonObj["result"]["name"].exists() ? placesResultsJsonObj["result"]["name"].string!:""
                    self.addr = placesResultsJsonObj["result"]["formatted_address"].exists() ? placesResultsJsonObj["result"]["formatted_address"].string!:""
                    self.phoneNumber = placesResultsJsonObj["result"]["international_phone_number"].exists() ? placesResultsJsonObj["result"]["international_phone_number"].string!:""
                    self.priceLevel = placesResultsJsonObj["result"]["price_level"].exists() ? placesResultsJsonObj["result"]["price_level"].int!:0
                    self.rating = placesResultsJsonObj["result"]["rating"].exists() ? placesResultsJsonObj["result"]["rating"].double!: 0.0
                    self.website = placesResultsJsonObj["result"]["website"].exists() ? placesResultsJsonObj["result"]["website"].string!: ""
                    self.googlePage = placesResultsJsonObj["result"]["url"].exists() ? placesResultsJsonObj["result"]["url"].string!: ""
                    self.imgUrls = [String]()
                    if placesResultsJsonObj["result"]["photos"].count != 0{
                        for i in 0...placesResultsJsonObj["result"]["photos"].count-1
                        {
                            self.imgUrls.append(placesResultsJsonObj["result"]["photos"][i]["photo_reference"].string!)
                        }
                    }
                    self.latitude = placesResultsJsonObj["result"]["geometry"]["location"].exists() ? placesResultsJsonObj["result"]["geometry"]["location"]["lat"].double!: 0.0
                    self.longitude = placesResultsJsonObj["result"]["geometry"]["location"].exists() ? placesResultsJsonObj["result"]["geometry"]["location"]["lng"].double!: 0.0
                    self.googleReviews = [PlaceDetail.Review]()
                    if placesResultsJsonObj["result"]["reviews"].count != 0{
                        for i in 0...placesResultsJsonObj["result"]["reviews"].count-1{
                            let review = placesResultsJsonObj["result"]["reviews"][i].dictionary!
                            let date = Date(timeIntervalSince1970: TimeInterval((review["time"]?.uInt64)!))
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let time = dateFormatter.string(from: date)
                            self.googleReviews.append(PlaceDetail.Review(author_name: (review["author_name"]?.string)!, author_url: (review["author_url"]?.string)!, profile_photo_url: (review["profile_photo_url"]?.string)!, rating: (review["rating"]?.double)!, text: (review["text"]?.string)!, time: time))
                        }
                    }
                    for i in 0...placesResultsJsonObj["result"]["address_components"].count-1{
                        if placesResultsJsonObj["result"]["address_components"][i]["types"][0].string! == "locality"
                        {
                            self.city = placesResultsJsonObj["result"]["address_components"][i]["short_name"].string!
                        }
                        if placesResultsJsonObj["result"]["address_components"][i]["types"][0].string! == "administrative_area_level_1"
                        {
                            self.state = placesResultsJsonObj["result"]["address_components"][i]["short_name"].string!
                        }
                        if placesResultsJsonObj["result"]["address_components"][i]["types"][0].string! == "country"
                        {
                            self.country = placesResultsJsonObj["result"]["address_components"][i]["short_name"].string!
                        }
                    }
                    let url = domain + "index.php?name=\(self.name)&city=\(self.city)&state=\(self.state)&country=\(self.country)&address1=\(self.addr.split(separator: ",")[0])&QueryType=YelpReview".replacingOccurrences(of: " ", with: "+")
                    Alamofire.request(url, method: .post, parameters: [:], encoding:JSONEncoding.default).responseJSON{ response in
                        let placesResultsJsonObj = JSON(response.data!)
                        if placesResultsJsonObj["reviews"].count != 0 {
                            for i in 0...placesResultsJsonObj["reviews"].count-1 {
                                let author_name = placesResultsJsonObj["reviews"][i]["user"]["name"].string!
                                let author_url = placesResultsJsonObj["reviews"][i]["url"].string!
                                let profile_photo_url = placesResultsJsonObj["reviews"][i]["user"]["image_url"] == JSON.null ? "": placesResultsJsonObj["reviews"][i]["user"]["image_url"].string!
                                let rating = placesResultsJsonObj["reviews"][i]["rating"].double!
                                let text = placesResultsJsonObj["reviews"][i]["text"].string!
                                let time = placesResultsJsonObj["reviews"][i]["time_created"].string!
                                let review = PlaceDetail.Review(author_name: author_name, author_url: author_url, profile_photo_url: profile_photo_url, rating: rating, text: text, time: time)
                                self.yelpReviews.append(review)
                            }
                        }
                        placeDetail = PlaceDetail(name: self.name,addr: self.addr, phoneNumber: self.phoneNumber, priceLevel: self.priceLevel, rating: self.rating, website: self.website, googlePage: self.googlePage, imgUrls: self.imgUrls, latitude: self.latitude, longitude: self.longitude, googleReviews: self.googleReviews, yelpReviews: self.yelpReviews)
                        SwiftSpinner.hide()
                    }
                    self.addressText.text =  self.addr
                    self.phoneNumberText.text = self.phoneNumber
                    self.priceLevelText.text =  String(repeating: "$", count: self.priceLevel)
                    self.starControl.rating = self.rating
                    self.websiteButton.setTitle(self.website, for: .normal)
                    self.googlePageButton.setTitle(self.googlePage, for: .normal)
                }
            }
            self.starControl.settings.updateOnTouch = false
        }
    }

    @IBAction func viewWebsite(_ sender: Any) {
        if let url = URL(string: self.website) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func viewGooglePage(_ sender: Any) {
        if let url = URL(string: self.googlePage) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
