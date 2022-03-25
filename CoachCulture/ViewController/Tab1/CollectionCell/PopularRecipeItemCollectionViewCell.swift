//
//  PopularRecipeItemCollectionViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit

class PopularRecipeItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblDuration : UILabel!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblSubtitle : UILabel!
    @IBOutlet weak var lblUserName : UILabel!
    @IBOutlet weak var lblViews : UILabel!
    @IBOutlet weak var imgRecipe : UIImageView!
    @IBOutlet weak var imgThumbnail : UIImageView!
    @IBOutlet weak var clvDietaryRestriction: UICollectionView!

    var arrDietaryRestriction = [String]()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialSetupUI()
    }

    //MARK:- FUNCTION
    
    func initialSetupUI() {
        clvDietaryRestriction.register(UINib(nibName: "RecipeDietartyItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecipeDietartyItemCollectionViewCell")
        clvDietaryRestriction.delegate = self
        clvDietaryRestriction.dataSource = self
        clvDietaryRestriction.collectionViewLayout = TagsLayout()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension PopularRecipeItemCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return arrDietaryRestriction.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeDietartyItemCollectionViewCell", for: indexPath) as!  RecipeDietartyItemCollectionViewCell
        cell.lblTitle.text = arrDietaryRestriction[indexPath.row]
        cell.lblTitle.textColor = UIColor.white
        cell.lblTitle.sizeToFit()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: 20)
    }
}
