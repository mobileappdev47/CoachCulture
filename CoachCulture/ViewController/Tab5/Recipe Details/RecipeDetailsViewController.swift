//
//  RecipeDetailsViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 11/12/21.
//

import UIKit

class RecipeDetailsViewController: BaseViewController {
    
    static func viewcontroller() -> RecipeDetailsViewController {
        let vc = UIStoryboard(name: "Recipe", bundle: nil).instantiateViewController(withIdentifier: "RecipeDetailsViewController") as! RecipeDetailsViewController
        return vc
    }
    @IBOutlet weak var viewMealType: UIView!
    @IBOutlet weak var viewRecipeDuration: UIView!
    
    @IBOutlet weak var lblMealType: UILabel!
    @IBOutlet weak var lblRecipeDuration: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblRecipeTitle: UILabel!
    @IBOutlet weak var lblRecipeSubTitle: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var lblDate: UILabel!

    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var imgRecipeCover: UIImageView!
    @IBOutlet weak var imgBookmark: UIImageView!

    @IBOutlet weak var btnMore: UIButton!
    
    @IBOutlet weak var clvDietaryRestriction: UICollectionView!
    @IBOutlet weak var tblIntredienta: UITableView!
    
    @IBOutlet weak var viwSatFat: UIView!
    @IBOutlet weak var viwFat: UIView!
    @IBOutlet weak var viwCarbs: UIView!
    @IBOutlet weak var viwSugar: UIView!
    @IBOutlet weak var viwProtein: UIView!
    @IBOutlet weak var viwSodium: UIView!
    @IBOutlet weak var viwNutritionFacts: UIView!
    @IBOutlet weak var viwViewRecipe: UIView!
    @IBOutlet weak var imgUserBlur: UIImageView!
    
    var recipeDetailDataObj = RecipeDetailData()
    var dropDown = DropDown()
    var recipeID = ""
    var isNew = false
    var showDetailView : ShowDetailView!
    var logOutView:LogOutView!
    var ratingListPopUp : RatingListPopUp!
    var arrClassRatingList = [ClassRatingList]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Reachability.isConnectedToNetwork(){
            getRecipeDetails()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viwNutritionFacts.roundCorners(corners: [.bottomLeft], radius: 30)
        viwViewRecipe.roundCorners(corners: [.bottomRight], radius: 30)
    }
    
    
    func setUpUI() {
        viewRecipeDuration.addCornerRadius(5.0)
        viewRecipeDuration.layer.maskedCorners = [.layerMinXMinYCorner]
        viewMealType.addCornerRadius(5.0)
        viewMealType.layer.maskedCorners = [.layerMaxXMinYCorner]

        logOutView = Bundle.main.loadNibNamed("LogOutView", owner: nil, options: nil)?.first as? LogOutView
        viwSatFat.applyBorder(4, borderColor: hexStringToUIColor(hex: "#CC2936"))
        viwFat.applyBorder(4, borderColor: hexStringToUIColor(hex: "#4DB748"))
        viwCarbs.applyBorder(4, borderColor: hexStringToUIColor(hex: "#1A82F6"))
        viwSugar.applyBorder(4, borderColor: hexStringToUIColor(hex: "#D5A82C"))
        viwProtein.applyBorder(4, borderColor: hexStringToUIColor(hex: "#FEDC31"))
        viwSodium.applyBorder(4, borderColor: hexStringToUIColor(hex: "#C731FA"))
        
        ratingListPopUp = Bundle.main.loadNibNamed("RatingListPopUp", owner: nil, options: nil)?.first as? RatingListPopUp
        
        clvDietaryRestriction.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvDietaryRestriction.delegate = self
        clvDietaryRestriction.dataSource = self
        
        imgUserBlur.setImageFromURL(imgUrl: recipeDetailDataObj.coachDetailsObj.user_image, placeholderImage: nil)
        imgUserBlur.blurImage()
        
        tblIntredienta.register(UINib(nibName: "RecipeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeIngredientTableViewCell")
        tblIntredienta.delegate = self
        tblIntredienta.dataSource = self
        tblIntredienta.layoutIfNeeded()
        
        showDetailView = Bundle.main.loadNibNamed("ShowDetailView", owner: nil, options: nil)?.first as? ShowDetailView
        
        self.showDetailView.recipeDetailDataObj = self.recipeDetailDataObj
        self.showDetailView.tblDescriptionDetail.reloadData()

        dropDown.anchorView = btnMore
        
        dropDown.cellHeight = 50
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if item.lowercased() == "Edit".lowercased() { //Edit
                let vc = CreateMealRecipeViewController.viewcontroller()
                vc.isFromEdit = true
                vc.recipeDetailDataObj = self.recipeDetailDataObj
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            if item.lowercased() == "Delete".lowercased() { //Delete
                self.addConfirmationView()
                self.deleteView()
            }
            
            if item.lowercased() == "Template".lowercased() { //Template
                let vc = CreateMealRecipeViewController.viewcontroller()
                vc.isFromEdit = true
                vc.isFromTemplate = true
                self.recipeDetailDataObj.title = ""
                self.recipeDetailDataObj.thumbnail_image = ""
                self.recipeDetailDataObj.id = ""
                vc.recipeDetailDataObj = self.recipeDetailDataObj
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            if item.lowercased() == "Ratings".lowercased() { //Rating
                
                if recipeDetailDataObj.coachDetailsObj.id == AppPrefsManager.sharedInstance.getUserData().id {
                    self.setRatingListPopUpView()
                } else {
                    let vc = GiveRecipeRattingViewController.viewcontroller()
                    vc.recipeDetailDataObj = self.recipeDetailDataObj
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
            
            if item.lowercased() == "Share".lowercased() {
                let textToShare = [ "" ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
                
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
        
        dropDown.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        dropDown.textColor = UIColor.white
        dropDown.selectionBackgroundColor = .clear
        
        
        hideTabBar()
    }
    
    func setData() {
        if self.recipeDetailDataObj.coachDetailsObj.id == AppPrefsManager.sharedInstance.getUserData().id {
            dropDown.dataSource = ["Edit", "Delete", "Template", "Ratings", "Send", "Share"]
        } else {
            dropDown.dataSource = ["Send", "Share"]
        }
        lblMealType.text = recipeDetailDataObj.arrMealTypeString
        lblRecipeDuration.text = recipeDetailDataObj.duration
        clvDietaryRestriction.reloadData()
        imgRecipeCover.setImageFromURL(imgUrl: recipeDetailDataObj.thumbnail_image, placeholderImage: nil)
        
        if recipeDetailDataObj.bookmark.lowercased() == "no".lowercased() {
            imgBookmark.image = UIImage(named: "BookmarkLight")
        } else {
            imgBookmark.image = UIImage(named: "Bookmark")
        }
        
        lblUserName.text = "@" + recipeDetailDataObj.coachDetailsObj.username
        imgUserProfile.setImageFromURL(imgUrl: recipeDetailDataObj.coachDetailsObj.user_image, placeholderImage: nil)
        lblRecipeTitle.text = recipeDetailDataObj.title
        lblRecipeSubTitle.text = recipeDetailDataObj.sub_title
        lblViews.text = recipeDetailDataObj.total_viewers + "Views"
        lblDate.text = recipeDetailDataObj.created_at
        
        showDetailView.setData(title: recipeDetailDataObj.title, SubTitle: recipeDetailDataObj.sub_title, Data: recipeDetailDataObj)
        self.showDetailView.heightDescriptionDetailTbl.constant = 0.5
        self.showDetailView.hightRecipeIngTbl.constant = 0.5
        tblIntredienta.reloadData()
    }
    
    func deleteView() {
        logOutView.lblTitle.text = "Delete Recipe?"
        logOutView.lblMessage.text = "Are you sure you would like to delete this Recipe?"
        logOutView.btnLeft.setTitle("Yes", for: .normal)
        logOutView.btnRight.setTitle("Cancel", for: .normal)
        logOutView.tapToBtnLogOut {
            if Reachability.isConnectedToNetwork(){
                self.deleteRecipeDetail()
            }
            self.removeConfirmationView()
            self.navigateToRoot()
        }
    }
    
    func addConfirmationView() {
        logOutView.frame.size = self.view.frame.size
        self.view.addSubview(logOutView)
    }
    
    func removeConfirmationView() {
        if logOutView != nil{
            logOutView.removeFromSuperview()
        }
    }
    
    func setRatingListPopUpView() {
        ratingListPopUp.frame.size = self.view.frame.size
        self.view.addSubview(ratingListPopUp)
    }
    
    func setShowDetailView() {
        showDetailView.frame.size = self.view.frame.size
        self.view.addSubview(showDetailView)
    }
    
    private func navigateToRoot() {
        for controller in navigationController!.viewControllers {
            if controller.isKind(of: EditProfileViewController.self) || controller.isKind(of: CoachViseOnDemandClassViewController.self) {
                self.navigationController?.popToViewController(controller, animated: true)
                break
            }
        }
    }

    // MARK: - Click events
    @IBAction func clickToBtnAddIngredient(_ sender : UIButton) {
       
    }
    
    @IBAction func clickToBtnNutritionFacts(_ sender : UIButton) {
       
    }
    
    @IBAction func clickToBtnViewRecipe(_ sender : UIButton) {
        setShowDetailView()
    }
    
    @IBAction func didTapUserProfile(_ sender: UIButton) {
        let vc = CoachViseOnDemandClassViewController.viewcontroller()
        vc.selectedCoachId = self.recipeDetailDataObj.coachDetailsObj.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func clickToBtnBookMark(_ sender : UIButton) {
        
        if recipeDetailDataObj.bookmark.lowercased() == "no".lowercased() {
            if Reachability.isConnectedToNetwork(){
                addOrRemoveFromBookMark(bookmark: "yes")
            }
        } else {
            if Reachability.isConnectedToNetwork(){
                addOrRemoveFromBookMark(bookmark: "no")
            }
        }
        
    }
    
    @IBAction func tapOnBack(_ sender: UIButton) {
        if isNew {
            navigateToRoot()
        } else {
            self.popVC(animated: true)
        }
    }
    
    @IBAction func clickToBtn3Dots( _ sender: UIButton) {
        dropDown.show()
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension RecipeDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return recipeDetailDataObj.arrDietaryRestrictionListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MuscleItemCollectionViewCell", for: indexPath) as!  MuscleItemCollectionViewCell
        let obj = recipeDetailDataObj.arrDietaryRestrictionListData[indexPath.row]
        cell.lblTitle.text = obj.dietary_restriction_name
        cell.lblTitle.font = UIFont(name: cell.lblTitle.font.fontName, size: 11)
        cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#061424")
       
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width =  (clvDietaryRestriction.frame.width - 20 ) / 2
        return CGSize(width: width, height: 25)
    }
        
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension RecipeDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeDetailDataObj.arrQtyIngredient.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientTableViewCell", for: indexPath) as! RecipeIngredientTableViewCell
        let obj = recipeDetailDataObj.arrQtyIngredient[indexPath.row]
        cell.selectionStyle = .none
        cell.lblQty.text = obj.quantity
        cell.lblIngredient.text = obj.ingredients
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}


// MARK: - API CALL
extension RecipeDetailsViewController {
    func getRecipeDetails() {
        showLoader()
        let param = ["id" : self.recipeID]
        
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
    
    func getClassRating() {
        //showLoader()
        let param = ["coach_class_id" : recipeID,
                     "page_no" : "1",
                     "per_page" : "10"
        ]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.RECIPE_RATING, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["data"] as? [String:Any] ?? [String:Any]()
            let coach_class_rating = dataObj["coach_class_rating"] as? [Any] ?? [Any]()
            let ratevalue = (dataObj["average_rating"] as? NSNumber)?.stringValue ?? ""
            self.arrClassRatingList = ClassRatingList.getData(data: coach_class_rating)
            self.ratingListPopUp.setData(title: self.recipeDetailDataObj.title, SubTitle: self.recipeDetailDataObj.sub_title, rateValue: ratevalue)
            self.ratingListPopUp.arrClassRatingList = self.arrClassRatingList
            self.ratingListPopUp.reloadTable()
            // self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func deleteRecipeDetail() {
        showLoader()
        let url = API.RECIPE_DELETE + recipeID
        _ =  ApiCallManager.requestApi(method: .delete, urlString: url, parameters: nil, headers: nil) { responseObj in
            Utility.shared.showToast((responseObj["message"] as? String) ?? "", title: "")
            self.popVC(animated: true)
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func addOrRemoveFromBookMark(bookmark : String) {
        showLoader()
        let param = ["coach_recipe_id" : recipeID.description,"bookmark" : bookmark]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.ADD_REMOVE_BOOKMARK, parameters: param, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            if let message = responseObj["message"] as? String, !message.isEmpty {
                Utility.shared.showToast(message)
            }

            if Reachability.isConnectedToNetwork(){
                self.getRecipeDetails()
            }
            Utility.shared.showToast(responseModel.message)
           
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
}
