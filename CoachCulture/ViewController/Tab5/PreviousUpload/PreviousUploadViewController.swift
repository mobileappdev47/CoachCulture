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
    var coach_only = "no"
    var bookmark_only = "no"
    var max_duration = ""
    var min_duration = ""
    var class_difficulty_name = ""
    
    var paramForApi = [String:Any]()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPrevoisCoachClassList()
        
    }
    
    // MARK: - Methods
    func setUpUI() {
        hideTabBar()
        
        tblOndemand.register(UINib(nibName: "PrevoisUploadItemTableViewCell", bundle: nil), forCellReuseIdentifier: "PrevoisUploadItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
        
        tblOndemand.register(UINib(nibName: "CoachViseRecipeItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseRecipeItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
        
        txtSearch.delegate = self
        
        self.tblOndemand.layoutIfNeeded()
        self.tblOndemand.reloadData()
        
        clickToBtnClassTypeForCoach(btnOnDemand)
        
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
            viwLiveLine.isHidden = false
            getPrevoisCoachClassList()
        }
        
        if sender == btnRecipe {
            viwRecipeLine.isHidden = false
            resetRecipeVariable()
            getPrevoisCoachRecipeList()
        }
        
        if sender == btnOnDemand {
            viwOnDemandLine.isHidden = false
            getPrevoisCoachClassList()
        }
    }
    
    @IBAction func clickToBtnRateNow( _ sender : UIButton) {
        let vc = LiveClassRatingViewController.viewcontroller()
        vc.selectedId = arrCoachClassPrevious[sender.tag].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToBtnFilter( _ sender : UIButton) {
        let vc = ClassFilterViewController.viewcontroller()
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension PreviousUploadViewController : UITableViewDelegate, UITableViewDataSource {
    
    
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrevoisUploadItemTableViewCell", for: indexPath) as! PrevoisUploadItemTableViewCell
            let obj = arrCoachClassPrevious[indexPath.row]
            
            cell.lblClassType.text = "On demand".uppercased()
            cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
            cell.imgClassCover.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "coverBG")
            cell.lbltitle.text = obj.class_type_name
            cell.lblClassDifficultyLevel.text = obj.class_type_name
            cell.lblClassDate.text = obj.class_subtitle
            cell.lblFollowers.text = obj.total_viewers + " Views"
            cell.lblDuration.text = obj.duration
          
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            
            if arrCoachClassPrevious.count - 1 == indexPath.row {
                
                getPrevoisCoachClassList()
            }
            return cell
        } else if viwLiveLine.isHidden == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrevoisUploadItemTableViewCell", for: indexPath) as! PrevoisUploadItemTableViewCell
            let obj = arrCoachClassPrevious[indexPath.row]
            cell.lblClassType.text = "On demand".uppercased()
            cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
            cell.imgClassCover.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "coverBG")
            cell.lbltitle.text = obj.class_type_name
            cell.lblClassDifficultyLevel.text = obj.class_type_name
            cell.lblClassDate.text = obj.class_subtitle
            cell.lblFollowers.text = obj.total_viewers + " Views"
            cell.lblDuration.text = obj.duration
            if arrCoachClassPrevious.count - 1 == indexPath.row {
                
                getPrevoisCoachClassList()
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseRecipeItemTableViewCell", for: indexPath) as! CoachViseRecipeItemTableViewCell
            
            let obj = arrCoachRecipePrevious[indexPath.row]
            cell.lbltitle.text = obj.title
            cell.lblDuration.text = obj.duration
            cell.lblRecipeType.text = obj.arrMealTypeString
            cell.arrDietaryRestriction = obj.arrdietary_restriction
            cell.clvDietaryRestriction.reloadData()
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
            
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
            vc.selectedId = arrCoachClassPrevious[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - API CALL
extension PreviousUploadViewController {
    
    func getPrevoisCoachClassList() {
        if(isDataLoading || !continueLoadingData){
            return
        }
        
        isDataLoading = true
        
        showLoader()
        let param = [ "page_no" : "\(pageNo)",
                      "per_page" : "\(perPageCount)",
                      "coach_only" : coach_only,
                      "bookmark_only" :  bookmark_only ,
                      "max_duration" : max_duration,
                      "min_duration" : min_duration,
                      "class_difficulty_name" : class_difficulty_name,
                      "subscription" : "",
                      "search" : searchString,
                      "class_type" : class_type,
        ]
        
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
        let param = [ "page_no" : "\(pageNoRecipe)",
                      "per_page" : "\(perPageCountRecipe)",
                      "meal_type" : "",
                      "dietary_restriction" : "",
                      "max_duration" : "",
                      
        ]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_RECIPE_CLASS_PREVIOUS_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_recipe_download"] as? [Any] ?? [Any]()
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
extension PreviousUploadViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        searchString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.resetVariable()
        getPrevoisCoachClassList()
    }
    
}
