//
//  MainSearchViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 18/12/21.
//

import UIKit

class MainSearchViewController: BaseViewController {
    
    
    static func viewcontrollerNav() -> UINavigationController {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "MainSearchNavVc") as! UINavigationController
        return vc
    }
    
    @IBOutlet weak var stackNoClassFoundMain: UIStackView!
    @IBOutlet weak var viewNoLiveClass: UIView!
    @IBOutlet weak var viewNoUpcommingLiveClass: UIView!
    @IBOutlet weak var viewUserProfile: UIView!
    @IBOutlet weak var imgBookmark: UIImageView!
    @IBOutlet weak var lblCoachClassType : UILabel!
    @IBOutlet weak var lbltitle : UILabel!
    @IBOutlet weak var lblDuration : UILabel!
    @IBOutlet weak var lblUserName : UILabel!
    @IBOutlet weak var lblClassDate : UILabel!
    @IBOutlet weak var lblClassTime : UILabel!
    @IBOutlet weak var lblLiveTitle : UILabel!
    @IBOutlet weak var lblOnDemandTitle : UILabel!
    
    @IBOutlet weak var imgUser : UIImageView!
    @IBOutlet weak var imgClassCover : UIImageView!
    
    @IBOutlet weak var viwLive : UIView!
    @IBOutlet weak var viwOnDemand : UIView!
    
    @IBOutlet weak var btnLive : UIButton!
    @IBOutlet weak var btnOnDemand : UIButton!
    
    @IBOutlet weak var clvClassType : UICollectionView!
    @IBOutlet weak var lctClassTypeHeight : NSLayoutConstraint!
    @IBOutlet weak var imgUserThumbnail: UIImageView!
    
    var arrClassTypeList = [ClassTypeList]()
    var upcommingLiveClassModel = UpCommingLiveClass()
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showTabBar()
        callGetUpcommingLiveClassAPI()
        getClassType()
    }
    

    // MARK: - METHODS
    
    func setUpUI() {
        self.viewUserProfile.addCornerRadius(10)
        self.viewUserProfile.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        clickToBtnClassType(btnLive)
        
        clvClassType.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvClassType.delegate = self
        clvClassType.dataSource = self
    }
    
    // MARK: - CLICK EVENTS
    
    
    @IBAction func btnBookmarkClick(_ sender: Any) {
        var param = [String:Any]()
        param[Params.AddRemoveBookmark.coach_class_id] = self.upcommingLiveClassModel.class_id
        param[Params.AddRemoveBookmark.bookmark] = self.upcommingLiveClassModel.class_bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
        self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param)
    }
    
    @IBAction func clickToBtnClassType( _ sender : UIButton) {
        
        btnLive.isSelected = false
        btnOnDemand.isSelected = false
        if sender == btnLive {
            btnLive.isSelected = true
            viwLive.backgroundColor = hexStringToUIColor(hex: "#061424")
            viwOnDemand.backgroundColor = .clear
            lblLiveTitle.textColor = hexStringToUIColor(hex: "#C12734")
            lblOnDemandTitle.textColor = hexStringToUIColor(hex: "#ffffff")
        } else {
            btnOnDemand.isSelected = true
            viwOnDemand.backgroundColor = hexStringToUIColor(hex: "#061424")
            viwLive.backgroundColor = .clear
            lblOnDemandTitle.textColor = hexStringToUIColor(hex: "#C12734")
            lblLiveTitle.textColor = hexStringToUIColor(hex: "#ffffff")
        }
    }
    
    @IBAction func clickToBtnSearch( _ sender : UIButton) {
        var str = ""
        
        for temp in arrClassTypeList {
            if temp.isSelected {
                if str.isEmpty {
                    str = temp.class_type_name
                } else {
                    str += "," + temp.class_type_name
                }
            }
        }
        
        
        let vc = SearchResultViewController.viewcontroller()
        vc.class_type = btnLive.isSelected == true ?  "live" : "on_demand"
        vc.class_type_name = str
        self.navigationController?.pushViewController(vc, animated: true)
    }

}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension MainSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        return arrClassTypeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MuscleItemCollectionViewCell", for: indexPath) as!  MuscleItemCollectionViewCell
        let obj  = arrClassTypeList[indexPath.row]
        cell.lblTitle.text = obj.class_type_name
        cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#525F6F")
        cell.lblTitle.textColor = hexStringToUIColor(hex: "#ffffff")
        
        if obj.isSelected {
            cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#061424")
            cell.lblTitle.textColor = hexStringToUIColor(hex: "#C12734")
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width =  (clvClassType.frame.width - 30 ) / 3
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        arrClassTypeList[indexPath.row].isSelected = !arrClassTypeList[indexPath.row].isSelected
        collectionView.reloadData()
    }
    
    
}


extension MainSearchViewController {
    
    func callToAddRemoveBookmarkAPI(urlStr: String, params: [String:Any]) {
        showLoader()
        _ =  ApiCallManager.requestApi(method: .post, urlString: urlStr, parameters: params, headers: nil) { responseObj in
            
            if let message = responseObj["message"] as? String, !message.isEmpty {
                Utility.shared.showToast(message)
            }
            if let bookmark = responseObj["bookmark"] as? String, !bookmark.isEmpty {
                self.upcommingLiveClassModel.class_bookmark = bookmark
                
                self.imgBookmark.image = self.upcommingLiveClassModel.class_bookmark == BookmarkType.Yes ? UIImage(named: "Bookmark") : UIImage(named: "BookmarkLight")
            }
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }
    func callGetUpcommingLiveClassAPI() {
        showLoader()
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_UPCOMMING_LIVE_CLASS_LIST, parameters: nil, headers: nil) { responseObj in
            if let upcoming_live_class = responseObj["upcoming_live_class"] as? [String:Any], upcoming_live_class.count > 0 {
                self.upcommingLiveClassModel = UpCommingLiveClass(responseObj: upcoming_live_class)
                
                if let flag_upcoming = responseObj["flag_upcoming"] as? Bool, !flag_upcoming {
                    self.stackNoClassFoundMain.isHidden = false
                    self.viewNoUpcommingLiveClass.isHidden = false
                }
                
                self.imgClassCover.setImageFromURL(imgUrl: self.upcommingLiveClassModel.thumbnail_url, placeholderImage: "")
                self.imgUserThumbnail.blurImage()
                self.imgUser.setImageFromURL(imgUrl: self.upcommingLiveClassModel.user_image, placeholderImage: "")
                self.lbltitle.text = self.upcommingLiveClassModel.class_type
                self.lblCoachClassType.text = self.upcommingLiveClassModel.class_subtitle
                self.lblUserName.text = "@\(self.upcommingLiveClassModel.username)"
                self.lblDuration.text = self.upcommingLiveClassModel.duration
                self.lblClassDate.text = convertUTCToLocal(dateStr: self.upcommingLiveClassModel.class_date, sourceFormate: "yyyy-MM-dd", destinationFormate: "dd MMM yyyy")
                self.lblClassTime.text = convertUTCToLocal(dateStr: self.upcommingLiveClassModel.class_time, sourceFormate: "HH:mm:ss", destinationFormate: "HH:mm")
                self.imgBookmark.image = self.upcommingLiveClassModel.class_bookmark == BookmarkType.Yes ? UIImage(named: "Bookmark") : UIImage(named: "BookmarkLight")
            } else {
                self.stackNoClassFoundMain.isHidden = false
                self.viewNoLiveClass.isHidden = false
            }
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func getClassType() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.CLASS_TYPE_LIST, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()
                self.arrClassTypeList = ClassTypeList.getData(data: dataObj)
                self.clvClassType.reloadData()
                self.lctClassTypeHeight.constant = self.clvClassType.collectionViewLayout.collectionViewContentSize.height
               
            }
            
            self.hideLoader()
           
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
}
