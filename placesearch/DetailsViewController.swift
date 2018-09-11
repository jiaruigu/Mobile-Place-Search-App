//
//  DetailsViewController.swift
//  hw9
//
//  Created by GuJiarui on 4/23/18.
//  Copyright © 2018 GuJiarui. All rights reserved.
//

import UIKit

var placeDetail = PlaceDetail()

class DetailsViewController: UITabBarController {
    
    @IBOutlet weak var favoriteBarButton: UIButton!
    
    @IBOutlet weak var forwardBarButton: UIButton!
    
    @IBOutlet weak var naviItem: UINavigationItem!
    
    var place = Place()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        naviItem.title = detailPlaceName
        var favorited = false
        if favoritePlaces.count != 0{
            for i in 0...favoritePlaces.count-1{
                if favoritePlaces[i].placeId == detailPlaceId{
                    favorited = true
                }
            }
        }
        if favorited{
            let image = UIImage(named: "favorite-filled")
            self.favoriteBarButton.setImage(image, for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func favoriteTouched(_ sender: Any) {
        var placeIndex = -1
        if favoritePlaces.count != 0{
            for i in 0...favoritePlaces.count-1{
                if favoritePlaces[i].placeId == detailPlaceId{
                    placeIndex = i
                }
            }
        }
        if placeIndex == -1{
            favoritePlaces.append(place)
            let image = UIImage(named: "favorite-filled")
            self.favoriteBarButton.setImage(image, for: .normal)
        }
        else{
            favoritePlaces.remove(at: placeIndex)
            let image = UIImage(named: "favorite-empty")
            self.favoriteBarButton.setImage(image, for: .normal)
        }
    }
    
    @IBAction func forwardTouched(_ sender: Any) {
        if let url = URL(string:"https://twitter.com/intent/tweet?text=Check out \(placeDetail.name) located at \(placeDetail.addr). Website: \(placeDetail.website.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)&hashtags= TravelAndEntertainmentSearch".replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

class PlaceDetail{
    let name, addr, phoneNumber, website, googlePage: String, priceLevel: Int, rating: Double, imgUrls: [String], latitude: Double, longitude: Double, googleReviews: [Review], yelpReviews: [Review]
    class Review{
        let author_name: String, author_url: String, profile_photo_url: String, rating: Double, text: String, time: String
        init(author_name: String, author_url: String, profile_photo_url: String, rating: Double, text: String, time: String){
            self.author_name = author_name
            self.author_url = author_url
            self.profile_photo_url = profile_photo_url
            self.rating = rating
            self.text = text
            self.time = time
        }
        init(){
            self.author_name = ""
            self.author_url = ""
            self.profile_photo_url = ""
            self.rating = 0.0
            self.text = ""
            self.time = ""
        }
    }
    init(name:String, addr: String, phoneNumber: String, priceLevel: Int, rating: Double, website: String, googlePage: String, imgUrls:[String], latitude: Double, longitude: Double, googleReviews: [Review], yelpReviews: [Review]) {
        self.name = name
        self.addr = addr
        self.phoneNumber = phoneNumber
        self.priceLevel = priceLevel
        self.rating = rating
        self.website = website
        self.googlePage = googlePage
        self.imgUrls = imgUrls
        self.latitude = latitude
        self.longitude = longitude
        self.googleReviews = googleReviews
        self.yelpReviews = yelpReviews
    }
    init() {
        self.name = ""
        self.addr = ""
        self.phoneNumber = ""
        self.priceLevel = 0
        self.rating = 0.0
        self.website = ""
        self.googlePage = ""
        self.imgUrls = []
        self.latitude = 0.0
        self.longitude = 0.0
        self.googleReviews = []
        self.yelpReviews = []
    }
}
