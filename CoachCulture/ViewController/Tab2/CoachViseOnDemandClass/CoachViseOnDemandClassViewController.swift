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
    
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var imgClassCover: UIImageView!
    
    @IBOutlet weak var viwUserProfileContainer: UIView!
    @IBOutlet weak var viwUSubscriber: UIView!
    @IBOutlet weak var viwOnDemandLine: UIView!
    @IBOutlet weak var viwLiveLine: UIView!
    @IBOutlet weak var viwRecipeLine: UIView!
    
    @IBOutlet weak var btnOnDemand: UIButton!
    @IBOutlet weak var btnLive: UIButton!
    @IBOutlet weak var btnRecipe: UIButton!
    
    
    @IBOutlet weak var tblOndemand: UITableView!
    @IBOutlet weak var lctOndemandTableHeight: NSLayoutConstraint!
    
    var arrCoachClassInfoList = [CoachClassInfoList]()
    var coachInfoDataObj = CoachInfoData()
    var selectedCoachId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    // MARK: - Methods
    private func setUpUI() {
        viwUserProfileContainer.applyBorder(3, borderColor: hexStringToUIColor(hex: "#CC2936")) //#81747E
        clickToBtnClassTypeForCoach(btnOnDemand)
        
        tblOndemand.register(UINib(nibName: "CoachViseOnDemandClassItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseOnDemandClassItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
        
        tblOndemand.register(UINib(nibName: "CoachViseRecipeItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseRecipeItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
                
        getCoachesWiseClassList()
        
    }
    
    
    func setData() {
        
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
            getCoachesWiseClassList()
        }
        
        if sender == btnRecipe {
            viwRecipeLine.isHidden = false
        }
        
        if sender == btnOnDemand {
            viwOnDemandLine.isHidden = false
            getCoachesWiseClassList()
        }
        
       
    }
    
   
    
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension CoachViseOnDemandClassViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrCoachClassInfoList.count
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

            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseRecipeItemTableViewCell", for: indexPath) as! CoachViseRecipeItemTableViewCell
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


extension CoachViseOnDemandClassViewController {
    func getCoachesWiseClassList() {
        
        showLoader()
        let param = [ "coach_id" : selectedCoachId,
                      "type" : viwOnDemandLine.isHidden == false ? "on_demand" : "live",
                      "page_no" : "1",
                      "per_page" : "10",
        ]
        
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_COACH_WISE_CLASS_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach"] as? [String : Any] ?? [String : Any]()
            let coach_info = dataObj["coach_info"] as? [String : Any] ?? [String : Any]()
            let class_info = dataObj["class_info"] as? [ Any] ?? [ Any]()
            
            self.arrCoachClassInfoList = CoachClassInfoList.getData(data: class_info)
            self.coachInfoDataObj = CoachInfoData(responseObj: coach_info)
            self.setData()
           
            self.hideLoader()
            
        } failure: { (error) in
            return true
        }
    }
}
