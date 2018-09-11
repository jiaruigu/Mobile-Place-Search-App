//
//  FavoritesTableViewController.swift
//  hw9
//
//  Created by GuJiarui on 4/25/18.
//  Copyright © 2018 GuJiarui. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import McPicker
import SwiftyJSON
import Alamofire
import AlamofireSwiftyJSON
import GooglePlaces
import GoogleMaps

var favoriteList = [String]()

class FavoritesTableViewController: UITableViewController {

    var needsUpdate: Bool = false {
        didSet {
            if needsUpdate == true{
                self.tableView.reloadData()
            }
        }
    }
    var cellIndex = -1
    
    weak var delegate: SegueHandler?

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

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        needsUpdate = false
        tableView.separatorStyle = .singleLine
        if favoritePlaces.isEmpty{
            let noDataLabel: UILabel = UILabel(frame: CGRect(x:0, y:0, width:tableView.bounds.size.width, height:tableView.bounds.size.height))
            noDataLabel.text = "No Favorites"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment  = .center
            tableView.separatorStyle = .none
            tableView.backgroundView = noDataLabel
        }
        else {
            tableView.backgroundView = .none
        }
        return favoritePlaces.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PlaceTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PlaceTableViewCell  else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        let place = favoritePlaces[indexPath.row]
        
        cell.placeNameLabel.text = place.name
        cell.placeAddrLabel.text = place.addr
        
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
        detailUrl = domain + "index.php?PlaceId=" + favoritePlaces[indexPath.row].placeId + "&QueryType=PlaceDetail"
        detailPlaceId = favoritePlaces[indexPath.row].placeId
        detailPlaceName = favoritePlaces[indexPath.row].name
        delegate?.segueToNext(identifier: "placeSearchToDetailsSegue")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is DetailsViewController
        {
            let vc = segue.destination as? DetailsViewController
            vc?.place = favoritePlaces[self.cellIndex]
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            if favoritePlaces.count == 1 {
                favoritePlaces.remove(at: indexPath.row)
                tableView.reloadData()
            }
            else{
                tableView.beginUpdates()
                favoritePlaces.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                tableView.endUpdates()
            }
        }
    }

}
