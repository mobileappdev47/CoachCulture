//
//  PreviousClassesViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 22/12/21.
//

import UIKit

class PreviousClassesViewController: BaseViewController {
    
    static func viewcontroller() -> PreviousClassesViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "PreviousClassesViewController") as! PreviousClassesViewController
        return vc
    }
    
    @IBOutlet weak var viwOnDemandLine: UIView!
    @IBOutlet weak var viwLiveLine: UIView!
    @IBOutlet weak var viwRecipeLine: UIView!
    
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnOnDemand: UIButton!
    @IBOutlet weak var btnLive: UIButton!
    @IBOutlet weak var btnRecipe: UIButton!
    
    @IBOutlet weak var tblOndemand: UITableView!
    var arrCoachClassPrevious = [CoachClassPrevious]()
    var arrCoachRecipePrevious = [PopularRecipeData]()
    
    
    var isDataLoading = false
    var continueLoadingData = true
    var pageNo = 1
    var perPageCount = 10
    
    var isDataLoadingRecipe = false
    var continueLoadingDataRecipe = true
    var pageNoRecipe = 1
    var perPageCountRecipe = 10
    
    var searchString = ""
    var class_type = "on_demand"
    var class_type_name = ""
    var coach_only = "no"
    var bookmark_only = "no"
    var max_duration = ""
    var min_duration = ""
    var class_difficulty_name = ""
    var meal_type_name = ""
    var dietary_restriction_name = ""
    var duration = ""
    var isFromBookMarkPage = false
    var paramForApi = [String:Any]()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        getPrevoisCoachClassList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    // MARK: - Methods
    func setUpUI() {
        hideTabBar()
        
        tblOndemand.register(UINib(nibName: "SearchResultItemTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchResultItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
        
        tblOndemand.register(UINib(nibName: "CoachViseRecipeItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseRecipeItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
        
        txtSearch.delegate = self
        
        self.tblOndemand.layoutIfNeeded()
        self.tblOndemand.reloadData()
        
        clickToBtnClassTypeForCoach(btnOnDemand)
        
        lblTitle.text = "Previous Classes"
        if isFromBookMarkPage {
            lblTitle.text = "Bookmark Classes"
        }
        
    }
    
    func resetVariable() {
        arrCoachClassPrevious.removeAll()
        isDataLoading = false
        continueLoadingData = true
        pageNo = 1
        perPageCount = 10
    }
    
    func resetRecipeVariable() {
        arrCoachRecipePrevious.removeAll()
        isDataLoadingRecipe = false
        continueLoadingDataRecipe = true
        pageNoRecipe = 1
        perPageCountRecipe = 10
    }
    
    
    // MARK: - Methods
    @IBAction func clickToBtnClassTypeForCoach( _ sender : UIButton) {
        viwOnDemandLine.isHidden = true
        viwLiveLine.isHidden = true
        viwRecipeLine.isHidden = true
        resetVariable()
        if sender == btnLive {
            class_type = "live"
            viwLiveLine.isHidden = false
            getPrevoisCoachClassList()
        }
        
        if sender == btnRecipe {
            viwRecipeLine.isHidden = false
            resetRecipeVariable()
            getPrevoisCoachRecipeList()
        }
        
        if sender == btnOnDemand {
            class_type = "on_demand"
            viwOnDemandLine.isHidden = false
            getPrevoisCoachClassList()
        }
    }
    
    // MARK: - Click Events
    @IBAction func clickToBtnClassFilter( _ sender : UIButton) {
        
    }
    
    @IBAction func clickToBtnRateNow( _ sender : UIButton) {
        if viwRecipeLine.isHidden == true {
            let vc = LiveClassRatingViewController.viewcontroller()
            vc.selectedId = arrCoachClassPrevious[sender.tag].id
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = GiveRecipeRattingViewController.viewcontroller()
            vc.selectedId = arrCoachRecipePrevious[sender.tag].id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func clickToBtnUser( _ sender : UIButton) {
        let vc = CoachViseOnDemandClassViewController.viewcontroller()
        if viwRecipeLine.isHidden == true {
            vc.selectedCoachId = self.arrCoachClassPrevious[sender.tag].coachDetailsObj.id
        } else {
            vc.selectedCoachId = self.arrCoachRecipePrevious[sender.tag].coachDetailsObj.id
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToBtnFilter( _ sender : UIButton) {
        let vc = ClassFilterViewController.viewcontroller()
        vc.isFromRecipe = viwRecipeLine.isHidden ? false : true
        vc.previousClassVC = self
        vc.isFromBookMarkPage = self.isFromBookMarkPage
        vc.param = self.paramForApi
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension PreviousClassesViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viwOnDemandLine.isHidden == false {
            return arrCoachClassPrevious.count
        }
        
        if viwLiveLine.isHidden == false {
            return arrCoachClassPrevious.count
        }
        return arrCoachRecipePrevious.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if viwOnDemandLine.isHidden == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultItemTableViewCell", for: indexPath) as! SearchResultItemTableViewCell
            let obj = arrCoachClassPrevious[indexPath.row]
            cell.viewBlur.isHidden = false
            cell.lblClassType.text = "On demand".uppercased()
            cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
            cell.imgUser.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "coverBG")
            if cell.imgThumbnail.image == nil {
                cell.imgThumbnail.blurImage()
            }
            cell.imgThumbnail.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "coverBG")
            cell.imgClassCover.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "coverBG")
            cell.lbltitle.text = obj.class_type_name
            cell.lblClassDifficultyLevel.text = obj.class_type_name
            cell.lblClassDate.text = obj.class_subtitle
            cell.lblUserName.text = "@" + obj.coachDetailsObj.username
            cell.lblClassTime.text = obj.total_viewers + " Views"
            cell.lblDuration.text = obj.duration
            let str = obj.average_rating
            if let num = NumberFormatter().number(from: str) {
                let f = CGFloat(truncating: num)
                cell.viwRating.value = f
            }
            cell.viewProfile.addCornerRadius(10)
            cell.viewProfile.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            cell.selectedIndex = indexPath.row
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            cell.btnRating.tag = indexPath.row
            cell.btnRating.addTarget(self, action: #selector(self.clickToBtnRateNow(_:)), for: .touchUpInside)
            cell.btnUser.tag = indexPath.row
            cell.btnUser.addTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)
            
            if arrCoachClassPrevious.count - 1 == indexPath.row {
                
                getPrevoisCoachClassList()
            }
            if isFromBookMarkPage {
                cell.viewBlur.isHidden = true
                cell.btnBookmark.isEnabled = true
            } else {
                cell.viewBlur.isHidden = false
                cell.btnBookmark.isEnabled = false
                cell.didTapBookmarkButton = {
                    var param = [String:Any]()
                    param[Params.AddRemoveBookmark.coach_class_id] = obj.id
                    param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                    self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, recdType: SelectedDemandClass.onDemand, selectedIndex: cell.selectedIndex)
                }
            }
            return cell
        } else if viwLiveLine.isHidden == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultItemTableViewCell", for: indexPath) as! SearchResultItemTableViewCell
            cell.viewBlur.isHidden = false
            let obj = arrCoachClassPrevious[indexPath.row]
            cell.lblClassType.text = "Live".uppercased()
            cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#CC2936")
            cell.imgUser.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "coverBG")
            cell.btnUser.tag = indexPath.row
            cell.btnUser.addTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)
            if cell.imgThumbnail.image == nil {
                cell.imgThumbnail.blurImage()
            }
            cell.imgThumbnail.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "coverBG")
            cell.imgClassCover.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "coverBG")
            cell.lbltitle.text = obj.class_type_name
            cell.lblClassDifficultyLevel.text = obj.class_type_name
            cell.lblClassDate.text = obj.class_subtitle
            cell.lblUserName.text = "@" + obj.coachDetailsObj.username
            cell.lblClassTime.text = obj.total_viewers + " Views"
            cell.lblDuration.text = obj.duration
            let str = obj.average_rating
            if let num = NumberFormatter().number(from: str) {
                let f = CGFloat(truncating: num)
                cell.viwRating.value = f
            }
            if !obj.userRatingObj.rating.isEmpty {
                cell.viwRating.value = CGFloat(Double(obj.userRatingObj.rating)!)
            }
            cell.selectedIndex = indexPath.row
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            cell.btnRating.tag = indexPath.row
            cell.btnRating.addTarget(self, action: #selector(self.clickToBtnRateNow(_:)), for: .touchUpInside)
            
            if arrCoachClassPrevious.count - 1 == indexPath.row {
                
                getPrevoisCoachClassList()
            }
            if isFromBookMarkPage {
                cell.viewBlur.isHidden = true
                cell.btnBookmark.isEnabled = true
            } else {
                cell.viewBlur.isHidden = false
                cell.btnBookmark.isEnabled = false
                cell.didTapBookmarkButton = {
                    var param = [String:Any]()
                    param[Params.AddRemoveBookmark.coach_class_id] = obj.id
                    param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                    self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, recdType: SelectedDemandClass.live, selectedIndex: cell.selectedIndex)
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseRecipeItemTableViewCell", for: indexPath) as! CoachViseRecipeItemTableViewCell
            cell.viewBlur.isHidden = false
            let obj = arrCoachRecipePrevious[indexPath.row]
            cell.lbltitle.text = obj.title
            cell.lblUsername.text = "@" + obj.coachDetailsObj.username
            cell.lblDuration.text = obj.duration
            cell.lblRecipeType.text = obj.meal_type_name
            cell.arrDietaryRestriction = obj.arrdietary_restriction
            cell.clvDietaryRestriction.reloadData()
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
            cell.selectedIndex = indexPath.row
            cell.viewProfile.isHidden = false
            cell.viewProfile.addCornerRadius(10)
            let str = obj.average_rating
            if let num = NumberFormatter().number(from: str) {
                let f = CGFloat(truncating: num)
                cell.starRating.value = f
            }
            cell.btnRating.tag = indexPath.row
            cell.btnRating.addTarget(self, action: #selector(self.clickToBtnRateNow(_:)), for: .touchUpInside)
            cell.btnUser.tag = indexPath.row
            cell.btnUser.addTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)
            cell.viewProfile.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            if cell.imgProfileBottom.image == nil {
                cell.imgProfileBottom.blurImage()
            }
            cell.imgProfileBottom.setImageFromURL(imgUrl: obj.coach_image, placeholderImage: "")
            cell.imgProfileBanner.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "")
            
            let arrSeperatedDietaryRestriction = obj.dietary_restriction_name.components(separatedBy: ",")
            var arrFilteredDietaryRestriction = [String]()
            if arrSeperatedDietaryRestriction.count > 2 {
                arrFilteredDietaryRestriction.append(arrSeperatedDietaryRestriction[0])
                arrFilteredDietaryRestriction.append(arrSeperatedDietaryRestriction[1])
                cell.arrDietaryRestriction = arrFilteredDietaryRestriction
            } else {
                cell.arrDietaryRestriction = arrSeperatedDietaryRestriction
            }
            cell.arrDietaryRestriction = obj.arrdietary_restriction

            cell.clvDietaryRestriction.reloadData()
            if isFromBookMarkPage {
                cell.viewBlur.isHidden = true
                cell.btnBookMark.isEnabled = true
            } else {
                cell.viewBlur.isHidden = false
                cell.btnBookMark.isEnabled = false
                cell.didTapBookmarkButton = {
                    var param = [String:Any]()
                    param[Params.AddRemoveBookmark.coach_recipe_id] = obj.id
                    param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                    self.callToAddRemoveBookmarkAPI(urlStr: API.ADD_REMOVE_BOOKMARK, params: param, recdType: SelectedDemandClass.recipe, selectedIndex: cell.selectedIndex)
                }
            }
            cell.imgBookMark.image = obj.bookmark == BookmarkType.Yes ? UIImage(named: "BookmarkLight") : UIImage(named: "Bookmark")
            
            return cell
        }
        
        
    }
    
    func callToAddRemoveBookmarkAPI(urlStr: String, params: [String:Any], recdType : String, selectedIndex: Int) {
        showLoader()
        _ =  ApiCallManager.requestApi(method: .post, urlString: urlStr, parameters: params, headers: nil) { responseObj in
            
            if let message = responseObj["message"] as? String, !message.isEmpty {
                Utility.shared.showToast(message)
            }
            switch recdType {
            case SelectedDemandClass.onDemand, SelectedDemandClass.live:
                for (index, model) in self.arrCoachClassPrevious.enumerated() {
                    if selectedIndex == index {
                        model.bookmark = model.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                        self.arrCoachClassPrevious[index] = model
                        DispatchQueue.main.async {
                            self.tblOndemand.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                        break
                    }
                }
            case SelectedDemandClass.recipe:
                for (index, model) in self.arrCoachRecipePrevious.enumerated() {
                    if selectedIndex == index {
                        model.bookmark = model.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                        self.arrCoachRecipePrevious[index] = model
                        DispatchQueue.main.async {
                            self.tblOndemand.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                        break
                    }
                }
            default:
                self.resetVariable()
                self.getPrevoisCoachClassList()
            }
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viwOnDemandLine.isHidden == false || viwLiveLine.isHidden == false {
            let vc = LiveClassDetailsViewController.viewcontroller()
            vc.selectedId = arrCoachClassPrevious[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = RecipeDetailsViewController.viewcontroller()
            let obj = arrCoachRecipePrevious[indexPath.row]
            vc.recipeID = obj.id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - API CALL
extension PreviousClassesViewController {
    
    func getPrevoisCoachClassList() {
        if(isDataLoading || !continueLoadingData){
            return
        }
        isDataLoading = true
        showLoader()
        
        var param = [String:Any]()
        if isFromBookMarkPage {
            param["bookmark_only"] = "yes"
        }
        if !class_difficulty_name.isEmpty || class_difficulty_name != "" {
            param["class_difficulty_name"] = class_difficulty_name
        }
        if !min_duration.isEmpty || min_duration != "" {
            param["min_duration"] = min_duration
        }
        if !max_duration.isEmpty || max_duration != "" {
            param["max_duration"] = max_duration
        }
        if !class_type_name.isEmpty || class_type_name != "" {
            param["class_type_name"] = class_type_name
        }
        
        param["page_no"] = "\(pageNo)"
        param["per_page"] = "\(perPageCount)"
        param["class_type"] = class_type
        
        paramForApi =  param
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_FILTER_CLASS_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_class_list"] as? [Any] ?? [Any]()
            let arr = CoachClassPrevious.getData(data: dataObj)
            self.arrCoachClassPrevious.append(contentsOf: arr)
            self.tblOndemand.reloadData()
            
            if arr.count < self.perPageCount
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
    
    
    func getPrevoisCoachRecipeList() {
        if(isDataLoadingRecipe || !continueLoadingDataRecipe){
            return
        }
        
        isDataLoadingRecipe = true
        
        showLoader()
        
        var param = [String:Any]()
        
        param["page_no"] = "\(pageNoRecipe)"
        param["per_page"] = "\(perPageCountRecipe)"
        if !duration.isEmpty || duration != "" {
            param["duration"] = duration
        }
        if !meal_type_name.isEmpty || meal_type_name != "" {
            param["meal_type_name"] = meal_type_name
        }
        if !dietary_restriction_name.isEmpty || dietary_restriction_name != "" {
            param["dietary_restriction_name"] = dietary_restriction_name
        }
        if !searchString.isEmpty || searchString != "" {
            param["search"] = searchString
        }
        
        var url = API.GET_ALL_COACH_RECIPE_LIST
        if isFromBookMarkPage {
            url = API.GET_USER_BOOKMARK_LIST
        } else {
            param["bookmark_only"] = "no"
            param["previous"] = "yes"
            param["coach_only"] = coach_only
        }
        paramForApi =  param
        _ =  ApiCallManager.requestApi(method: .post, urlString: url, parameters: param, headers: nil) { responseObj in
            
            var dataObj = [Any]()
            if self.isFromBookMarkPage {
                dataObj = responseObj["coach_recipe_bookmark"] as? [Any] ?? [Any]()
            } else {
                dataObj = responseObj["coach_recipe_list"] as? [Any] ?? [Any]()
            }
            let arr = PopularRecipeData.getData(data: dataObj)
            self.arrCoachRecipePrevious.append(contentsOf: arr)
            self.tblOndemand.reloadData()
            
            if arr.count < self.perPageCountRecipe
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
    
}


//MARK: - UITextFieldDelegate
extension PreviousClassesViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        searchString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.resetVariable()
        getPrevoisCoachClassList()
    }
    
}
