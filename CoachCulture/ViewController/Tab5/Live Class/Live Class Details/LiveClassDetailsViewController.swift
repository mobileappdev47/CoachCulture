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
    @IBOutlet weak var btnJoinClass: UIButton!
    @IBOutlet weak var imgMusclesFront: UIImageView!
    @IBOutlet weak var imgMusclesBack: UIImageView!

    @IBOutlet weak var viewFrontBody: UIView!
    @IBOutlet weak var viewBackBody: UIView!
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
    @IBOutlet weak var viwScanQr: UIView!
    @IBOutlet weak var viwJoinClass: UIView!
    
    
    @IBOutlet weak var btnImgBackLeftArm: UIButton!
    @IBOutlet weak var btnImgBackRightArm: UIButton!
    @IBOutlet weak var btnImgBackUpperBackLeft: UIButton!
    @IBOutlet weak var btnImgBackUpperBackRight: UIButton!
    @IBOutlet weak var btnImgBackLowerBackLeft: UIButton!
    @IBOutlet weak var btnImgBackLowerBackRight: UIButton!
    @IBOutlet weak var btnImgBackHarmstringsLeft: UIButton!
    @IBOutlet weak var btnImgBackHarmstringsRight: UIButton!
    @IBOutlet weak var btnImgBackCalfsLeft: UIButton!
    @IBOutlet weak var btnImgBackCalfsRight: UIButton!
    @IBOutlet weak var btnImgBackGlutesLeft: UIButton!
    @IBOutlet weak var btnImgBackGlutesRight: UIButton!
        
    @IBOutlet weak var btnImgNeckLeft: UIButton!
    @IBOutlet weak var btnImgNeckRight: UIButton!
    @IBOutlet weak var btnChestLeft: UIButton!
    @IBOutlet weak var btnChestRight: UIButton!
    @IBOutlet weak var btnObliqueFrontLeft: UIButton!
    @IBOutlet weak var btnObliqueFrontRight: UIButton!
    @IBOutlet weak var btnObliqueBackLeft: UIButton!
    @IBOutlet weak var btnObliqueBackRight: UIButton!
    @IBOutlet weak var btnAbdominalsFrontLeft: UIButton!
    @IBOutlet weak var btnAbdominalsFrontRight: UIButton!
    @IBOutlet weak var btnShoulderBicepsForearmFrontLeft: UIButton!
    @IBOutlet weak var btnShoulderBicepsForearmFrontRight: UIButton!
    @IBOutlet weak var btnChestFrontLeft: UIButton!
    @IBOutlet weak var btnChestFrontRIght: UIButton!
    @IBOutlet weak var btnQuadricepsFrontLeft: UIButton!
    @IBOutlet weak var btnQuadricepsFrontRight: UIButton!
    @IBOutlet weak var btnCalfsFrontLeft: UIButton!
    @IBOutlet weak var btnCalfsFrontRight: UIButton!

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
    var timer : Timer?
    var totalTime = 00
    var counter = 0.0
    var userCoachHistoryID : Int?
    var isStatusUpdatedForVideoEnd = false
    var isNew = false
    var deleteID = Int()
    var isFromSubscriptionPurchase = false
    var arrMuscleList = [MuscleList]()
    var streamObj : StreamInfo?
    var isFutureClass = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.hideTabBar()
        self.timer?.invalidate()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        viwScanQr.roundCorners(corners: [.bottomLeft], radius: 30)
        viwJoinClass.roundCorners(corners: [.bottomRight], radius: 30)
    }

    private func setUpUI() {
        DispatchQueue.main.async {
            if Reachability.isConnectedToNetwork() {
                self.getMuscleGroupList()
            }
        }
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
        dropDown.cellHeight = 50
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
                self.addConfirmationView()
                self.deleteView()
            }
            
            if item.lowercased() == "Template".lowercased() { //Delete
                
                if classDetailDataObj.coach_class_type == CoachClassType.live {
                    let vc = ScheduleLiveClassViewController.viewcontroller()
                    vc.isFromEdit = true
                    vc.isFromTemplate = true
                    self.classDetailDataObj.class_subtitle = ""
                    self.classDetailDataObj.thumbnail_image = ""
                    self.classDetailDataObj.id = ""
                    vc.classDetailDataObj = self.classDetailDataObj
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = OnDemandVideoUploadViewController.viewcontroller()
                    vc.isFromEdit = true
                    vc.isFromTemplate = true
                    self.classDetailDataObj.class_subtitle = ""
                    self.classDetailDataObj.thumbnail_image = ""
                    self.classDetailDataObj.thumbnail_video = ""
                    self.classDetailDataObj.id = ""
                    vc.classDetailDataObj = self.classDetailDataObj
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            if item.lowercased() == "Ratings".lowercased() { //Rating
                
                if classDetailDataObj.coachDetailsDataObj.id == AppPrefsManager.sharedInstance.getUserData().id {
                    self.setRatingListPopUpView()
                } else {
                    let vc = LiveClassRatingViewController.viewcontroller()
                    vc.selectedId = self.classDetailDataObj.id
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
            if Reachability.isConnectedToNetwork(){
                getClassDetails(isFromTimerToCheckClassStatus: false)
            }
        }
        self.viewClassDifficultyLevel.layer.maskedCorners = [.layerMaxXMinYCorner]
        self.viewDuration.layer.maskedCorners = [.layerMinXMinYCorner]
    }
    
    @objc func didCompletePlaying() {
        self.isStatusUpdatedForVideoEnd = true
        self.timer?.invalidate()
        let tempCounter = counter / 60
        counter = tempCounter.rounded() <= 0.0 ? 1.0 : tempCounter
        if Reachability.isConnectedToNetwork(){
            self.callEndLiveClassAPI(isFromLiveStream: false)
        }
    }

    func setData() {
        if self.classDetailDataObj.coachDetailsDataObj.id == AppPrefsManager.sharedInstance.getUserData().id { // personal class
            dropDown.dataSource  = ["Edit", "Delete", "Send", "Template", "Ratings", "Share"]
        } else {
            dropDown.dataSource  = ["Send", "Share"]
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
            if classDetailDataObj.coachDetailsDataObj.id == AppPrefsManager.sharedInstance.getUserData().id {
                lblViewRecipeBottomButton.text = "Start Class"
            } else {
                lblViewRecipeBottomButton.text = "Join Class"
            }
            imgViewRecipeBottomButton.image = UIImage(named: "joinVideo")
        } else {
            lblClassType.text = "ON DEMAND"
            viwClassType.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
            viwClassStartIn.isHidden = true
            lblDate.text = classDetailDataObj.total_viewers + " views"
            lblTime.text = classDetailDataObj.created_atForamted
            lblTime?.font = UIFont.init(name: "SFProText-Heavy", size: 14)
            lblTime?.textColor = #colorLiteral(red: 0.1725490196, green: 0.2274509804, blue: 0.2901960784, alpha: 1)
            imgDownload.isHidden = false
            viewRecipeBottomButton.backgroundColor = COLORS.ON_DEMAND_COLOR
            lblViewRecipeBottomButton.text = "Join Class"
            imgViewRecipeBottomButton.image = UIImage(named: "ic_play")
        }
        
        lblClassDifficultyLevel.text = classDetailDataObj.class_difficulty
        lblDuration.text = classDetailDataObj.duration
        //lblClassStartIn.text = "Class starts in: " + classDetailDataObj.class_time
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
        
        let tempArrMuscleList = arrMuscleList
        
        for (indexMain, temp) in arrMuscleList.enumerated() {
            for (_ , model) in classDetailDataObj.arrMuscleGroupList.enumerated() {
                if model.muscle_group_id == temp.id {
                    print("model.muscle_group_name: \(model.muscle_group_name)")
                    print("obj.muscle_group_id: \(model.muscle_group_id)")
                    print("temp.id: \(temp.id)")
                    tempArrMuscleList[indexMain].isSelected = true
                    self.manageMusclesActivity(musclesModel: tempArrMuscleList[indexMain])
                    break
                }
            }
        }

        let frontImage = self.viewFrontBody.asImage()
        self.imgMusclesFront.image = frontImage
        let backImage = self.viewBackBody.asImage()
        self.imgMusclesBack.image = backImage
        print("")
    }
    
    func manageMusclesActivity(musclesModel: MuscleList) {
        let muscleGroupName = musclesModel.muscle_group_name
        let isSelected = musclesModel.isSelected
        
        switch muscleGroupName {
        case MuscleGroupName.Neck:
            self.setNeckMuscles(isSelected: isSelected)
        case MuscleGroupName.Shoulder, MuscleGroupName.Biceps, MuscleGroupName.Forearm:
            self.setShoulderBicepsForearmMuscles()
        case MuscleGroupName.Chest:
            self.setChestMuscles(isSelected: isSelected)
        case MuscleGroupName.Abdominals:
            self.setAbdominalsMuscles(isSelected: isSelected)
        case MuscleGroupName.Oblique:
            self.setObliqueMuscles(isSelected: isSelected)
        case MuscleGroupName.Quadriceps:
            self.setQuadricepsMuscles(isSelected: isSelected)
        case MuscleGroupName.Calfs:
            self.setCalfsMuscles(isSelected: isSelected)
        case MuscleGroupName.UpperBack:
            self.setUpperBackMuscles(isSelected: isSelected)
        case MuscleGroupName.LowerBack:
            self.setLowerBackMuscles(isSelected: isSelected)
        case MuscleGroupName.Hamstrings:
            self.setHarmstringsMuscles(isSelected: isSelected)
        case MuscleGroupName.Glutes:
            self.setGlutesMuscles(isSelected: isSelected)
        default:
            break
        }
    }
    
    func setGlutesMuscles(isSelected: Bool) {
        btnImgBackGlutesLeft.setImage(UIImage(named: "ic_glutes_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackGlutesLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnImgBackGlutesRight.setImage(UIImage(named: "ic_glutes_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackGlutesRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setHarmstringsMuscles(isSelected: Bool) {
        btnImgBackHarmstringsLeft.setImage(UIImage(named: "ic_hamstrings_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackHarmstringsLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnImgBackHarmstringsRight.setImage(UIImage(named: "ic_hamstrings_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackHarmstringsRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setLowerBackMuscles(isSelected: Bool) {
        btnImgBackLowerBackLeft.setImage(UIImage(named: "ic_lower_back_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackLowerBackLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnImgBackLowerBackRight.setImage(UIImage(named: "ic_lower_back_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackLowerBackRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setUpperBackMuscles(isSelected: Bool) {
        btnImgBackUpperBackLeft.setImage(UIImage(named: "ic_upper_back_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackUpperBackLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnImgBackUpperBackRight.setImage(UIImage(named: "ic_upper_back_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackUpperBackRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setCalfsMuscles(isSelected: Bool) {
        btnCalfsFrontLeft.setImage(UIImage(named: "ic_calfs_front_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnCalfsFrontLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnCalfsFrontRight.setImage(UIImage(named: "ic_calfs_front_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnCalfsFrontRight.tintColor = isSelected ? COLORS.THEME_RED : .white
        
        btnImgBackCalfsLeft.setImage(UIImage(named: "ic_calfs_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackCalfsLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnImgBackCalfsRight.setImage(UIImage(named: "ic_calfs_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackCalfsRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setQuadricepsMuscles(isSelected: Bool) {
        btnQuadricepsFrontLeft.setImage(UIImage(named: "ic_quadriceps_front_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnQuadricepsFrontLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnQuadricepsFrontRight.setImage(UIImage(named: "ic_quadriceps_front_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnQuadricepsFrontRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setObliqueMuscles(isSelected: Bool) {
        btnObliqueBackLeft.setImage(UIImage(named: "ic_oblique__back_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnObliqueBackLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnObliqueBackRight.setImage(UIImage(named: "ic_oblique__back_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnObliqueBackRight.tintColor = isSelected ? COLORS.THEME_RED : .white

        btnObliqueFrontLeft.setImage(UIImage(named: "ic_oblique_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnObliqueFrontLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnObliqueFrontRight.setImage(UIImage(named: "ic_oblique_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnObliqueFrontRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setAbdominalsMuscles(isSelected: Bool) {
        btnAbdominalsFrontLeft.setImage(UIImage(named: "ic_abdominals_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnAbdominalsFrontLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnAbdominalsFrontRight.setImage(UIImage(named: "ic_abdominals_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnAbdominalsFrontRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setChestMuscles(isSelected: Bool) {
        btnChestFrontLeft.setImage(UIImage(named: "ic_chest_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnChestFrontLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnChestFrontRIght.setImage(UIImage(named: "ic_chest_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnChestFrontRIght.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setShoulderBicepsForearmMuscles() {
        let tempArrMuscleList = self.arrMuscleList.filter { (musclesModel) -> Bool in
            musclesModel.muscle_group_name == MuscleGroupName.Shoulder || musclesModel.muscle_group_name == MuscleGroupName.Biceps || musclesModel.muscle_group_name == MuscleGroupName.Forearm
        }
        
        var shoulderSelected = false
        var bicepsSelected = false
        var forearmSelected = false

        for (_, musclesModel) in tempArrMuscleList.enumerated() {
            
            if musclesModel.muscle_group_name == MuscleGroupName.Shoulder {
                shoulderSelected = musclesModel.isSelected
            }
            if musclesModel.muscle_group_name == MuscleGroupName.Biceps {
                bicepsSelected = musclesModel.isSelected
            }
            if musclesModel.muscle_group_name == MuscleGroupName.Forearm {
                forearmSelected = musclesModel.isSelected
            }
        }
        
        if shoulderSelected && bicepsSelected && forearmSelected {
            btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_biceps_forearm_selected_front_left"), for: .normal)
            btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_biceps_forearm_selected_front_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_forearm_bothselected"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_forearm_bothselected"), for: .normal)
        } else if forearmSelected && bicepsSelected {
            self.btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_biceps_forearm_bothselected_front_left"), for: .normal)
            self.btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_biceps_forearm_bothselected_front_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_forearm_selectedonly"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_forearm_selectedonly"), for: .normal)
        } else if shoulderSelected && bicepsSelected {
            btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_biceps_bothselected_forearm_front_left"), for: .normal)
            btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_biceps_bothselected_forearm_front_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_selectedonly_forearm"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_selectedonly_forearm"), for: .normal)
        } else if shoulderSelected && forearmSelected {
            btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_forearm_bothselected_biceps_front_left"), for: .normal)
            btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_forearm_bothselected_biceps_front_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_forearm_bothselected"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_forearm_bothselected"), for: .normal)
        } else if shoulderSelected {
            btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_selectedonly_biceps_forearm_front_left"), for: .normal)
            btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_selectedonly_biceps_forearm_front_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_selectedonly_forearm"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_selectedonly_forearm"), for: .normal)
        } else if bicepsSelected {
            btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_biceps_selectedonly_forearm_front_left"), for: .normal)
            btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_biceps_selectedonly_forearm_front_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_forearm"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_forearm"), for: .normal)
        } else if forearmSelected {
            btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_biceps_forearm_selectedonly_front_left"), for: .normal)
            btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_biceps_forearm_selectedonly_front_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_forearm_selectedonly"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_forearm_selectedonly"), for: .normal)
        } else {
            btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_biceps_forearm_front_left_group"), for: .normal)
            btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_biceps_forearm_front_left_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_forearm"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_forearm"), for: .normal)
        }
        self.view.layoutIfNeeded()
    }

    func setNeckMuscles(isSelected: Bool) {
        btnImgNeckLeft.setImage(UIImage(named: "ic_neck_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgNeckLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnImgNeckRight.setImage(UIImage(named: "ic_neck_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgNeckRight.tintColor = isSelected ? COLORS.THEME_RED : .white
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
    
    func deleteView() {
        logOutView.lblTitle.text = "Delete Class?"
        logOutView.lblMessage.text = "Are you sure you would like to delete this class?"
        logOutView.btnLeft.setTitle("Yes", for: .normal)
        logOutView.btnRight.setTitle("Cancel", for: .normal)
        logOutView.tapToBtnLogOut {
            if Reachability.isConnectedToNetwork(){
                self.deleteClass()
            }
            self.removeConfirmationView()
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
            if Reachability.isConnectedToNetwork(){
                self.callAddUserToCoachClassAPI()
            }
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

    func goToPlayOndemandClass() {
        let folderName = self.classDetailDataObj.id + "_" + self.classDetailDataObj.class_subtitle
        let directoryUrl =  URL(fileURLWithPath: getDirectoryPath() + "/" + folderName + "/")
        
        var destinationFileUrl = ""
        isStatusUpdatedForVideoEnd = false
        var videoURL : URL?

        if Reachability.isConnectedToNetwork() {
            destinationFileUrl = self.classDetailDataObj.thumbnail_video
            if let tempVideoURL = URL(string: destinationFileUrl.addingPercentEncoding(withAllowedCharacters: .urlAllowedCharacters) ?? "") {
                videoURL = tempVideoURL
            }
        } else {
            destinationFileUrl = directoryUrl.appendingPathComponent(self.classDetailDataObj.thumbnail_video_file).absoluteString
            let url = destinationFileUrl.replacingOccurrences(of: "file://", with: "")
//            let abc = url.replacingOccurrences(of: "%20", with: " ")
            videoURL = URL(fileURLWithPath: url.removingPercentEncoding ?? "")
            isStatusUpdatedForVideoEnd = false
        }
        if let finalUrl = videoURL {
            let player = AVPlayer(url: finalUrl)
            let playerViewController = AVPlayerViewController()
            playerViewController.delegate = self
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }
    }
    
    private func goToStartClass() {
        let vc = JoinLiveClassVC.instantiate(fromAppStoryboard: .Recipe)
        vc.didEndStreamingBlock = { isSuccessfullyJoinned in
            if isSuccessfullyJoinned {
                if Reachability.isConnectedToNetwork() {
                    self.callEndLiveClassAPI(isFromLiveStream: true)
                }
            }
        }
        vc.stream = self.streamObj
        self.pushVC(To: vc, animated: false)
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
            if Reachability.isConnectedToNetwork(){
                addOrRemoveFromBookMark(bookmark: "yes")
            }
        } else {
            if Reachability.isConnectedToNetwork(){
                addOrRemoveFromBookMark(bookmark: "no")
            }
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
        bottomDetailView.setData(title: self.classDetailDataObj.class_type, SubTitle: self.classDetailDataObj.class_subtitle, calary: classDetailDataObj.burn_calories + "Kcal", duration: classDetailDataObj.duration, musclesBackImage: self.imgMusclesBack.image ?? UIImage(), musclesFrontImage: self.imgMusclesFront.image ?? UIImage(), Data: self.classDetailDataObj)
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
            if self.classDetailDataObj.coach_class_type == CoachClassType.live {
                if !classDetailDataObj.class_completed {
                    if !isFutureClass {
                        if Reachability.isConnectedToNetwork() {
                            self.getAWSDetails(isFromBroadcasting: true)
                        }
                    } else {
                        handleSinglePopup(message: "You can not start class before class time")
                    }
                }
            } else {
                self.goToPlayOndemandClass()
            }
        } else {
            if !isFutureClass {
                checkUserSubscriptionOfClass()
            } else {
                handleSinglePopup(message: "You can not join class before class time")
            }
        }
    }
    
    func handleSinglePopup(message: String) {
        let vc = PopupViewController.viewcontroller()
        vc.isHide = true
        vc.message = message
        self.present(vc, animated: true, completion: nil)
    }
    
    func goForBroadcastAWSClass() {
        let vc = BroadcastClassVC.instantiate(fromAppStoryboard: .Recipe)
        vc.streamObj = self.streamObj
        vc.didEndStreamingBlock = { isSuccessfullyJoinned in
            if isSuccessfullyJoinned {
                if Reachability.isConnectedToNetwork() {
                    self.callEndLiveClassAPI(isFromLiveStream: true)
                }
            }
        }
        self.pushVC(To: vc, animated: false)
    }
    
    func checkUserSubscriptionOfClass() {
        var fees = ""
        var recdCurrency = ""
        
        if self.classDetailDataObj.subscription {
            fees = classDetailDataObj.feesDataObj.subscriber_fee
            recdCurrency = classDetailDataObj.feesDataObj.base_currency
        } else {
            fees = classDetailDataObj.feesDataObj.non_subscriber_fee
            recdCurrency = classDetailDataObj.feesDataObj.fee_regional_currency
        }
        if Reachability.isConnectedToNetwork(){
            self.checkUserSubscribedClassAPI { (isSubscribed) in
                if isSubscribed {
                    if self.isFromSubscriptionPurchase {
                        self.getClassDetails(isFromTimerToCheckClassStatus: false)
                    } else if self.classDetailDataObj.coach_class_type == CoachClassType.live {
                        self.getAWSDetails(isFromBroadcasting: false)
                    } else {
                        self.goToPlayOndemandClass()
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
    
    func getMuscleGroupList() {
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.MUSCLE_GROUP_LIST, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()
                self.arrMuscleList = MuscleList.getData(data: dataObj)                
            }
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }

    func getAWSDetails(isFromBroadcasting: Bool) {
        showLoader()
        let param = ["class_id" : self.classDetailDataObj.id]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_AWS_DETAILS, parameters: param, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            if responseModel.success {
                if let dataObj = responseObj["data"] as? [String:Any] {
                    self.streamObj = StreamInfo(responseObj: dataObj)
                }
                self.hideLoader()
                if isFromBroadcasting {
                    if Reachability.isConnectedToNetwork() {
                        self.callJoinSessionsAPI()
                        self.goForBroadcastAWSClass()
                    }
                } else {
                    if Reachability.isConnectedToNetwork() {
                        self.callJoinSessionsAPI()
                        self.goToStartClass()
                    }
                }
            }
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }

    private func startTimerForRemainTimeFromClassStart() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerForRemainTimeFromClassStart), userInfo: nil, repeats: true)
    }

    @objc func updateTimerForRemainTimeFromClassStart() {
        print(self.totalTime)
        self.lblClassStartIn.text = "Class starts in : \(self.timeFormatted(self.totalTime))"
        if totalTime != 0 {
            totalTime -= 1  // decrease counter timer
        } else {
            if let timer = self.timer {
                isFutureClass = false
                timer.invalidate()
                self.timer = nil
            }
        }
    }
    
    private func startTimerForClassHasBeenStarted() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimerForClassHasBeenStarted), userInfo: nil, repeats: true)
    }

    @objc func updateTimerForClassHasBeenStarted() {
        print(self.totalTime)
        self.lblClassStartIn.text = "Class started: \(self.timeFormatted(self.totalTime))"
        if totalTime != 0 {
            totalTime += 1  // decrease counter timer
        } else {
            if let timer = self.timer {
                timer.invalidate()
                self.timer = nil
            }
        }
    }

    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func startTimerToCheckClassStatus() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(updateTimerForRemainTimeFromClassStart), userInfo: nil, repeats: true)
    }

    @objc func updateTimerToCheckClassStatus() {
        if Reachability.isConnectedToNetwork() {
            self.getClassDetails(isFromTimerToCheckClassStatus: true)
        }
    }

    func setupAfterClassStatusUpdation() {
        if self.classDetailDataObj.coach_class_type == CoachClassType.live {
            viwClassStartIn.isHidden = false
            if classDetailDataObj.class_completed {
                lblClassStartIn.text = "Class has ended"
                btnJoinClass.isEnabled = false
            } else {
                let currentDateTime = Date().getDateStringWithFormate("yyyy-MM-dd HH:mm:ss", timezone: TimeZone.current.abbreviation()!).getDateWithFormate(formate: "yyyy-MM-dd HH:mm:ss", timezone: TimeZone.current.abbreviation()!)
                let classStartDateTime = convertUTCToLocalDate(dateStr: "\(classDetailDataObj.class_date) \(classDetailDataObj.class_time)", sourceFormate: "yyyy-MM-dd HH:mm", destinationFormate: "yyyy-MM-dd HH:mm:ss")
                let diffClass = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: currentDateTime, to: classStartDateTime)
                if diffClass.day ?? 0 == 0 {
                    if diffClass.hour ?? 0 == 0 {
                        if (diffClass.minute ?? 0 > 0) || (diffClass.second ?? 0 > 0) {
                            //start Timer For Remain Time From Class Start
                            isFutureClass = true
                            self.totalTime = (((diffClass.minute ?? 0) * 60) + (diffClass.second ?? 0))
                            self.startTimerForRemainTimeFromClassStart()
                        } else {
                            if !classDetailDataObj.started_at.isEmpty || classDetailDataObj.started_at != "" {
                                //start Timer For Class Has Been Started
                                
                                let classStartedTime = convertUTCToLocalDate(dateStr: "\(classDetailDataObj.started_at)", sourceFormate: "yyyy-MM-dd HH:mm:ss", destinationFormate: "yyyy-MM-dd HH:mm:ss")
                                let diffClass = Calendar.current.dateComponents([.minute, .second], from: classStartedTime, to: currentDateTime)
                                self.totalTime = (((diffClass.minute ?? 0) * 60) + (diffClass.second ?? 0))
                                self.startTimerForClassHasBeenStarted()
                            } else {
                                //if class time is gone and allow coach to start class within 15 minute and then disable
                                if classDetailDataObj.coachDetailsDataObj.id != AppPrefsManager.sharedInstance.getUserData().id {
                                    if (diffClass.minute ?? 0 < -15) {
                                        self.lblClassStartIn.text = "coach was missed to start the class"
                                        btnJoinClass.isEnabled = false
                                    } else {
                                        //start timer to join class
                                        self.startTimerToCheckClassStatus()
                                    }
                                } else {
                                    if (diffClass.minute ?? 0 < -15) {
                                        self.lblClassStartIn.text = "You was misssed to start this class"
                                        btnJoinClass.isEnabled = false
                                    } else {
                                        //start timer to join class
                                        self.startTimerToCheckClassStatus()
                                    }
                                }
                            }
                        }
                    } else if diffClass.hour ?? 0 > 0 {
                        let todayEndDayTime = "23:59".getDateWithFormate(formate: "HH:mm", timezone: TimeZone.current.abbreviation()!)
                        let currentHourTime = Date().getDateStringWithFormate("HH:mm", timezone: TimeZone.current.abbreviation()!).getDateWithFormate(formate: "HH:mm", timezone: TimeZone.current.abbreviation()!)
                        isFutureClass = true
                        if todayEndDayTime > currentHourTime {
                            self.lblClassStartIn.text = "Class starts today at \(convertUTCToLocal(dateStr: classDetailDataObj.class_time, sourceFormate: "HH:mm", destinationFormate: "HH:mm"))"
                        } else {
                            self.lblClassStartIn.text = "Class starts at \(convertUTCToLocal(dateStr: classDetailDataObj.class_time, sourceFormate: "HH:mm", destinationFormate: "HH:mm"))"
                        }
                    } else if diffClass.hour ?? 0 < 0 {
                        if !classDetailDataObj.started_at.isEmpty || classDetailDataObj.started_at != "" {
                            //"start timer for class has been started - plus count down"

                            let classStartedTime = convertUTCToLocalDate(dateStr: "\(classDetailDataObj.started_at)", sourceFormate: "yyyy-MM-dd HH:mm:ss", destinationFormate: "yyyy-MM-dd HH:mm:ss")
                            let diffClass = Calendar.current.dateComponents([.minute, .second], from: classStartedTime, to: currentDateTime)
                            self.totalTime = (((diffClass.minute ?? 0) * 60) + (diffClass.second ?? 0))
                            self.startTimerForClassHasBeenStarted()
                        } else {
                            if classDetailDataObj.coachDetailsDataObj.id == AppPrefsManager.sharedInstance.getUserData().id {
                                self.lblClassStartIn.text = "You was missed to start the class"
                            } else {
                                self.lblClassStartIn.text = "coach was missed to start the class"
                            }
                            btnJoinClass.isEnabled = false
                        }
                    }
                } else if diffClass.day ?? 0 < 0 {
                    if classDetailDataObj.coachDetailsDataObj.id == AppPrefsManager.sharedInstance.getUserData().id {
                        self.lblClassStartIn.text = "You was missed to start the class"
                    } else {
                        self.lblClassStartIn.text = "coach was missed to start the class"
                    }
                    btnJoinClass.isEnabled = false
                } else if diffClass.day ?? 0 > 0 {
                    isFutureClass = true
                    let classStartDateTime = convertUTCToLocal(dateStr: "\(classDetailDataObj.class_date) \(classDetailDataObj.class_time)", sourceFormate: "yyyy-MM-dd mm:ss", destinationFormate: "dd MMM, yyyy")
                    self.lblClassStartIn.text = "Class starts at \(classStartDateTime)"
                }
            }
        } else {
            viwClassStartIn.isHidden = true
        }
    }
    
    func getClassDetails(isFromTimerToCheckClassStatus: Bool) {
        if !self.isFromSubscriptionPurchase && !isFromTimerToCheckClassStatus {
            showLoader()
        }
        let param = ["id" : selectedId]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.COACH_CLASS_DETAILS, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_class"] as? [String:Any] ?? [String:Any]()
            self.classDetailDataObj = ClassDetailData(responseObj: dataObj)
            if self.isFromSubscriptionPurchase {
                self.getAWSDetails(isFromBroadcasting: false)
            } else {
                if isFromTimerToCheckClassStatus {
                    self.setupAfterClassStatusUpdation()
                } else {
                    self.setupAfterClassStatusUpdation()
                    self.checkIfDataIsUpdated()
                    self.getClassRating()
                    self.setData()
                }
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
        
        _ =  ApiCallManager.requestApi(method: .delete, urlString: API.COACH_CLASS_DELETE + classDetailDataObj.id, parameters: nil, headers: nil) { responseObj in
            
            let resObj = ResponseDataModel(responseObj: responseObj)
            self.popVC(animated: true)
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
            if Reachability.isConnectedToNetwork(){
                self.getClassDetails(isFromTimerToCheckClassStatus: false)
            }
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
    
    func callEndLiveClassAPI(isFromLiveStream: Bool) {
        isStatusUpdatedForVideoEnd = true
        var param = [String:Any]()
        
        param[Params.EndLiveClass.class_id] = self.classDetailDataObj.id
        if !isFromLiveStream {
            param[Params.EndLiveClass.duration] = Int(self.counter)
        }
        param[Params.EndLiveClass.user_coach_history_id] = self.userCoachHistoryID ?? 0
        
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
        if Reachability.isConnectedToNetwork(){
            self.callJoinSessionsAPI()
        }
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        counter += 1.0
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        if !isStatusUpdatedForVideoEnd {
            self.timer?.invalidate()
            let tempCounter = counter / 60
            counter = tempCounter.rounded() <= 0.0 ? 1.0 : tempCounter
            if Reachability.isConnectedToNetwork(){
                self.callEndLiveClassAPI(isFromLiveStream: false)
            }
        }
    }
}
