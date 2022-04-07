//
//  YourCoachRecipeItemTableViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit

class YourCoachRecipeItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblRecipeType: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    
    @IBOutlet weak var imgRecipe: UIImageView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var imgBookmark: UIImageView!
    
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var clvDietaryRestriction: UICollectionView!
    
    //MARK: - VARIABLE AND OBJECT
    
    var didTapBookmarkButton : (() -> Void)!
    var selectedIndex = 0
    var arrDietaryRestriction = [String]()
    
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK: - ACTION
    
    @IBAction func btnBookmarkClick(_ sender: Any) {
        if didTapBookmarkButton != nil {
            didTapBookmarkButton()
        }
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension YourCoachRecipeItemTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return arrDietaryRestriction.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeDietartyItemCollectionViewCell", for: indexPath) as!  RecipeDietartyItemCollectionViewCell
        
        cell.viwContainer.addCornerRadius(3)
        cell.lblTitle.text = arrDietaryRestriction[indexPath.row]
    
        
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: 55, height: 15)
    }
    
    
}
