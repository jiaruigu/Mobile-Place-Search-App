//
//  ResultsTableViewController.swift
//  hw9
//
//  Created by GuJiarui on 4/19/18.
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
import SwiftSpinner

class ResultsTableViewController: UITableViewController {
    var places = [Place]()
    var url = ""
    var cellIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SwiftSpinner.show("Searching")
        Alamofire.request(self.url, method: .post, parameters: [:], encoding:JSONEncoding.default).responseJSON{ response in
            let placesResultsJsonObj = JSON(response.data!)
            var name,addr,icon,placeId:String
            var place = Place()
            if placesResultsJsonObj[0]["status"].string! == "ZERO_RESULTS" {
                //no results
            }
            else{
                for i in 0...placesResultsJsonObj.count-1 {
                    for j in 0...placesResultsJsonObj[i]["results"].count-1
                    {
                        name = placesResultsJsonObj[i]["results"][j]["name"].string!
                        icon = placesResultsJsonObj[i]["results"][j]["icon"].string!
                        addr = placesResultsJsonObj[i]["results"][j]["vicinity"].string!
                        placeId = placesResultsJsonObj[i]["results"][j]["place_id"].string!
                        place = Place(icon: icon, name: name, addr: addr, placeId: placeId)
                        self.places += [place]
                    }
                }
            }
            SwiftSpinner.hide()
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.separatorStyle = .singleLine
        if self.places.isEmpty{
            let noDataLabel: UILabel = UILabel(frame: CGRect(x:0, y:0, width:tableView.bounds.size.width, height:tableView.bounds.size.height))
            noDataLabel.text = "No Results"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment  = .center
            tableView.separatorStyle = .none
            tableView.backgroundView = noDataLabel
        }
        else {
            tableView.backgroundView = .none
        }
        return self.places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PlaceTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PlaceTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        let place = self.places[indexPath.row]
        var favorited = false
        if favoritePlaces.count != 0{
            for i in 0...favoritePlaces.count-1{
                if favoritePlaces[i].placeId == place.placeId{
                    favorited = true
                }
            }
        }
        if favorited{
            let image = UIImage(named: "favorite-filled")
            cell.favoriteButton.setImage(image, for: .normal)
        }
        cell.placeNameLabel.text = place.name
        cell.placeAddrLabel.text = place.addr
        cell.place = place
        Alamofire.request(place.icon, method: .get).responseImage { response in
            guard let image = response.result.value else {
                // Handle error
                return
            }
            // Do stuff with your image
            cell.iconImageView.image = image
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellIndex = indexPath.row
        detailUrl = domain + "index.php?PlaceId=" + self.places[indexPath.row].placeId + "&QueryType=PlaceDetail"
        detailPlaceId = self.places[indexPath.row].placeId
        detailPlaceName = self.places[indexPath.row].name
        self.performSegue(withIdentifier: "resultsToDetailsSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DetailsViewController
        {
            let vc = segue.destination as? DetailsViewController
            vc?.place = self.places[self.cellIndex]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }

}

