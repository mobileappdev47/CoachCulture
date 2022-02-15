//
//  CoachClassProfileViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 03/01/22.
//

import UIKit

class CoachClassProfileViewController: BaseViewController {

    static func viewcontroller() -> CoachClassProfileViewController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "CoachClassProfileViewController") as! CoachClassProfileViewController
        return vc
    }
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblNoDataFound: UILabel!
    
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    
    @IBOutlet weak var viwOnDemandLine: UIView!
    @IBOutlet weak var viwLiveLine: UIView!
    @IBOutlet weak var viwRecipeLine: UIView!
    @IBOutlet weak var viwNoDataFound: UIView!
    
    @IBOutlet weak var btnOnDemand: UIButton!
    @IBOutlet weak var btnLive: UIButton!
    @IBOutlet weak var btnRecipe: UIButton!
    
    @IBOutlet weak var tblOndemand: UITableView!
    //@IBOutlet weak var lctOndemandTableHeight: NSLayoutConstraint!
    
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
        viwNoDataFound.isHidden = false
        clickToBtnClassTypeForCoach(btnOnDemand)
        
        tblOndemand.register(UINib(nibName: "CoachViseOnDemandClassItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseOnDemandClassItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
        
        tblOndemand.register(UINib(nibName: "CoachViseRecipeItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseRecipeItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
                
        getCoachesWiseClassList()
       
        
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
        
       
        lblUserName.text = "@" + coachInfoDataObj.username
        imgUserProfile.setImageFromURL(imgUrl: coachInfoDataObj.user_image, placeholderImage: nil)
        imgThumbnail.setImageFromURL(imgUrl: coachInfoDataObj.user_image, placeholderImage: nil)
        imgThumbnail.blurImage()
        
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
       // self.lctOndemandTableHeight.constant = self.tblOndemand.contentSize.height
        
        
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

   
    
    @IBAction func clickToBtnCoachProfile( _ sender : UIButton) {
       
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension CoachClassProfileViewController : UITableViewDelegate, UITableViewDataSource {
    
    
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
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "")
            cell.lbltitle.text = obj.class_type_name
            cell.lbltitle.text = obj.class_subtitle
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
        } else if viwLiveLine.isHidden == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseOnDemandClassItemTableViewCell", for: indexPath) as! CoachViseOnDemandClassItemTableViewCell
            cell.lblClassType.text = "Live".uppercased()
            cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#CC2936")
            
            let obj = arrCoachClassInfoList[indexPath.row]
            cell.lblDuration.text = obj.duration
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "")
            cell.lbltitle.text = obj.class_type_name
            cell.lbltitle.text = obj.class_subtitle
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
            cell.lbltitle.text = obj.title
            cell.lblDuration.text = obj.duration
            cell.lblRecipeType.text = obj.arrMealTypeString
            cell.arrDietaryRestriction = obj.arrdietary_restriction
            cell.clvDietaryRestriction.reloadData()
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
            
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
        
    }
}


extension CoachClassProfileViewController {
    func getCoachesWiseClassList() {
        
        if(isDataLoading || !continueLoadingData){
            return
        }
        
        isDataLoading = true
        
        showLoader()
        let param = [ "coach_id" : selectedCoachId,
                      "type" : viwOnDemandLine.isHidden == false ? "on_demand" : "live",
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
    
    
    
}
