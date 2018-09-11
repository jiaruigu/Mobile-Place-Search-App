//
//  ViewController.swift
//  hw9
//
//  Created by GuJiarui on 4/17/18.
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

let domain = "http://127.0.0.1:8888/IOS/"
var deviceLocation = CLLocationCoordinate2D()
var favoritePlaces = [Place]()
var detailUrl = ""
var detailPlaceId = ""
var detailPlaceName = ""

protocol SegueHandler: class {
    func segueToNext(identifier: String)
}

class ViewController: UIViewController, CLLocationManagerDelegate, SegueHandler {
    func segueToNext(identifier: String) {
        self.performSegue(withIdentifier: identifier, sender: self)
    }
    
    @IBOutlet weak var messageBox: UILabel!
    
    @IBOutlet weak var keywordField: UITextField!
    
    @IBOutlet weak var catagoryField: McTextField!
    
    @IBOutlet weak var distanceField: UITextField!
    
    @IBOutlet weak var fromField: UITextField!
    
    @IBOutlet weak var favoritesView: UIView!
    
    @IBOutlet weak var contentControl: UISegmentedControl!
    
    var contentType = 0
    
    let catagorySelector: [[String]] = [
        ["Defult","Airport","Amusrment Park","Aquarium","Art Gallery","Bakery","Bar","Beauty Salon","Bowling Alley","Bus Station","Cafe","Campground","Car Rental","Casino","Lodging","Movie Theater","Museum","Night Club","Park","Parking","Restaurant", "Shopping Mall", "Stadium", "Subway Station", "Taxi Stand", "Train Station", "Transit Station", "Travel Agency", "Zoo"]
    ]
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide favorites view
        messageBox.isHidden = true
        favoritesView.isHidden = true
        //Set up mcpicker
        catagoryField.text = "Default"
        let catagoryView = McPicker(data: catagorySelector)
        catagoryView.backgroundColor = .gray
        catagoryView.backgroundColorAlpha = 0.25
        catagoryField.inputViewMcPicker = catagoryView
        catagoryField.doneHandler = { [weak catagoryField] (selections) in
            catagoryField?.text = selections[0]!
        }
        //Get the device location
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        //Set up textui
        distanceField.keyboardType = .numberPad
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        deviceLocation = (manager.location?.coordinate)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func contentChanged(_ sender: Any) {
        self.contentType = contentControl.selectedSegmentIndex
        if self.contentType == 0{
            self.favoritesView.isHidden = true
        }
        else{
            self.favoritesView.isHidden = false
            let cv = childViewControllers.last as! FavoritesTableViewController
            cv.needsUpdate = true
        }
        //let cv = childViewControllers.last as! FavoritesTableViewController
        //cv.orderType = self.orderType
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ResultsTableViewController
        {
            let keyword = keywordField?.text?.replacingOccurrences(of: " ", with: "+")
            let catagory = catagoryField?.text?.replacingOccurrences(of: " ", with: "_").lowercased()
            let distance = distanceField?.text == "" ? "10": distanceField?.text
            var url = domain + "index.php"
            var flag = true
            var location = ""
            if fromField?.text == "Your location" {
                location = "\(deviceLocation.latitude),\(deviceLocation.longitude)"
                flag = true
            }
            else {
                flag = false
                location = (fromField?.text?.replacingOccurrences(of: " ", with: "+"))!
            }
            url += "?Keyword=\(keyword ?? "")&Category=\(catagory ?? "")&Distance=\(distance ?? "")&Location=\(location)&Flag_LatLon=\(flag)&QueryType=PlaceNearBy"
            let vc = segue.destination as? ResultsTableViewController
            vc?.url = url
        }
        if segue.identifier == "Embed" {
            let dvc = segue.destination as! FavoritesTableViewController
            dvc.delegate = self
        }
    }
    
    @IBAction func showAutoComplete(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func searchTouched(_ sender: Any) {
        if keywordField.text?.replacingOccurrences(of: " ", with: "", options: .literal, range: nil) == ""{
            messageBox.text = "Keyword cannot be empty"
            messageBox.isHidden = false
            Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
        }
        else if fromField.text?.replacingOccurrences(of: " ", with: "", options: .literal, range: nil) == ""{
            messageBox.text = "From location cannot be empty"
            messageBox.isHidden = false
            Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.dismissAlert), userInfo: nil, repeats: false)
        }
        else{
            performSegue(withIdentifier: "placeSearchToResultsSegue", sender: self)
        }
    }
    
    @objc func dismissAlert(){
        messageBox.isHidden = true
    }
    
    @IBAction func clear(_ sender: Any) {
        catagoryField.text = "Default"
        let catagoryView = McPicker(data: catagorySelector)
        catagoryView.backgroundColor = .gray
        catagoryView.backgroundColorAlpha = 0.25
        catagoryField.inputViewMcPicker = catagoryView
        catagoryField.doneHandler = { [weak catagoryField] (selections) in
            catagoryField?.text = selections[0]!
        }
        keywordField.text = ""
        distanceField.text = ""
        fromField.text = "Your location"
    }
    
    @IBAction func HideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
}


extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        fromField?.text = place.name
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


class Place{
    let icon, name, addr, placeId: String
    init(icon: String, name: String, addr: String, placeId: String) {
        self.icon = icon
        self.name = name
        self.addr = addr
        self.placeId = placeId
    }
    init() {
        self.icon = ""
        self.name = ""
        self.addr  = ""
        self.placeId = ""
    }
}
