//
//  ReviewCollectionViewCell.swift
//  YelmGMap
//
//  Created by Manuel Aurora on 13.06.17.
//  Copyright © 2017 Manuel Aurora. All rights reserved.
//

import UIKit
import Cosmos
import Alamofire
import AlamofireImage

class ReviewCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var ratingStarsView: CosmosView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false;
        let screenWidth = UIScreen.main.bounds.size.width;
        widthConstraint.constant = screenWidth - 10*2;
        self.needsUpdateConstraints() 
    }

    
    func setupWith(review: Review) {
        
        if let user = review.user {
            if let username = user.name {
                self.usernameLabel.text = username
            } else {
                self.usernameLabel.text = "No Username Provided"
            }
            
            if let userImageUrlStr = user.imageUrlStr {
                if let userImageUrl = URL(string: userImageUrlStr) {
                    let imageFilter = RoundedCornersFilter(radius: 16.0)
                    self.userImageView.af_setImage(withURL: userImageUrl, filter: imageFilter)
                }
            }
            else {
                self.userImageView.image = UIImage(named: "DefaultAvatar.jpeg")
            }

        }
        
        dateLabel.text = review.timeCreated
        
        commentTextView.text = review.text
        
        if let rating = review.rating {
            ratingStarsView.isHidden = false;
            ratingStarsView.rating = rating;
        }
        else {
            ratingStarsView.isHidden = true;
        }
        
    }
}
