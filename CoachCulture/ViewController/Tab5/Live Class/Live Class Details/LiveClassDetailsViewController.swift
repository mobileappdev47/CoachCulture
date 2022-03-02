//
//  LiveClassDetailsViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 15/12/21.
//

import UIKit
import AVKit
import AVFoundation

class LiveClassDetailsViewController: BaseViewController {
    
    static func viewcontroller() -> LiveClassDetailsViewController {
        let vc = UIStoryboard(name: "Recipe", bundle: nil).instantiateViewController(withIdentifier: "LiveClassDetailsViewController") as! LiveClassDetailsViewController
        return vc
    }
    
    @IBOutlet weak var lblViewRecipeBottomButton: UILabel!
    @IBOutlet weak var imgViewRecipeBottomButton: UIImageView!
    @IBOutlet weak var viewRecipeBottomButton: UIView!
    @IBOutlet weak var viewDuration: UIView!
    @IBOutlet weak var viewClassDifficultyLevel: UIView!
    @IBOutlet weak var btnBookmark: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    
    @IBOutlet weak var lblClassStartIn: UILabel!
    @IBOutlet weak var lblClassType: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblClassTitle: UILabel!
    @IBOutlet weak var lblClassSubTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblCal: UILabel!
    @IBOutlet weak var lblTimeDuration1: UILabel!
    @IBOutlet weak var lblOneTimeFee: UILabel!
    @IBOutlet weak var lblNonSubscriberFee: UILabel!
    @IBOutlet weak var lblClassDifficultyLevel: UILabel!
    @IBOutlet weak var lblMoreIngredients: UILabel!
    
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var imgThumbNail: UIImageView!
    @IBOutlet weak var imgClassCover: UIImageView!
    @IBOutlet weak var imgBookmark: UIImageView!
    @IBOutlet weak var imgDownload: UIImageView!
    
    @IBOutlet weak var tblEquipment: UITableView!
    
    @IBOutlet weak var viwCal: UIView!
    @IBOutlet weak var viwDuration: UIView!
    @IBOutlet weak var viwClassDescription: UIView!
    @IBOutlet weak var viwClassType: UIView!
    @IBOutlet weak var viwMoreIngredient: UIView!
    @IBOutlet weak var viwClassStartIn: UIView!
    
    var classDetailDataObj = ClassDetailData()
    var dropDown = DropDown()
    var classDescriptionView : ClassDescriptionView!
    var selectedId = ""
    var arrLocalCoachClassData = [Any]()
    var isClassDownloaded = false
    var isFromClassDownloadedPage = false
    var ratingListPopUp : RatingListPopUp!
    var arrClassRatingList = [ClassRatingList]()
    var bottomDetailView = BottomDetailView()
    var logOutView:LogOutView!
    var timer = Timer()
    var counter = 0.0
    var userCoachHistoryID : Int?
    var isStatusUpdatedForVideoEnd = false
    var isNew = false
    var deleteID = Int()
    var isFromSubscriptionPurchase = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    private func setUpUI() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didCompletePlaying),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: nil
        )

        logOutView = Bundle.main.loadNibNamed("LogOutView", owner: nil, options: nil)?.first as? LogOutView
        hideTabBar()
        arrLocalCoachClassData = AppPrefsManager.sharedInstance.getClassDataJson()
        
        dropDown.anchorView = btnMore
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if item.lowercased() == "Edit".lowercased() { //Edit
                
                if classDetailDataObj.coach_class_type == CoachClassType.live {
                    let vc = ScheduleLiveClassViewController.viewcontroller()
                    vc.isFromEdit = true
                    vc.classDetailDataObj = self.classDetailDataObj
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = OnDemandVideoUploadViewController.viewcontroller()
                    vc.isFromEdit = true
                    vc.classDetailDataObj = self.classDetailDataObj
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            if item.lowercased() == "Delete".lowercased() { //Delete
                self.deleteClass()
            }
            
            if item.lowercased() == "Rate Class".lowercased() { //Rating
                
                if classDetailDataObj.coachDetailsDataObj.id == AppPrefsManager.sharedInstance.getUserData().id {
                    self.setRatingListPopUpView()
                } else {
                    let vc = LiveClassRatingViewController.viewcontroller()
                    vc.selectedId = self.classDetailDataObj.id
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
        }
        dropDown.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        dropDown.textColor = UIColor.white
        dropDown.selectionBackgroundColor = .clear
        
        viwCal.applyBorder(4.0, borderColor: hexStringToUIColor(hex: "#CC2936"))
        viwDuration.applyBorder(4.0, borderColor: hexStringToUIColor(hex: "#1A82F6"))
        viwClassDescription.applyBorder(2.0, borderColor: hexStringToUIColor(hex: "#ffffff"))
        
        
        tblEquipment.register(UINib(nibName: "LiveClassEquipmentItemTableViewCell", bundle: nil), forCellReuseIdentifier: "LiveClassEquipmentItemTableViewCell")
        tblEquipment.delegate = self
        tblEquipment.dataSource = self
        tblEquipment.layoutIfNeeded()
        tblEquipment.reloadData()
        
        classDescriptionView = Bundle.main.loadNibNamed("ClassDescriptionView", owner: nil, options: nil)?.first as? ClassDescriptionView
        classDescriptionView.tapToBtnOk {
            self.classDescriptionView.removeFromSuperview()
        }
        
        ratingListPopUp = Bundle.main.loadNibNamed("RatingListPopUp", owner: nil, options: nil)?.first as? RatingListPopUp
        
        bottomDetailView = Bundle.main.loadNibNamed("BottomDetailView", owner: nil, options: nil)?.first as! BottomDetailView
        
        if isFromClassDownloadedPage && !Reachability.isConnectedToNetwork() {
            for temp in AppPrefsManager.sharedInstance.getClassData() {
                if temp.id == selectedId {
                    self.classDetailDataObj = temp
                    self.setData()
                }
            }
        } else {
            getClassDetails()
        }
        self.viewClassDifficultyLevel.layer.maskedCorners = [.layerMaxXMinYCorner]
        self.viewDuration.layer.maskedCorners = [.layerMinXMinYCorner]
    }
    
    @objc func didCompletePlaying() {
        self.isStatusUpdatedForVideoEnd = true
        self.timer.invalidate()
        let tempCounter = counter / 60
        counter = tempCounter.rounded() <= 0.0 ? 1.0 : tempCounter
        self.callEndLiveClassAPI()
    }

    func setData() {
        if self.classDetailDataObj.coachDetailsDataObj.id == AppPrefsManager.sharedInstance.getUserData().id { // personal class
            dropDown.dataSource  = ["Edit", "Delete", "Send", "Template", "Rate Class"]
        } else {
            dropDown.dataSource  = ["Send", "Rate Class"]
        }
        imgClassCover.setImageFromURL(imgUrl: classDetailDataObj.thumbnail_image, placeholderImage: nil)
        if classDetailDataObj.coach_class_type == CoachClassType.live {
            lblClassType.text = "LIVE"
            viwClassType.backgroundColor = hexStringToUIColor(hex: "#CC2936")
            viwClassStartIn.isHidden = false
            lblDate.text = classDetailDataObj.class_date
            lblTime.text = classDetailDataObj.class_time
            imgDownload.isHidden = true
            viewRecipeBottomButton.backgroundColor = COLORS.THEME_RED
            lblViewRecipeBottomButton.text = "Start Class"
            imgViewRecipeBottomButton.image = UIImage(named: "joinVideo")
        } else {
            lblClassType.text = "ON DEMAND"
            viwClassType.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
            viwClassStartIn.isHidden = true
            lblDate.text = classDetailDataObj.total_viewers + " views"
            lblTime.text = classDetailDataObj.created_atForamted
            imgDownload.isHidden = false
            viewRecipeBottomButton.backgroundColor = COLORS.ON_DEMAND_COLOR
            lblViewRecipeBottomButton.text = "Join Class"
            imgViewRecipeBottomButton.image = UIImage(named: "ic_play")
        }
        
        lblClassDifficultyLevel.text = classDetailDataObj.class_difficulty
        lblDuration.text = classDetailDataObj.duration
        lblClassStartIn.text = "Class starts in: " + classDetailDataObj.class_time
        lblClassTitle.text = classDetailDataObj.class_type
        lblClassSubTitle.text = classDetailDataObj.class_subtitle
        
        lblUserName.text = "@" + classDetailDataObj.coachDetailsDataObj.username
        imgUserProfile.setImageFromURL(imgUrl: classDetailDataObj.coachDetailsDataObj.user_image, placeholderImage: nil)
        imgThumbNail.setImageFromURL(imgUrl: classDetailDataObj.coachDetailsDataObj.user_image, placeholderImage: nil)
        imgThumbNail.blurImage()
        imgClassCover.setImageFromURL(imgUrl: classDetailDataObj.thumbnail_image, placeholderImage: nil)
        lblCal.text = classDetailDataObj.burn_calories + "Kcal"
        lblTimeDuration1.text = classDetailDataObj.duration
        bottomDetailView.heightEqupmentTbl.constant = 0.5
        tblEquipment.reloadData()
        
        let currencySybmol = getCurrencySymbol(from: classDetailDataObj.feesDataObj.fee_regional_currency)

        lblNonSubscriberFee.text = "Non-Subscribers Fee: " + currencySybmol + " " + classDetailDataObj.feesDataObj.non_subscriber_fee
        lblOneTimeFee.text = "One Time Fee: " + currencySybmol + " " + classDetailDataObj.feesDataObj.subscriber_fee
        
        lblMoreIngredients.text = "\(classDetailDataObj.arrEquipmentList.count) more ingredients"
        viwMoreIngredient.isHidden = classDetailDataObj.arrEquipmentList.count > 4 ? false : true
        
        classDescriptionView.lblTitle.text = classDetailDataObj.class_type
        classDescriptionView.lblSubtitle.text = classDetailDataObj.class_subtitle
        classDescriptionView.lblDescription.text = classDetailDataObj.description
        
        if classDetailDataObj.bookmark.lowercased() == "no".lowercased() {
            imgBookmark.image = UIImage(named: "BookmarkLight")
        } else {
            imgBookmark.image = UIImage(named: "Bookmark")
        }
        
        for temp in AppPrefsManager.sharedInstance.getClassData() {
            if temp.id == classDetailDataObj.id {
                imgDownload.image = UIImage(named: "Download Progress")
                self.isClassDownloaded = true
            }
        }
        
    }
    
    func setClassDescriptionView() {
        
        classDescriptionView.frame.size = self.view.frame.size
        self.view.addSubview(classDescriptionView)
    }
    
    func setRatingListPopUpView() {
        
        ratingListPopUp.frame.size = self.view.frame.size
        self.view.addSubview(ratingListPopUp)
    }
    
    func setbottomDetailView() {
        
        bottomDetailView.frame.size = self.view.frame.size
        self.view.addSubview(bottomDetailView)
    }
    
    func checkIfDataIsUpdated() {
        var classOldObj = ClassDetailData()
        var ind:Int!
        
        for (i,temp) in AppPrefsManager.sharedInstance.getClassData().enumerated() {
            if temp.id == classDetailDataObj.id {
                classOldObj = temp
                ind = i
                break
            }
        }
        
        if ind != nil {
            let resObj = classDetailDataObj.responseDic
            arrLocalCoachClassData.remove(at: ind!)
            arrLocalCoachClassData.insert(resObj, at: ind!)
            AppPrefsManager.sharedInstance.saveClassData(classData: arrLocalCoachClassData)
            
            if classOldObj.thumbnail_video_file != self.classDetailDataObj.thumbnail_video_file {
                downloadClassVideoImage(fileName: classDetailDataObj.thumbnail_video_file, downloadUrl: classDetailDataObj.thumbnail_video)
            }
            
            if classOldObj.thumbnail_image_path != self.classDetailDataObj.thumbnail_image_path {
               
                downloadClassVideoImage(fileName: classDetailDataObj.thumbnail_image_path, downloadUrl: classDetailDataObj.thumbnail_image)
            }
        }
        
       
    }
    
    func callAddUserToCoachClassAPI() {
        showLoader()
        let param = [ "coach_class_id" : classDetailDataObj.id,
                      "transaction_id" : "pi_3KYlygSD6FO6JDp91vNaiTqa",
                      
        ] as [String : Any]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.ADD_USER_TO_COACH_CLASS, parameters: param, headers: nil) { responseObj in
            self.hideLoader()
            let responseObj = ResponseDataModel(responseObj: responseObj)
            Utility.shared.showToast(responseObj.message)
            self.isFromSubscriptionPurchase = true
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func setupConfirmationView(fees: String, recdCurrency: String) {
        let currencySybmol = getCurrencySymbol(from: recdCurrency)
        var classTypeTitle = "Join Class"
        var classTypeName = "on demand"
        if self.classDetailDataObj.coach_class_type == CoachClassType.live {
            classTypeTitle = "Join the CoachCulture"
            classTypeName = "live"
        }
        logOutView.lblTitle.text = classTypeTitle
        logOutView.lblMessage.text = "Would you like to join \(self.lblUserName.text ?? "")'s \(classDetailDataObj.class_type) \(classTypeName) Class for a one time fee of \(currencySybmol + fees)?"
        logOutView.btnLeft.setTitle("Confirm", for: .normal)
        logOutView.btnRight.setTitle("Cancel", for: .normal)
        logOutView.tapToBtnLogOut {
            self.callAddUserToCoachClassAPI()
            self.removeConfirmationView()
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

    func goStepForwardAfterSubscribed() {
        if self.classDetailDataObj.coach_class_type == CoachClassType.live {
        } else {
            let folderName = self.classDetailDataObj.id + "_" + self.classDetailDataObj.class_subtitle
            let directoryUrl =  URL(fileURLWithPath: getDirectoryPath() + "/" + folderName + "/")
            
            var destinationFileUrl = ""
            
            if Reachability.isConnectedToNetwork() {
                destinationFileUrl = self.classDetailDataObj.thumbnail_video
            } else {
                destinationFileUrl = directoryUrl.appendingPathComponent(self.classDetailDataObj.thumbnail_video_file).absoluteString
            }
            
            let url = destinationFileUrl.replacingOccurrences(of: "file://", with: "")
//            let abc = url.replacingOccurrences(of: "%20", with: " ")
            let videoURL = URL(fileURLWithPath: url.removingPercentEncoding ?? "")
            isStatusUpdatedForVideoEnd = false
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.delegate = self
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    private func navigateToDashboard() {
        for controller in navigationController!.viewControllers {
            if controller.isKind(of: EditProfileViewController.self) {
                self.navigationController?.popToViewController(controller, animated: true)
                break
            } else {
                self.navigationController?.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    // MARK: - CLICK EVENTS
    
    @IBAction func btnTrainerDetailClick(_ sender: Any) {
        let vc = CoachViseOnDemandClassViewController.viewcontroller()
        vc.selectedCoachId = self.classDetailDataObj.coachDetailsDataObj.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToBtnBookmark( _ sender: UIButton) {
        if classDetailDataObj.bookmark.lowercased() == "no".lowercased() {
            addOrRemoveFromBookMark(bookmark: "yes")
        } else {
            addOrRemoveFromBookMark(bookmark: "no")
        }
    }
    
    @IBAction func clickToBtnDownload( _ sender: UIButton) {
        
        if !isClassDownloaded {
            let folderName = classDetailDataObj.id + "_" + classDetailDataObj.class_subtitle
            let _ =  createDirectory(MyFolderName: folderName)
            downloadClassVideoImage(fileName: URL(string: classDetailDataObj.thumbnail_image_path)?.lastPathComponent ?? "", downloadUrl: classDetailDataObj.thumbnail_image)
            let resObj = classDetailDataObj.responseDic
            arrLocalCoachClassData.append(resObj)
            AppPrefsManager.sharedInstance.saveClassData(classData: arrLocalCoachClassData)
            downloadClassVideoImage(fileName: classDetailDataObj.thumbnail_video_file, downloadUrl: classDetailDataObj.thumbnail_video)
            
        } else {
            self.addConfirmationView()
            logOutView.lblTitle.text = "Delete downloaded class"
            logOutView.lblMessage.text = "Are you sure that you want to delete the downloaded class?"
            logOutView.btnLeft.setTitle("Confirm", for: .normal)
            logOutView.btnRight.setTitle("Cancel", for: .normal)
            logOutView.tapToBtnLogOut {
                Utility.shared.showToast("Delete Downloded class sucessFully")
                self.isClassDownloaded = false
                self.imgDownload.image = UIImage(named: "Downloading")
                self.removeConfirmationView()
                if !self.isFromClassDownloadedPage {
                    for i in 0..<self.arrLocalCoachClassData.count {
                        let dic = self.arrLocalCoachClassData[i] as? NSDictionary ?? [:]
                        let id = dic["id"] as! Int
                        if "\(id)" == self.classDetailDataObj.id {
                            self.arrLocalCoachClassData.remove(at: i)
                            AppPrefsManager.sharedInstance.saveClassData(classData: self.arrLocalCoachClassData)
                            break
                        }
                        
                    }
                } else {
                    self.arrLocalCoachClassData.remove(at: self.deleteID)
                    AppPrefsManager.sharedInstance.saveClassData(classData: self.arrLocalCoachClassData)
                    self.checkIfDataIsUpdated()
                }
            }
        }
        
        
        
    }
    
    @IBAction func didTapBottomDetaile(_ sender: UIButton) {
        bottomDetailView.setData(title: self.classDetailDataObj.class_type, SubTitle: self.classDetailDataObj.class_subtitle, calary: classDetailDataObj.burn_calories + "Kcal", duration: classDetailDataObj.duration, Data: self.classDetailDataObj)
        setbottomDetailView()
    }
    
    @IBAction func didTapBtnBack(_ sender: UIButton) {
         if isNew {
            navigateToDashboard()
         } else {
            self.popVC(animated: true)
         }
    }
    @IBAction func clickToBtnScanQr( _ sender: UIButton) {
        
    }
    
    @IBAction func clickToBtnJoinClass( _ sender: UIButton) {
        if classDetailDataObj.coachDetailsDataObj.id == AppPrefsManager.sharedInstance.getUserData().id {
            self.goStepForwardAfterSubscribed()
        } else {
            var fees = ""
            var recdCurrency = ""
            
            if self.classDetailDataObj.subscription {
                fees = classDetailDataObj.feesDataObj.subscriber_fee
                recdCurrency = classDetailDataObj.feesDataObj.base_currency
            } else {
                fees = classDetailDataObj.feesDataObj.non_subscriber_fee
                recdCurrency = classDetailDataObj.feesDataObj.fee_regional_currency
            }
            self.checkUserSubscribedClassAPI { (isSubscribed) in
                if isSubscribed {
                    if self.isFromSubscriptionPurchase {
                        self.getClassDetails()
                    } else {
                        self.goStepForwardAfterSubscribed()
                    }
                } else {
                    self.addConfirmationView()
                    self.setupConfirmationView(fees: fees, recdCurrency: recdCurrency)
                }
            }
        }
    }
    
    @IBAction func clickToBtnMore( _ sender: UIButton) {
        
    }
    
    @IBAction func clickToBtn3Dots( _ sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            dropDown.show()
        } else{
            Utility.shared.showToast("No internet connection available")
        }
        
    }
    
    @IBAction func clickToBtnClassDescription( _ sender: UIButton) {
        setClassDescriptionView()
    }
    
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension LiveClassDetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classDetailDataObj.arrEquipmentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveClassEquipmentItemTableViewCell", for: indexPath) as! LiveClassEquipmentItemTableViewCell
        let obj = classDetailDataObj.arrEquipmentList[indexPath.row]
        cell.lblTitle.text = obj.equipment_name
        
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
extension LiveClassDetailsViewController {
    func getClassDetails() {
        if !self.isFromSubscriptionPurchase {
            showLoader()
        }
        let param = ["id" : selectedId]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.COACH_CLASS_DETAILS, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_class"] as? [String:Any] ?? [String:Any]()
            self.classDetailDataObj = ClassDetailData(responseObj: dataObj)
            if self.isFromSubscriptionPurchase {
                self.goStepForwardAfterSubscribed()
            } else {
                self.checkIfDataIsUpdated()
                self.getClassRating()
                self.setData()
            }
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func checkUserSubscribedClassAPI(completion completionHandler:@escaping (_ isSubscribed: Bool) -> Void) {
        showLoader()
        let param = ["class_id" : self.classDetailDataObj.id]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.CHECK_USER_SUBSCRIBED_CLASS, parameters: param, headers: nil) { responseObj in
            self.hideLoader()
            if let subscribed = responseObj["class_subscription"] as? Bool {
                completionHandler(subscribed)
            }
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }

    func getClassRating() {
        //showLoader()
        let param = ["coach_class_id" : selectedId,
                     "page_no" : "1",
                     "per_page" : "10"
        ]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_COACH_CLASS_RATING, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["data"] as? [String:Any] ?? [String:Any]()
            let coach_class_rating = dataObj["coach_class_rating"] as? [Any] ?? [Any]()
            let ratevalue = (dataObj["average_rating"] as? NSNumber)?.stringValue ?? ""
            self.arrClassRatingList = ClassRatingList.getData(data: coach_class_rating)
            self.ratingListPopUp.setData(title: self.classDetailDataObj.class_type, SubTitle: self.classDetailDataObj.class_subtitle, rateValue: ratevalue)
            self.ratingListPopUp.arrClassRatingList = self.arrClassRatingList
            self.ratingListPopUp.reloadTable()
           // self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func deleteClass() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.COACH_CLASS_DELETE + classDetailDataObj.id, parameters: nil, headers: nil) { responseObj in
            
            let resObj = ResponseDataModel(responseObj: responseObj)
            Utility.shared.showToast(resObj.message)
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func addOrRemoveFromBookMark(bookmark : String) {
        showLoader()
        let param = ["coach_class_id" : classDetailDataObj.id,"bookmark" : bookmark]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.COACH_CLASS_BOOKMARK, parameters: param, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            self.getClassDetails()
            Utility.shared.showToast(responseModel.message)
            
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func downloadClassVideoImage(fileName: String, downloadUrl : String) {
        showLoader()
        let folderName = classDetailDataObj.id + "_" + classDetailDataObj.class_subtitle
        
        let directoryUrl = URL(fileURLWithPath: getDirectoryPath() + "/" +  folderName)
        
        let destinationFileUrl = directoryUrl.appendingPathComponent( fileName)
        
        //Create URL to the source file you want to download
        if let fileURL = URL(string: downloadUrl.addingPercentEncoding(withAllowedCharacters: .urlAllowedCharacters) ?? "") {
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            
            let task = session.dataTask(with: fileURL) { (data, response, error) in
                
                DispatchQueue.main.async {
                    if error == nil {
                        
                        do {
                            try data?.write(to: destinationFileUrl)
                            
                        } catch {
                            print("Error", error)
                            return
                        }
                        
                    }
                    self.hideLoader()
                    self.isClassDownloaded = true
                    self.imgDownload.image = UIImage(named: "Download Progress")
                }
            }
            task.resume()
        }
    }
    
    func callJoinSessionsAPI() {
        let param = [
            Params.JoinSessions.class_id: self.classDetailDataObj.id,
            Params.JoinSessions.coach_class_subscription_id: self.classDetailDataObj.coach_class_subscription_id
        ] as [String : Any]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.JOIN_SESSION, parameters: param, headers: nil) { responseObj in
            if let dataDict = responseObj["data"] as? [String:Any] {
                if let user_coach_history_id = dataDict["user_coach_history_id"] as? Int {
                    self.userCoachHistoryID = user_coach_history_id
                    self.isFromSubscriptionPurchase = false
                }
            }
        } failure: { (error) in
            return true
        }
    }
    
    func callEndLiveClassAPI() {
        isStatusUpdatedForVideoEnd = true
        let param = [
            Params.EndLiveClass.class_id: self.classDetailDataObj.id,
            Params.EndLiveClass.duration: Int(self.counter),
            Params.EndLiveClass.user_coach_history_id: self.userCoachHistoryID ?? 0
        ] as [String : Any]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.END_LIVE_CLASS, parameters: param, headers: nil) { responseObj in
            _ = ResponseDataModel(responseObj: responseObj)
            self.counter = 0.0
        } failure: { (error) in
            self.counter = 0.0
            return true
        }
    }
}

extension CharacterSet {

    /// Characters valid in at least one part of a URL.
    ///
    /// These characters are not allowed in ALL parts of a URL; each part has different requirements. This set is useful for checking for Unicode characters that need to be percent encoded before performing a validity check on individual URL components.
    static var urlAllowedCharacters: CharacterSet {
        // Start by including hash, which isn't in any set
        var characters = CharacterSet(charactersIn: "#")
        // All URL-legal characters
        characters.formUnion(.urlUserAllowed)
        characters.formUnion(.urlPasswordAllowed)
        characters.formUnion(.urlHostAllowed)
        characters.formUnion(.urlPathAllowed)
        characters.formUnion(.urlQueryAllowed)
        characters.formUnion(.urlFragmentAllowed)

        return characters
    }
}

extension LiveClassDetailsViewController: AVPlayerViewControllerDelegate {
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        self.callJoinSessionsAPI()
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        counter += 1.0
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        if !isStatusUpdatedForVideoEnd {
            self.timer.invalidate()
            let tempCounter = counter / 60
            counter = tempCounter.rounded() <= 0.0 ? 1.0 : tempCounter
            self.callEndLiveClassAPI()
        }
    }
}
