//
//  CoachViseRecipeItemTableViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit

class CoachViseRecipeItemTableViewCell: UITableViewCell {
    
    
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
    
    //MARK: - VARIABLE AND OBJECT
    
    var arrDietaryRestriction = [String]()
    var didTapBookmarkButton : (() -> Void)!
    var selectedIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    func setUpUI() {
        clvDietaryRestriction.register(UINib(nibName: "RecipeDietartyItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecipeDietartyItemCollectionViewCell")
        clvDietaryRestriction.delegate = self
        clvDietaryRestriction.dataSource = self
        clvDietaryRestriction.collectionViewLayout = TagsLayout()
    }
    
    //MARK: - ACTION
    
    @IBAction func btnBookmarkClick(_ sender: Any) {
        if didTapBookmarkButton != nil {
            didTapBookmarkButton()
        }
    }
    
}



// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension CoachViseRecipeItemTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return arrDietaryRestriction.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeDietartyItemCollectionViewCell", for: indexPath) as!  RecipeDietartyItemCollectionViewCell
        
        cell.lblTitle.text = arrDietaryRestriction[indexPath.row]
        cell.lblTitle.sizeToFit()
        
        return cell
        
        
    }
}
