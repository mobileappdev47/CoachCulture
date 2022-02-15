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


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    private func setUpUI() {
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
        
    }
    
    func setData() {
        if classDetailDataObj.coachDetailsDataObj.id == AppPrefsManager.sharedInstance.getUserData().id { // personal class
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
        } else {
            lblClassType.text = "ON DEMAND"
            viwClassType.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
            viwClassStartIn.isHidden = true
            lblDate.text = classDetailDataObj.total_viewers + " views"
            lblTime.text = classDetailDataObj.created_atForamted
            imgDownload.isHidden = false
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
        tblEquipment.reloadData()
        lblNonSubscriberFee.text = "Non-Subscribers Fee: " + classDetailDataObj.feesDataObj.base_currency + " " + classDetailDataObj.feesDataObj.non_subscriber_fee
        lblOneTimeFee.text = "One Time Fee: " + classDetailDataObj.feesDataObj.base_currency + " " + classDetailDataObj.feesDataObj.subscriber_fee
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
    
    
    // MARK: - CLICK EVENTS
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
            downloadClassVideoImage(fileName: classDetailDataObj.thumbnail_video_file, downloadUrl: classDetailDataObj.thumbnail_video)
            let resObj = classDetailDataObj.responseDic
            arrLocalCoachClassData.append(resObj)
            AppPrefsManager.sharedInstance.saveClassData(classData: arrLocalCoachClassData)
            downloadClassVideoImage(fileName: URL(string: classDetailDataObj.thumbnail_image_path)?.lastPathComponent ?? "", downloadUrl: classDetailDataObj.thumbnail_image)
            
        }
        
        
        
    }
    
    
    @IBAction func clickToBtnScanQr( _ sender: UIButton) {
        
    }
    
    @IBAction func clickToBtnJoinClass( _ sender: UIButton) {
        let folderName = classDetailDataObj.id + "_" + classDetailDataObj.class_subtitle
        let directoryUrl =  URL(fileURLWithPath: getDirectoryPath() + "/" + folderName + "/")
        
        var destinationFileUrl = ""
        
        if Reachability.isConnectedToNetwork() {
            destinationFileUrl = classDetailDataObj.thumbnail_video
        } else {
            destinationFileUrl = directoryUrl.appendingPathComponent(classDetailDataObj.thumbnail_video_file).absoluteString
        }
        
        if let videoURL = URL(string: destinationFileUrl) {
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
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
        showLoader()
        let param = ["id" : selectedId]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.COACH_CLASS_DETAILS, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_class"] as? [String:Any] ?? [String:Any]()
            self.classDetailDataObj = ClassDetailData(responseObj: dataObj)
            self.setData()
            self.hideLoader()
            self.checkIfDataIsUpdated()
            self.getClassRating()
            
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
        if let fileURL = URL(string: downloadUrl) {
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
}
