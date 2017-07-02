//
//  BusinessCollectionViewCell.swift
//  YelmGMap
//
//  Created by Manuel Aurora on 09.06.17.
//  Copyright © 2017 Manuel Aurora. All rights reserved.
//

import UIKit
import Cosmos

class BusinessCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mainImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneNumberLabal: UILabel!
    @IBOutlet weak var ratingStarsView: CosmosView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    var defautMainImageHeightValue: CGFloat = 181.0;
    var business: Business!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false;
        let screenWidth = UIScreen.main.bounds.size.width;
        widthConstraint.constant = screenWidth - 10*2;
        defautMainImageHeightValue = mainImageViewHeightConstraint.constant
    }
    
    func setUpWith (business: Business) {
        self.business = business;
        if let grs = phoneNumberLabal.gestureRecognizers {
            for recognizer in grs {
                phoneNumberLabal.removeGestureRecognizer(recognizer)
            }
        }
        if let phone = business.phone {
            phoneNumberLabal.isHidden = false
            phoneNumberLabal.text = phone
        }
        else {
            phoneNumberLabal.isHidden = true
        }
        
        if let rating = business.rating {
            ratingStarsView.isHidden = false
            ratingStarsView.rating = rating
        }
        else {
            ratingStarsView.isHidden = true
        }
        
        if let imageUrl = business.imageUrlStr {
            mainImageViewHeightConstraint.constant = defautMainImageHeightValue;
            mainImageView.af_setImage(withURL: URL(string: imageUrl)!)
        }
        else {
             mainImageViewHeightConstraint.constant = 0;
        }
        if let categories = business.categories {
            if (categories.count > 0) {
                categoryLabel.text = business.getCategoriesString()
                categoryLabel.isHidden = false;
                categoryTitle.isHidden = false;
            }
            else {
                categoryLabel.isHidden = true;
                categoryTitle.isHidden = true;
            }
        }
    }
    
}
