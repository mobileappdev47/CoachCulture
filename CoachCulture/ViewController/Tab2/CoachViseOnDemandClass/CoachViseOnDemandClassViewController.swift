//
//  CoachViseOnDemandClassViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit

class CoachViseOnDemandClassViewController: BaseViewController {
    
    static func viewcontroller() -> CoachViseOnDemandClassViewController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "CoachViseOnDemandClassViewController") as! CoachViseOnDemandClassViewController
        return vc
    }
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblFees: UILabel!
    @IBOutlet weak var lblNoDataFound: UILabel!
    
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var imgClassCover: UIImageView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var imgSubscription: UIImageView!
    @IBOutlet weak var imgMovieIcon: UIImageView!
    
    @IBOutlet weak var viwUserProfileContainer: UIView!
    @IBOutlet weak var viwUSubscriber: UIView!
    @IBOutlet weak var viwOnDemandLine: UIView!
    @IBOutlet weak var viwLiveLine: UIView!
    @IBOutlet weak var viwRecipeLine: UIView!
    @IBOutlet weak var viwNoDataFound: UIView!
    @IBOutlet weak var viwCoachProfile: UIView!
    @IBOutlet weak var viwOtherCoachProfile: UIView!
    
    @IBOutlet weak var btnOnDemand: UIButton!
    @IBOutlet weak var btnLive: UIButton!
    @IBOutlet weak var btnRecipe: UIButton!
    
    @IBOutlet weak var tblOndemand: UITableView!
    @IBOutlet weak var lctOndemandTableHeight: NSLayoutConstraint!
    
    var arrCoachClassInfoList = [CoachClassInfoList]()
    var coachInfoDataObj = CoachInfoData()
    var selectedCoachId = ""
    var arrCoachRecipe = [PopularRecipeData]()
    
    var isDataLoading = false
    var continueLoadingData = true
    var pageNo = 1
    var perPageCount = 10
    
    var isDataLoadingRecipe = false
    var continueLoadingDataRecipe = true
    var pageNoRecipe = 1
    var perPageCountRecipe = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    // MARK: - Methods
    
    private func setUpUI() {
        hideTabBar()
        viwNoDataFound.isHidden = false
        viwCoachProfile.isHidden = true
        viwUserProfileContainer.applyBorder(3, borderColor: hexStringToUIColor(hex: "#CC2936")) //#81747E
        clickToBtnClassTypeForCoach(btnOnDemand)
        
        tblOndemand.register(UINib(nibName: "CoachViseOnDemandClassItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseOnDemandClassItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
        
        tblOndemand.register(UINib(nibName: "CoachViseRecipeItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseRecipeItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
        
        getCoachesWiseClassList()
        getCoacheSearchHistory()
        
    }
    
    func resetVariable() {
        arrCoachClassInfoList.removeAll()
        isDataLoading = false
        continueLoadingData = true
        pageNo = 1
        perPageCount = 10
    }
    
    func resetRecipeVariable() {
        arrCoachRecipe.removeAll()
        isDataLoadingRecipe = false
        continueLoadingDataRecipe = true
        pageNoRecipe = 1
        perPageCountRecipe = 10
    }
    
    
    func setData() {
        
        if selectedCoachId == AppPrefsManager.sharedInstance.getUserData().id {
            viwCoachProfile.isHidden = false
            viwOtherCoachProfile.isHidden = true
            viwUserProfileContainer.applyBorder(3, borderColor: hexStringToUIColor(hex: "#81747E")) //
            imgMovieIcon.image = UIImage(named: "grayMovieIcon")
        }
        
        lblFees.text =  coachInfoDataObj.monthly_subscription_fee
        lblUserName.text = "@" + coachInfoDataObj.username
        lblFollowers.text =  coachInfoDataObj.total_followers + " Followers"
        imgUserProfile.setImageFromURL(imgUrl: coachInfoDataObj.user_image, placeholderImage: nil)
        imgThumbnail.setImageFromURL(imgUrl: coachInfoDataObj.user_image, placeholderImage: nil)
        imgThumbnail.blurImage()
        if coachInfoDataObj.user_subscribed == "no" {
            imgSubscription.isHidden = true
        } else {
            imgSubscription.isHidden = false
        }
        if viwOnDemandLine.isHidden == false  {
            lblNoDataFound.text = "No demand class found"
            viwNoDataFound.isHidden = arrCoachClassInfoList.count > 0
        }
        if viwLiveLine.isHidden == false {
            lblNoDataFound.text = "No live class found"
            viwNoDataFound.isHidden = arrCoachClassInfoList.count > 0
        }
        
        if viwRecipeLine.isHidden == false {
            lblNoDataFound.text = "No recipe class found"
            viwNoDataFound.isHidden = arrCoachRecipe.count > 0
        }
        
        self.tblOndemand.layoutIfNeeded()
        self.tblOndemand.reloadData()
        self.lctOndemandTableHeight.constant = self.tblOndemand.contentSize.height
        
        
    }
    
    // MARK: - CLICK EVENTS
    @IBAction func clickToBtnClassTypeForCoach( _ sender : UIButton) {
        viwOnDemandLine.isHidden = true
        viwLiveLine.isHidden = true
        viwRecipeLine.isHidden = true
        
        if sender == btnLive {
            viwLiveLine.isHidden = false
            resetVariable()
            getCoachesWiseClassList()
        }
        
        if sender == btnRecipe {
            viwRecipeLine.isHidden = false
            resetRecipeVariable()
            getCoachesWiseRecipeList()
        }
        
        if sender == btnOnDemand {
            viwOnDemandLine.isHidden = false
            resetVariable()
            getCoachesWiseClassList()
        }
        
    }
    
    @IBAction func clickToBtnAddFollow( _ sender : UIButton) {
        addRemoveFollowers()
    }
    
    @IBAction func clickToBtnCoachProfile( _ sender : UIButton) {
        let vc = CoachClassProfileViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension CoachViseOnDemandClassViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viwOnDemandLine.isHidden == false || viwLiveLine.isHidden == false {
            return arrCoachClassInfoList.count
        }
        return arrCoachRecipe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if viwOnDemandLine.isHidden == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseOnDemandClassItemTableViewCell", for: indexPath) as! CoachViseOnDemandClassItemTableViewCell
            
            cell.lblClassType.text = "On demand".uppercased()
            cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
            let obj = arrCoachClassInfoList[indexPath.row]
            cell.lblDuration.text = obj.duration
            cell.lblClassDifficultyLevel.text = obj.class_subtitle
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "")
            cell.lbltitle.text = obj.class_type_name
            cell.lblClassDate.text = obj.created_atFormated
            cell.lblClassTime.text = obj.total_viewers + " Views"
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_class_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, sender: self.btnOnDemand)
            }
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            
            if arrCoachClassInfoList.count - 1 == indexPath.row {
                
                getCoachesWiseClassList()
            }
            
            
            return cell
        } else if viwLiveLine.isHidden == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseOnDemandClassItemTableViewCell", for: indexPath) as! CoachViseOnDemandClassItemTableViewCell
            cell.lblClassType.text = "Live".uppercased()
            cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#CC2936")
            let obj = arrCoachClassInfoList[indexPath.row]
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_class_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, sender: self.btnLive)
            }
            cell.lblDuration.text = obj.duration
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "")
            cell.lblClassDifficultyLevel.text = obj.class_subtitle
            cell.lbltitle.text = obj.class_type_name
            cell.lblClassDate.text = obj.created_atFormated
            cell.lblClassTime.text = obj.total_viewers + " Views"
            
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            
            if arrCoachClassInfoList.count - 1 == indexPath.row {
                
                getCoachesWiseClassList()
            }
            
            
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseRecipeItemTableViewCell", for: indexPath) as! CoachViseRecipeItemTableViewCell
            let obj = arrCoachRecipe[indexPath.row]
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_recipe_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                self.callToAddRemoveBookmarkAPI(urlStr: API.ADD_REMOVE_BOOKMARK, params: param, sender: self.btnRecipe)
            }
            cell.lbltitle.text = obj.title
            cell.lblDuration.text = obj.duration
            cell.lblRecipeType.text = obj.arrMealTypeString
            cell.arrDietaryRestriction = obj.arrdietary_restriction
            cell.clvDietaryRestriction.reloadData()
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            if arrCoachRecipe.count - 1 == indexPath.row {
                
                getCoachesWiseRecipeList()
            }
            
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viwOnDemandLine.isHidden == false || viwLiveLine.isHidden == false {
            let vc = LiveClassDetailsViewController.viewcontroller()
            let obj = arrCoachClassInfoList[indexPath.row]
            vc.selectedId = obj.id
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = RecipeDetailsViewController.viewcontroller()
            let obj = arrCoachRecipe[indexPath.row]
            vc.recipeID = obj.id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}


extension CoachViseOnDemandClassViewController {
    func getCoachesWiseClassList() {
        
        if(isDataLoading || !continueLoadingData){
            return
        }
        
        isDataLoading = true
        
        showLoader()
        let param = [ "coach_id" : selectedCoachId,
                      "class_type" : viwOnDemandLine.isHidden == false ? "on_demand" : "live",
                      "page_no" : pageNo,
                      "per_page" : perPageCount,
        ] as [String : Any]
        
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_COACH_WISE_CLASS_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach"] as? [String : Any] ?? [String : Any]()
            let coach_info = dataObj["coach_info"] as? [String : Any] ?? [String : Any]()
            let class_info = dataObj["class_info"] as? [ Any] ?? [ Any]()
            
            self.arrCoachClassInfoList.append(contentsOf: CoachClassInfoList.getData(data: class_info))
            self.coachInfoDataObj = CoachInfoData(responseObj: coach_info)
            self.setData()
            
            if class_info.count < self.perPageCount
            {
                self.continueLoadingData = false
            }
            self.isDataLoading = false
            self.pageNo += 1
            
            self.hideLoader()
            
        } failure: { (error) in
            return true
        }
    }
    
    func getCoachesWiseRecipeList() {
        
        if(isDataLoadingRecipe || !continueLoadingDataRecipe){
            return
        }
        
        isDataLoadingRecipe = true
        showLoader()
        let param = [ "coach_id" : selectedCoachId,
                      "page_no" : pageNoRecipe,
                      "per_page" : perPageCountRecipe,
        ] as [String : Any]
        
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_COACH_WISE_RECIPE_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach"] as? [String : Any] ?? [String : Any]()
            let recipe_info = dataObj["recipe_info"] as? [ Any] ?? [ Any]()
            
            self.arrCoachRecipe.append(contentsOf: PopularRecipeData.getData(data: recipe_info))
            self.setData()
            
            if recipe_info.count < self.perPageCountRecipe
            {
                self.continueLoadingDataRecipe = false
            }
            self.isDataLoadingRecipe = false
            self.pageNoRecipe += 1
            
            self.hideLoader()
            
        } failure: { (error) in
            return true
        }
    }
    
    func getCoacheSearchHistory() {
        let param = [ "search_coach_id" : selectedCoachId,
                      
        ] as [String : Any]
        
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_COACH_SEARCH_HISTORY, parameters: param, headers: nil) { responseObj in
            
            
        } failure: { (error) in
            return true
        }
    }
    
    func addRemoveFollowers() {
        showLoader()
        let param = [ "coach_id" : selectedCoachId,
                      "status" : "yes",
                      
        ] as [String : Any]
        
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.ADD_REMOVE_FOLLOWERS, parameters: param, headers: nil) { responseObj in
            
            let responseObj = ResponseDataModel(responseObj: responseObj)
            Utility.shared.showToast(responseObj.message)
            self.hideLoader()
            
        } failure: { (error) in
            return true
        }
    }
    
    func callToAddRemoveBookmarkAPI(urlStr: String, params: [String:Any], sender : UIButton) {
        showLoader()
        _ =  ApiCallManager.requestApi(method: .post, urlString: urlStr, parameters: params, headers: nil) { responseObj in
            self.clickToBtnClassTypeForCoach(sender)
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }
}
