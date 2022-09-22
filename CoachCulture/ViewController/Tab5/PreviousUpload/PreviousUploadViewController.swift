//
//  PreviousUploadViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 30/12/21.
//

import UIKit

class PreviousUploadViewController: BaseViewController {
    
    static func viewcontroller() -> PreviousUploadViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "PreviousUploadViewController") as! PreviousUploadViewController
        return vc
    }
    
    @IBOutlet weak var lblNoDataFound: UILabel!
    @IBOutlet weak var viewNoDataFound: UIView!
    @IBOutlet weak var viwOnDemandLine: UIView!
    @IBOutlet weak var viwLiveLine: UIView!
    @IBOutlet weak var viwRecipeLine: UIView!
    
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnOnDemand: UIButton!
    @IBOutlet weak var btnLive: UIButton!
    @IBOutlet weak var btnRecipe: UIButton!
    
    @IBOutlet weak var tblOndemand: UITableView!
    var coachInfoDataObj = CoachInfoData()
    
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
    var coach_only = "no"
    var bookmark_only = "no"
    var max_duration = ""
    var min_duration = ""
    var class_difficulty_name = ""
    var duration = ""
    var meal_type_name = ""
    var dietary_restriction_name = ""
    var previous = ""
    var isFromBookMarkPage = false
    var paramForApi = [String:Any]()
    var class_type_name = ""
    var arrCoachClassInfoList = [CoachClassInfoList]()
    var arrCoachRecipe = [PopularRecipeData]()
    var classDetailDataObj = ClassDetailData()
    var recipeDetailDataObj = RecipeDetailData()

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        if Reachability.isConnectedToNetwork() {
            getCoachesWiseClassList()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Methods
    func setUpUI() {
        hideTabBar()
        
        tblOndemand.register(UINib(nibName: "CoachViseOnDemandClassItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseOnDemandClassItemTableViewCell")
        tblOndemand.register(UINib(nibName: "CoachViseRecipeItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseRecipeItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self

        txtSearch.delegate = self
        
        self.tblOndemand.layoutIfNeeded()
        self.tblOndemand.reloadData()
        
        clickToBtnClassTypeForCoach(btnOnDemand)
        
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
    
    
    // MARK: - Methods
    @IBAction func clickToBtnClassTypeForCoach( _ sender : UIButton) {
        viwOnDemandLine.isHidden = true
        viwLiveLine.isHidden = true
        viwRecipeLine.isHidden = true
        resetVariable()
        if sender == btnLive {
            class_type = "live"
            viwLiveLine.isHidden = false
            if Reachability.isConnectedToNetwork() {
                getCoachesWiseClassList()
            }
        }
        
        if sender == btnRecipe {
            viwRecipeLine.isHidden = false
            resetRecipeVariable()
            if Reachability.isConnectedToNetwork() {
                getCoachesWiseRecipeList()
            }
        }
        
        if sender == btnOnDemand {
            class_type = "on_demand"
            viwOnDemandLine.isHidden = false
            if Reachability.isConnectedToNetwork() {
                getCoachesWiseClassList()
            }
        }
    }
    
    @IBAction func clickToBtnRateNow( _ sender : UIButton) {
        let vc = LiveClassRatingViewController.viewcontroller()
        vc.selectedId = arrCoachClassInfoList[sender.tag].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToBtnFilter( _ sender : UIButton) {
        let vc = ClassFilterViewController.viewcontroller()
        vc.isFromRecipe = viwRecipeLine.isHidden ? false : true
        vc.previousUploadVC = self
        vc.param = self.paramForApi
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension PreviousUploadViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viwOnDemandLine.isHidden == false {
            return arrCoachClassInfoList.count
        }
        
        if viwLiveLine.isHidden == false {
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
            cell.viewDuration.layer.maskedCorners = [.layerMinXMinYCorner]
            cell.lblDuration.text = obj.duration
            cell.lblClassDifficultyLevel.text = obj.class_subtitle
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "")
            cell.lbltitle.text = obj.class_type_name
            cell.lblClassDate.text = obj.created_atFormated
            cell.selectedIndex = indexPath.row
            cell.lblClassTime.text = obj.total_viewers + " Views"
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_class_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                
                if Reachability.isConnectedToNetwork(){
                    self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, recdType: SelectedDemandClass.onDemand, selectedIndex: cell.selectedIndex)
                }
            }
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            
            if arrCoachClassInfoList.count - 1 == indexPath.row {
                if Reachability.isConnectedToNetwork() {
                    getCoachesWiseClassList()
                }
            }
            return cell
        } else if viwLiveLine.isHidden == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseOnDemandClassItemTableViewCell", for: indexPath) as! CoachViseOnDemandClassItemTableViewCell
            cell.lblClassType.text = "Live".uppercased()
            cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#CC2936")
            let obj = arrCoachClassInfoList[indexPath.row]
            cell.selectedIndex = indexPath.row
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_class_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, recdType: SelectedDemandClass.live, selectedIndex: cell.selectedIndex)
            }
            cell.viewDuration.layer.maskedCorners = [.layerMinXMinYCorner]
            cell.lblDuration.text = obj.duration
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "")
            cell.lblClassDifficultyLevel.text = obj.class_subtitle
            cell.lbltitle.text = obj.class_type_name
            cell.lblClassDate.text = convertUTCToLocal(dateStr: "\(obj.class_date) \(obj.class_time)", sourceFormate: "yyyy-MM-dd HH:mm", destinationFormate: "dd MMM yyyy")
            cell.lblClassTime.text = convertUTCToLocal(dateStr: "\(obj.class_date) \(obj.class_time)", sourceFormate: "yyyy-MM-dd HH:mm", destinationFormate: "HH:mm")
            
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            
            if arrCoachClassInfoList.count - 1 == indexPath.row {
                if Reachability.isConnectedToNetwork() {
                    getCoachesWiseClassList()
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseRecipeItemTableViewCell", for: indexPath) as! CoachViseRecipeItemTableViewCell
            let obj = arrCoachRecipe[indexPath.row]
            cell.selectedIndex = indexPath.row
            cell.viewBlur.isHidden = true
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_recipe_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                self.callToAddRemoveBookmarkAPI(urlStr: API.ADD_REMOVE_BOOKMARK, params: param, recdType: SelectedDemandClass.recipe, selectedIndex: cell.selectedIndex)
            }
            cell.viewDuration.layer.maskedCorners = [.layerMinXMinYCorner]

            cell.lbltitle.text = obj.title
            cell.viewDuration.layer.maskedCorners = [.layerMinXMinYCorner]
            cell.lblDuration.text = obj.duration
            cell.lblRecipeType.text = obj.arrMealTypeString
            
            var arrFilteredDietaryRestriction = [String]()
            
            if obj.arrdietary_restriction.count > 2 {
                arrFilteredDietaryRestriction.append(obj.arrdietary_restriction[0])
                arrFilteredDietaryRestriction.append(obj.arrdietary_restriction[1])
                cell.arrDietaryRestriction = arrFilteredDietaryRestriction
            } else {
                cell.arrDietaryRestriction = obj.arrdietary_restriction
            }
            
            cell.clvDietaryRestriction.reloadData()
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "")
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            if arrCoachRecipe.count - 1 == indexPath.row {
                if Reachability.isConnectedToNetwork(){
                    getCoachesWiseRecipeList()
                }
            }
            
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
                for (index, model) in self.arrCoachClassInfoList.enumerated() {
                    if selectedIndex == index {
                        model.bookmark = model.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                        self.arrCoachClassInfoList[index] = model
                        DispatchQueue.main.async {
                            self.tblOndemand.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                        break
                    }
                }
            case SelectedDemandClass.recipe:
                for (index, model) in self.arrCoachRecipe.enumerated() {
                    if selectedIndex == index {
                        model.bookmark = model.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                        self.arrCoachRecipe[index] = model
                        DispatchQueue.main.async {
                            self.tblOndemand.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                        break
                    }
                }
            default:
                self.resetVariable()
                
                if Reachability.isConnectedToNetwork(){
                    self.getCoachesWiseClassList()
                }
            }
            
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
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
            self.getClassDetails(selectedId: Int(arrCoachClassInfoList[indexPath.row].id) ?? 0)
        } else {
            self.getClassDetails(selectedId: Int(arrCoachRecipe[indexPath.row].id) ?? 0)
        }
    }
}

//MARK: - API CALL
extension PreviousUploadViewController {
    
    func getClassDetails(selectedId: Int) {
        showLoader()
        let param = ["id" : selectedId]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.COACH_CLASS_DETAILS, parameters: param, headers: nil) { responseObj in
              
            let dataObj = responseObj["coach_class"] as? [String:Any] ?? [String:Any]()
            self.classDetailDataObj = ClassDetailData(responseObj: dataObj)
            
            if self.viwLiveLine.isHidden == false {
                let vc = ScheduleLiveClassViewController.viewcontroller()
                vc.isFromEdit = true
                vc.isFromTemplate = true
                self.classDetailDataObj.class_subtitle = ""
                self.classDetailDataObj.thumbnail_image = ""
                self.classDetailDataObj.id = ""
                vc.classDetailDataObj = self.classDetailDataObj
                self.navigationController?.pushViewController(vc, animated: true)
            } else if self.viwOnDemandLine.isHidden == false{
                let vc = OnDemandVideoUploadViewController.viewcontroller()
                vc.isFromEdit = true
                vc.isFromTemplate = true
                self.classDetailDataObj.class_subtitle = ""
                self.classDetailDataObj.thumbnail_image = ""
                self.classDetailDataObj.thumbnail_video = ""
                self.classDetailDataObj.id = ""
                vc.classDetailDataObj = self.classDetailDataObj
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = CreateMealRecipeViewController.viewcontroller()
                vc.isFromEdit = true
                vc.isFromTemplate = true
                self.recipeDetailDataObj.title = ""
                self.recipeDetailDataObj.thumbnail_image = ""
                self.recipeDetailDataObj.id = ""
                vc.recipeDetailDataObj = self.recipeDetailDataObj
                self.navigationController?.pushViewController(vc, animated: true)
            }
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func getCoachesWiseClassList() {
        if(isDataLoading || !continueLoadingData){
            return
        }
        
        isDataLoading = true
        
        showLoader()
        
        var param = [String:Any]()
        
        param["coach_id"] = AppPrefsManager.sharedInstance.getUserData().id
        param["class_type"] = class_type
        param["page_no"] = "\(pageNo)"
        param["per_page"] = "\(perPageCount)"

        if isFromBookMarkPage {
            param["bookmark_only"] = "yes"
        }
        if !class_difficulty_name.isEmpty || class_difficulty_name != "" {
            param["class_difficulty_name"] = class_difficulty_name
        }
        if !class_type_name.isEmpty || class_type_name != "" {
            param["class_type_name"] = class_type_name
        }
        if !min_duration.isEmpty || min_duration != "" {
            param["min_duration"] = min_duration
        }
        if !max_duration.isEmpty || max_duration != "" {
            param["max_duration"] = max_duration
        }
        param["template"] = true
        
        paramForApi =  param
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_COACH_WISE_CLASS_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach"] as? [String : Any] ?? [String : Any]()
            let coach_info = dataObj["coach_info"] as? [String : Any] ?? [String : Any]()
            let class_info = dataObj["class_info"] as? [ Any] ?? [ Any]()
            
            self.arrCoachClassInfoList.append(contentsOf: CoachClassInfoList.getData(data: class_info))
            self.coachInfoDataObj = CoachInfoData(responseObj: coach_info)
            DispatchQueue.main.async {
                self.tblOndemand.reloadData()
            }
            
            if self.arrCoachClassInfoList.count > 0 {
                self.viewNoDataFound.isHidden = true
            } else {
                self.viewNoDataFound.isHidden = false
                self.lblNoDataFound.text = self.class_type == CoachClassType.onDemand ? "No on demand class found" : "No live class found"
            }
            
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
        
        var param = [String:Any]()
        
        param["coach_id"] = AppPrefsManager.sharedInstance.getUserData().id
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
        if isFromBookMarkPage {
            param["bookmark_only"] = "yes"
        }
        paramForApi =  param
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_COACH_WISE_RECIPE_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach"] as? [String : Any] ?? [String : Any]()
            let recipe_info = dataObj["recipe_info"] as? [ Any] ?? [ Any]()
            
            self.arrCoachRecipe.append(contentsOf: PopularRecipeData.getData(data: recipe_info))
            
            self.arrCoachRecipe.forEach { (model) in
                model.arrdietary_restriction.sort()
            }

            self.tblOndemand.reloadData()
            
            if self.arrCoachRecipe.count > 0 {
                self.viewNoDataFound.isHidden = true
            } else {
                self.viewNoDataFound.isHidden = false
                self.lblNoDataFound.text = "No recipe found"
            }
            
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
    
}


//MARK: - UITextFieldDelegate
extension PreviousUploadViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        searchString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.resetVariable()
        //getCoachesWiseClassList()
    }
    
}
