//
//  GoogleMapViewController.swift
//  hw9
//
//  Created by GuJiarui on 4/23/18.
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

class GoogleMapViewController: UIViewController {
    
    var travelMode: Int = 0 {
        didSet {
            showDirection()
        }
    }
    
    var fromPlaceId: String = "" {
        didSet {
            showDirection()
        }
    }
    
    var fromPlaceCoord = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Do any additional setup after loading the view.
        showMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showDirection(){
        var camera = GMSCameraPosition.camera(withLatitude: deviceLocation.latitude, longitude: deviceLocation.longitude, zoom: 20.0)
        let map = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = map
        var mode = "driving"
        switch self.travelMode {
        case 0:
            mode = "driving"
        case 1:
            mode = "bicycling"
        case 2:
            mode = "transit"
        case 3:
            mode = "walking"
        default:
            mode = "driving"
        }
        var url = ""
        if fromPlaceId == "" {
            url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(deviceLocation.latitude),\(deviceLocation.longitude)&destination=place_id:\(detailPlaceId)&mode=\(mode)&key=AIzaSyA4sZg1K91dMp5PQFyMzWD0r73-fnu8ob8"
        }
        else {
            url = "https://maps.googleapis.com/maps/api/directions/json?origin=place_id:\(fromPlaceId)&destination=place_id:\(detailPlaceId)&mode=\(mode)&key=AIzaSyA4sZg1K91dMp5PQFyMzWD0r73-fnu8ob8"
        }
        Alamofire.request(url, method: .post, parameters: [:], encoding:JSONEncoding.default).responseJSON{ response in
            let directionJsonObj = JSON(response.data!)
            if directionJsonObj["status"].string! == "ZERO_RESULTS" {
                //no results
            }
            else{
                for i in 0...directionJsonObj["routes"].count-1 {
                    let points = directionJsonObj["routes"][i]["overview_polyline"]["points"].string!
                    let path = GMSPath.init(fromEncodedPath: points)
                    let polyline = GMSPolyline.init(path: path)
                    polyline.strokeWidth = 3
                    polyline.map = self.view as? GMSMapView
                    let bounds = GMSCoordinateBounds(path: path!)
                    camera = map.camera(for: bounds, insets: UIEdgeInsets.zero)!
                    map.camera = camera
                    let markerA = GMSMarker()
                    let markerB = GMSMarker()
                    if self.fromPlaceId == ""{
                        markerA.position = CLLocationCoordinate2D(latitude: deviceLocation.latitude, longitude: deviceLocation.longitude)
                    }
                    else {
                        markerA.position = self.fromPlaceCoord
                    }
                    markerA.map = map
                    markerB.position = CLLocationCoordinate2D(latitude: placeDetail.latitude, longitude: placeDetail.longitude)
                    markerB.map = map
                }
            }
        }
    }
    
    func showMap() {
        let camera = GMSCameraPosition.camera(withLatitude: placeDetail.latitude, longitude: placeDetail.longitude, zoom: 15.0)
        let map = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = map
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: placeDetail.latitude, longitude: placeDetail.longitude)
        marker.map = map
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
