//
//  PlaceTableViewCell.swift
//  hw9
//
//  Created by GuJiarui on 4/19/18.
//  Copyright © 2018 GuJiarui. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var placeNameLabel: UILabel!
    
    @IBOutlet weak var placeAddrLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    var place = Place()
    
    @IBAction func favoriteTouched(_ sender: Any) {
        var placeIndex = -1
        if favoritePlaces.count != 0{
            for i in 0...favoritePlaces.count-1{
                if favoritePlaces[i].placeId == place.placeId{
                    placeIndex = i
                }
            }
        }
        if placeIndex == -1{
            favoritePlaces.append(place)
            let image = UIImage(named: "favorite-filled")
            self.favoriteButton.setImage(image, for: .normal)
        }
        else{
            favoritePlaces.remove(at: placeIndex)
            let image = UIImage(named: "favorite-empty")
            self.favoriteButton.setImage(image, for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
