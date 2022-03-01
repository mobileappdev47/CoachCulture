//
//  GiveRecipeRattingViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 16/12/21.
//

import UIKit
import KMPlaceholderTextView
import HCSStarRatingView

class GiveRecipeRattingViewController: BaseViewController {
    
    static func viewcontroller() -> GiveRecipeRattingViewController {
        let vc = UIStoryboard(name: "Recipe", bundle: nil).instantiateViewController(withIdentifier: "GiveRecipeRattingViewController") as! GiveRecipeRattingViewController
        return vc
    }
    
    @IBOutlet weak var lblMealType: UILabel!
    @IBOutlet weak var lblRecipeDuration: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblRecipeTitle: UILabel!
    @IBOutlet weak var lblRecipeSubTitle: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblCharCount: UILabel!

    
    @IBOutlet weak var txtTellusAbout: KMPlaceholderTextView!
    
    @IBOutlet weak var viwRating: HCSStarRatingView!

    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var imgRecipeCover: UIImageView!
    @IBOutlet weak var clvDietaryRestriction: UICollectionView!
    
    var selectedId = ""
    var recipeDetailDataObj = RecipeDetailData()

    override func viewDidLoad() {
        super.viewDidLoad()
        getRecipeDetails()
        setUpUI()
    }
    
//MARK: - METHODS
    func setUpUI() {
        
       
        clvDietaryRestriction.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvDietaryRestriction.delegate = self
        clvDietaryRestriction.dataSource = self
        txtTellusAbout.delegate = self
        viwRating.allowsHalfStars = true
    }
    
    func setData() {
        lblMealType.text = recipeDetailDataObj.arrMealTypeString
        lblRecipeDuration.text = recipeDetailDataObj.duration
        clvDietaryRestriction.reloadData()
        imgRecipeCover.setImageFromURL(imgUrl: recipeDetailDataObj.thumbnail_image, placeholderImage: nil)
        
        lblUserName.text = recipeDetailDataObj.coachDetailsObj.username
        imgUserProfile.setImageFromURL(imgUrl: recipeDetailDataObj.coachDetailsObj.user_image, placeholderImage: nil)
        lblRecipeTitle.text = recipeDetailDataObj.title
        lblRecipeSubTitle.text = recipeDetailDataObj.sub_title
        lblViews.text = recipeDetailDataObj.total_viewers + "Views"
        lblDate.text = recipeDetailDataObj.created_at
                
    }
    
    // MARK: - Click events
    @IBAction func clickToBtnNext(_ sender : UIButton) {
        giveRatting()
    }

}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension GiveRecipeRattingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return recipeDetailDataObj.arrDietaryRestrictionListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MuscleItemCollectionViewCell", for: indexPath) as!  MuscleItemCollectionViewCell
        let obj = recipeDetailDataObj.arrDietaryRestrictionListData[indexPath.row]
        cell.lblTitle.text = obj.dietary_restriction_name
        cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#061424")
       
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width =  (clvDietaryRestriction.frame.width - 20 ) / 2
        return CGSize(width: width, height: 40)
    }
        
}

// MARK: - UITextViewDelegate
extension GiveRecipeRattingViewController : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let finalString = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        if finalString.count < 300 {
                      
            lblCharCount.text = "\(finalString.count)" + "/300"
            return true
        } else {
            return false
        }
        
       
    }
    
}


// MARK: - API CALL
extension GiveRecipeRattingViewController {
    func giveRatting() {
        showLoader()
        let param = ["coach_recipe_id" : self.recipeDetailDataObj.id,
                     "rating" : "\(Float(Double(self.viwRating.value)))",
                     "comments" : self.txtTellusAbout.text!]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.RECIPE_RATING, parameters: param, headers: nil) { responseObj in
            
          
            let responseModel = ResponseDataModel(responseObj: responseObj)
            Utility.shared.showToast(responseModel.message)
            self.navigationController?.popViewController(animated: true)
            
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    func getRecipeDetails() {
        showLoader()
        let param = ["id" : selectedId]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.RECIPE_DETAILS, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_recipe"] as? [String:Any] ?? [String:Any]()
            self.recipeDetailDataObj = RecipeDetailData(responseObj: dataObj)
            self.setData()
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
  
}

