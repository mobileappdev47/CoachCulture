//
//  CoachViseRecipeItemTableViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit
import HCSStarRatingView

class CoachViseRecipeItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewDuration: UIView!
    @IBOutlet weak var lblSubscribedTime: UILabel!
    @IBOutlet weak var lblSubscribedName: UILabel!
    @IBOutlet weak var viewClassDetail: UIView!
    @IBOutlet weak var viewSubscribe: UIView!
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var lbltitle : UILabel!
    @IBOutlet weak var lblRecipeType : UILabel!
    @IBOutlet weak var lblDuration : UILabel!
    @IBOutlet weak var lblFoodType : UILabel!
    @IBOutlet weak var imgUser : UIImageView!
    @IBOutlet weak var imgBookMark : UIImageView!
    @IBOutlet weak var btnBookMark : UIButton!
    @IBOutlet weak var clvDietaryRestriction: UICollectionView!
    
    @IBOutlet weak var imgProfileBottom: UIImageView!
    @IBOutlet weak var viewProfileBottom: UIView!
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var imgProfileBanner: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    

    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var btnRating: UIButton!
    @IBOutlet weak var starRating: HCSStarRatingView!
    @IBOutlet weak var lblRate: UILabel!
    
    //MARK: - VARIABLE AND OBJECT
    
    var arrDietaryRestriction = [String]()
    var didTapBookmarkButton : (() -> Void)!
    var selectedIndex = 0
    var isAllowTagLayout = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    func setUpUI() {
        clvDietaryRestriction.register(UINib(nibName: "RecipeDietartyItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecipeDietartyItemCollectionViewCell")
        clvDietaryRestriction.delegate = self
        clvDietaryRestriction.dataSource = self
        if isAllowTagLayout {
            clvDietaryRestriction.collectionViewLayout = TagsLayout()
        }
    }
    
    //MARK: - ACTION
    
    @IBAction func btnBookmarkClick(_ sender: Any) {
        if didTapBookmarkButton != nil {
            didTapBookmarkButton()
        }
    }
    
    @IBAction func btnRatingTap(_ sender: UIButton) {
        
    }
}



// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension CoachViseRecipeItemTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return arrDietaryRestriction.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeDietartyItemCollectionViewCell", for: indexPath) as!  RecipeDietartyItemCollectionViewCell
        if !isAllowTagLayout {
            cell.viwContainer.addCornerRadius(3)
        } else {
            
        }
        cell.lblTitle.text = arrDietaryRestriction[indexPath.row]
        cell.lblTitle.sizeToFit()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 20.0) / 2, height: 15)
    }
    
}
