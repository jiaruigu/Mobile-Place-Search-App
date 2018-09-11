//
//  PhotosCollectionViewController.swift
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
import SwiftPhotoGallery

private let reuseIdentifier = "Cell"

class PhotosCollectionViewController: UICollectionViewController {
    
    var index: Int = 0
    //var images = [Image]()
    //var imagesIndex = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if placeDetail.imgUrls.isEmpty{
            let noDataLabel: UILabel = UILabel(frame: CGRect(x:0, y:0, width:collectionView.bounds.size.width, height:collectionView.bounds.size.height))
            noDataLabel.text = "No Photos"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment  = .center
            collectionView.backgroundView = noDataLabel
        }
        else {
            collectionView.backgroundView = .none
        }
        return placeDetail.imgUrls.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        // Configure the cell
        let cellIdentifier = "PhotoCollectionCellIdentifier"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        let imgUrl = placeDetail.imgUrls[indexPath.row]
        Alamofire.request(imgUrl, method: .get).responseImage { response in
            guard let image = response.result.value else {
                // Handle error
                return
            }
            // Do stuff with your image
            //self.images.append(image)
            //self.imagesIndex.append(indexPath.row)
            cell.photoImageView.image = image
        }
        return cell
    }
/*
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.index = indexPath.item
        
        let gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
        gallery.backgroundColor = UIColor.black
        gallery.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
        gallery.currentPageIndicatorTintColor = UIColor(red: 0.0, green: 0.66, blue: 0.875, alpha: 1.0)
        gallery.hidePageControl = false
        present(gallery, animated: true, completion: { () -> Void in
            gallery.currentPage = self.index
        })
    }
*/
}
/*
extension PhotosCollectionViewController: SwiftPhotoGalleryDataSource {
    
    func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
        return self.images.count
    }
    
    func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
        return images[self.imagesIndex[forIndex]]
    }
}


// MARK: SwiftPhotoGalleryDelegate Methods
extension PhotosCollectionViewController: SwiftPhotoGalleryDelegate {
    
    func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
        self.index = gallery.currentPage
        dismiss(animated: true, completion: nil)
    }
}
*/
