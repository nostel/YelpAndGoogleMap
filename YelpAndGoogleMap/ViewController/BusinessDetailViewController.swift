//
//  BusinessDetailViewController.swift
//  YelpAndGoogleMap
//
//  Created by Son Le on 7/1/17.
//  Copyright © 2017 Son Le. All rights reserved.
//

import UIKit

// This collection view have 2 seactions
// Section 1: show basic infomation
// Section 2: show reviews
class BusinessDetailViewController: UICollectionViewController
{
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var businessToShow: Business!
    var reviews = [Review]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        self.navigationItem.title = businessToShow.name
        loadReviewsForBusiness ()
    }
    
    func loadReviewsForBusiness() {
        if let id = self.businessToShow.id {
            WebserviceHelper.sharedInstance.loadReviewsForBusiness(id: id, successHandler: { reviewsArray in
                for item in reviewsArray {
                    self.reviews.append(item);
                }
                
                self.collectionView?.performBatchUpdates({
                    self.collectionView?.insertSections(IndexSet(integer: 1))
                }, completion: { success in
                    
                    // Bug: if reviews.count > 3 then Cells overlaping each other
                    // TODO: any better way?
                    OperationQueue.main.addOperation ({
                        self.collectionView?.reloadData ()
                    })

                })
                
            }) { errorMessage in
                self.showAlert(title: "Error", message: errorMessage)
            }
        }
    }
    
    // MARK: COLLECTION VIEW
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if reviews.count > 0 {
            return 2
        }
        else {
            return 1
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        else {
            return reviews.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        
        var cellId: String
        
        if indexPath.section == 0// Main Info
        {
     
            cellId = String(describing: BusinessCollectionViewCell.self)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId,
                                                          for: indexPath) as! BusinessCollectionViewCell
            cell.setUpWith(business: businessToShow)
            return cell
        }
        else {// Reviews
            cellId = String(describing: ReviewCollectionViewCell.self)
            
            let review = reviews[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId,
                                                          for: indexPath) as! ReviewCollectionViewCell            
            
            cell.setupWith(review: review)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10;
    }

}

