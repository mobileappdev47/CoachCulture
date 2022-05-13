//
//  CoachViseOnDemandClassViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit
import AVKit
import AVFoundation

var isFromSelectedType = "onDemand"

class CoachViseOnDemandClassViewController: BaseViewController, AVPlayerViewControllerDelegate {
    
    static func viewcontroller() -> CoachViseOnDemandClassViewController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "CoachViseOnDemandClassViewController") as! CoachViseOnDemandClassViewController
        return vc
    }
    
    @IBOutlet weak var topConstantViewNoDataFound: NSLayoutConstraint!
    @IBOutlet weak var viewSubscription: UIView!
    @IBOutlet weak var viewNavbar: UIView!
    @IBOutlet weak var viewTableHeader: UIView!
    @IBOutlet weak var viewContentBG: UIView!
    @IBOutlet weak var viewFollow: UIView!
    @IBOutlet weak var viewUserProfileBottom: UIView!
    @IBOutlet weak var heightConstantImgBanner: NSLayoutConstraint!
    @IBOutlet weak var bottomConstantViewUserProfile: NSLayoutConstraint!
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
    @IBOutlet weak var viwNoDataFound: UIView!
    @IBOutlet weak var viwCoachProfile: UIView!
    @IBOutlet weak var viwOtherCoachProfile: UIView!
    
    @IBOutlet weak var tblOndemand: UITableView!
    @IBOutlet weak var lctOndemandTableHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btn3Dots: UIButton!
    @IBOutlet weak var btnUserProfile: UIButton!
    
    @IBOutlet weak var lblCreateClass: UILabel!
    
    @IBOutlet weak var btnTrailer: UIButton!
    
    var arrCoachClassInfoList = [CoachClassInfoList]()
    var coachInfoDataObj = CoachInfoData()
    var selectedCoachId = ""
    var arrCoachRecipe = [PopularRecipeData]()
    var dropDown = DropDown()
    var coachTrailerURL = ""
    
    var isDataLoading = false
    var continueLoadingData = true
    var pageNo = 1
    var perPageCount = 10
    
    var isDataLoadingRecipe = false
    var continueLoadingDataRecipe = true
    var pageNoRecipe = 1
    var perPageCountRecipe = 10
    var userDataObj : UserData?
    let safeAreaTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0.0
    var logOutView:LogOutView!
    var isFromInitialLoadingBlock: (() -> Void)!
    static var isFromTransection = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.hideTabBar()
        if Reachability.isConnectedToNetwork(){
            getUserProfile()
            getCoacheSearchHistory()
            self.resetVariable()
            self.resetRecipeVariable()
        }
        setData()
        if self.isFromInitialLoadingBlock != nil {
            self.isFromInitialLoadingBlock()
        }
        if CoachViseOnDemandClassViewController.isFromTransection {
            Utility().showToast("Coach subscribe Successfully")
            CoachViseOnDemandClassViewController.isFromTransection = false
        }
    }
    
    // MARK: - Methods
    
    private func setUpUI() {
        logOutView = Bundle.main.loadNibNamed("LogOutView", owner: nil, options: nil)?.first as? LogOutView
        hideTabBar()
        imgThumbnail.blurImage()
        viwNoDataFound.isHidden = false
        self.bottomConstantViewUserProfile.constant = 10.0
        viwCoachProfile.isHidden = true
        heightConstantImgBanner.constant = 290 - 35
        viwUserProfileContainer.applyBorder(3, borderColor: hexStringToUIColor(hex: "#CC2936")) //#81747E
        viewUserProfileBottom.addCornerRadius(3)
        viewUserProfileBottom.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        tblOndemand.register(UINib(nibName: "HeaderTableView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderTableView")
        
        tblOndemand.register(UINib(nibName: "CoachViseOnDemandClassItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseOnDemandClassItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
        
        tblOndemand.register(UINib(nibName: "CoachViseRecipeItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseRecipeItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
        dropDown.cellHeight = 50
        dropDown.dataSource  = ["Profile Link", "Share"]
        dropDown.anchorView = btn3Dots
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if item.lowercased() == "Profile Link".lowercased() {
                UIPasteboard.general.string = "Check out Coach @\(self.userDataObj?.username ?? "") on\nCoachCulture\nhttps://www.coachculture.com/coach/\(self.userDataObj?.username ?? "")"
                Utility.shared.showToast("Profile Link Copied Successfully")
            }
            
            if item.lowercased() == "Share".lowercased() {
                let textToShare = [ "Check out Coach @\(self.userDataObj?.username ?? "") on CoachCulture https://www.coachculture.com/coach/timnorton" ]
                let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]                
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
        dropDown.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        dropDown.textColor = UIColor.white
        dropDown.selectionBackgroundColor = .clear
    }
    
    func redirectToPaymentMethod() {
        var fees = ""
        var recdCurrency = ""
        
        if self.userDataObj?.is_coach_subscribed ?? false {
            fees = userDataObj?.feesDataObj.subscriber_fee ?? ""
            recdCurrency = userDataObj?.feesDataObj.base_currency ?? ""
        } else {
            fees = userDataObj?.feesDataObj.base_subscriber_fee ?? ""
            recdCurrency = userDataObj?.feesDataObj.fee_regional_currency ?? ""
        }

        let vc = PaymentMethodViewController.viewcontroller()
            vc.didFinishPaymentBlock = { transaction_id, status in
            if status {
                if Reachability.isConnectedToNetwork() {
                    self.callAddUserToCoachAPI(transaction_id: transaction_id)
                }
            } else {
                Utility.shared.showToast("Ooops!! Something went wrong!")
            }
        }
        vc.fees = fees
        vc.coachID = Int(selectedCoachId) ?? 0
        vc.recdCurrency = recdCurrency
        vc.isFromLiveClass = true
        vc.isForCoach = true
        self.pushVC(To: vc, animated: true)
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
            self.bottomConstantViewUserProfile.constant = 20.0
            viwCoachProfile.isHidden = false
            viwOtherCoachProfile.isHidden = true
            viwUserProfileContainer.applyBorder(3, borderColor: hexStringToUIColor(hex: "#81747E")) //
            imgMovieIcon.image = UIImage(named: "grayMovieIcon")
        }
        
        //lblFees.text =  coachInfoDataObj.monthly_subscription_fee
        //lblUserName.text = "@" + coachInfoDataObj.username
        //lblFollowers.text =  coachInfoDataObj.total_followers + " Followers"
        if coachInfoDataObj.user_subscribed == "no" {
            self.imgSubscription.isHidden = true
        } else {
            self.imgSubscription.isHidden = false
        }
        imgUserProfile.addCornerRadius(3)
        
        lblNoDataFound.text = "No demand class found"
        viwNoDataFound.isHidden = arrCoachClassInfoList.count > 0
        
        switch isFromSelectedType {
        case SelectedDemandClass.onDemand:
            if arrCoachClassInfoList.count > 0 {
                if safeAreaTop > 20 {
                    lctOndemandTableHeight.constant = (self.view.frame.height - (self.viewNavbar.frame.height) - (15.0 + safeAreaTop + 14))
                } else {
                    lctOndemandTableHeight.constant = (self.view.frame.height - (self.viewNavbar.frame.height) - (15.0 + safeAreaTop))
                }
            } else {
                lctOndemandTableHeight.constant = 200.0
            }
            lblNoDataFound.text = "No demand class found"
            scrollView.isScrollEnabled = arrCoachClassInfoList.count > 0
            viwNoDataFound.isHidden = arrCoachClassInfoList.count > 0
        case SelectedDemandClass.live:
            if arrCoachClassInfoList.count > 0 {
                if safeAreaTop > 20 {
                    lctOndemandTableHeight.constant = (self.view.frame.height - (self.viewNavbar.frame.height) - (15.0 + safeAreaTop + 14))
                } else {
                    lctOndemandTableHeight.constant = (self.view.frame.height - (self.viewNavbar.frame.height) - (15.0 + safeAreaTop))
                }
            } else {
                lctOndemandTableHeight.constant = 200.0
            }
            scrollView.isScrollEnabled = arrCoachClassInfoList.count > 0
            lblNoDataFound.text = "No live class found"
            viwNoDataFound.isHidden = arrCoachClassInfoList.count > 0
        case SelectedDemandClass.recipe:
            if arrCoachRecipe.count > 0 {
                if safeAreaTop > 20 {
                    lctOndemandTableHeight.constant = (self.view.frame.height - (self.viewNavbar.frame.height) - (15.0 + safeAreaTop + 14))
                } else {
                    lctOndemandTableHeight.constant = (self.view.frame.height - (self.viewNavbar.frame.height) - (15.0 + safeAreaTop))
                }
            } else {
                lctOndemandTableHeight.constant = 200.0
            }
            scrollView.isScrollEnabled = arrCoachRecipe.count > 0
            lblNoDataFound.text = "No recipe class found"
            viwNoDataFound.isHidden = arrCoachRecipe.count > 0
        default:
            lctOndemandTableHeight.constant = 200.0
        }
        
        self.tblOndemand.reloadData()
        //self.lctOndemandTableHeight.constant = self.tblOndemand.contentSize.height
        
        self.tblOndemand.isScrollEnabled = false
        self.scrollView.delegate = self
        self.tblOndemand.layoutIfNeeded()
    }
    
    func setupConfirmationView() {
        logOutView.lblTitle.text = "Join the CoachCulture"
        logOutView.lblMessage.text = "Do you want to subscribe to \(self.lblUserName.text ?? "") for monthly subscription fee of \(self.lblFees.text ?? "")"
        logOutView.btnLeft.setTitle("Confirm", for: .normal)
        logOutView.btnRight.setTitle("Cancel", for: .normal)
        logOutView.tapToBtnLogOut {
            self.redirectToPaymentMethod()
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

    @IBAction func btnSubscribeClick(_ sender: UIButton) {
        if self.userDataObj?.is_coach_subscribed ?? false {
            let nextVc = ManageSubscriptionListViewController.viewcontroller()
            self.pushVC(To: nextVc, animated: true)
        } else {
            self.addConfirmationView()
            self.setupConfirmationView()
        }
    }
    
    @IBAction func clickToBtnAddFollow( _ sender : UIButton) {
        if Reachability.isConnectedToNetwork(){
            addRemoveFollowers(isShowLoader: true)
        }
    }
    
    @IBAction func clickToBtn3Dots(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            dropDown.show()
        } else{
            Utility.shared.showToast("No internet connection available")
        }
    }
    
    @IBAction func clickToBtnCoachProfile( _ sender : UIButton) {
        let vc = CoachClassProfileViewController.viewcontroller()
        vc.selectedCoachId = self.selectedCoachId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClkBtnTrailer(_ sender: UIButton) {
        let url = URL(string: userDataObj?.coach_trailer_file ?? "")!
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.delegate = self
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension CoachViseOnDemandClassViewController : UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            print(self.scrollView.contentOffset.y)
            if safeAreaTop > 20 {
                tblOndemand.isScrollEnabled = (self.scrollView.contentOffset.y >= 280)
            } else {
                tblOndemand.isScrollEnabled = (self.scrollView.contentOffset.y >= 250)
            }
        }
        
        if scrollView == self.tblOndemand {
            self.tblOndemand.isScrollEnabled = (tblOndemand.contentOffset.y > 0)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderTableView") as! HeaderTableView
        self.isFromInitialLoadingBlock = {
            headerView.clickToBtnClassTypeForCoach(headerView.btnOnDemand)
        }
        headerView.vewClass.isHidden = false
        headerView.didTapButton = { recdType in
            switch recdType {
            case SelectedDemandClass.onDemand:
                self.resetVariable()
                if Reachability.isConnectedToNetwork(){
                    self.getCoachesWiseClassList()
                }
            case SelectedDemandClass.live:
                self.resetVariable()
                if Reachability.isConnectedToNetwork(){
                    self.getCoachesWiseClassList()
                }
            case SelectedDemandClass.recipe:
                self.resetRecipeVariable()
                if Reachability.isConnectedToNetwork(){
                    self.getCoachesWiseRecipeList()
                }
            default:
                self.resetVariable()
                if Reachability.isConnectedToNetwork(){
                    self.getCoachesWiseClassList()
                }
            }
            headerView.didTapBtnClass = { recdType in
                switch headerView.btnClass.tag {
                    case 1:
                        let vc = OnDemandVideoUploadViewController.viewcontroller()
                        self.navigationController?.pushViewController(vc, animated: true)
                    case 2:
                        let vc = ScheduleLiveClassViewController.viewcontroller()
                        self.navigationController?.pushViewController(vc, animated: true)
                    case 3:
                        let vc = CreateMealRecipeViewController.viewcontroller()
                        self.navigationController?.pushViewController(vc, animated: true)
                    default:
                        let vc = OnDemandVideoUploadViewController.viewcontroller()
                        self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height = selectedCoachId == AppPrefsManager.sharedInstance.getUserData().id ? 100.0 : 50.0
        self.topConstantViewNoDataFound.constant = CGFloat(height)
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFromSelectedType == SelectedDemandClass.onDemand || isFromSelectedType == SelectedDemandClass.live {
            return arrCoachClassInfoList.count
        }
        return arrCoachRecipe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isFromSelectedType == SelectedDemandClass.onDemand {
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
            
            if arrCoachClassInfoList.count != 1 {
                if arrCoachClassInfoList.count - 1 == indexPath.row {
                    if Reachability.isConnectedToNetwork(){
                        getCoachesWiseClassList()
                    }
                }
            }
            return cell
        } else if isFromSelectedType == SelectedDemandClass.live {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseOnDemandClassItemTableViewCell", for: indexPath) as! CoachViseOnDemandClassItemTableViewCell
            cell.lblClassType.text = "Live".uppercased()
            cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#CC2936")
            let obj = arrCoachClassInfoList[indexPath.row]
            cell.selectedIndex = indexPath.row
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_class_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                if Reachability.isConnectedToNetwork(){
                    self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, recdType: SelectedDemandClass.live, selectedIndex: cell.selectedIndex)
                }
            }
            cell.viewDuration.layer.maskedCorners = [.layerMinXMinYCorner]
            cell.lblDuration.text = obj.duration
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "")
            cell.lblClassDifficultyLevel.text = obj.class_subtitle
            cell.lbltitle.text = obj.class_type_name
            cell.lblClassDate.text = obj.created_atFormated
            cell.lblClassTime.text = convertUTCToLocal(dateStr: obj.class_time, sourceFormate: "HH:mm", destinationFormate: "HH:mm")
            
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            
            if arrCoachClassInfoList.count != 1 {
                if arrCoachClassInfoList.count - 1 == indexPath.row {
                    if Reachability.isConnectedToNetwork(){
                        getCoachesWiseClassList()
                    }
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseRecipeItemTableViewCell", for: indexPath) as! CoachViseRecipeItemTableViewCell
            let obj = arrCoachRecipe[indexPath.row]
            cell.selectedIndex = indexPath.row
            cell.isAllowTagLayout = true
            cell.setUpUI()
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_recipe_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                if Reachability.isConnectedToNetwork(){
                    self.callToAddRemoveBookmarkAPI(urlStr: API.ADD_REMOVE_BOOKMARK, params: param, recdType: SelectedDemandClass.recipe, selectedIndex: cell.selectedIndex)
                }
            }
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
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            
            if arrCoachRecipe.count != 1 {
                if arrCoachRecipe.count - 1 == indexPath.row {
                    if Reachability.isConnectedToNetwork(){
                        getCoachesWiseRecipeList()
                    }
                }
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
        if isFromSelectedType == SelectedDemandClass.onDemand || isFromSelectedType == SelectedDemandClass.live {
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
    
    func getUserProfile(isShowLoader: Bool = true) {
        if isShowLoader {
            showLoader()
        }
        
        let api = "\(API.GET_PROFILE)?coach_id=\(selectedCoachId)"
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: api, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [String:Any] ?? [String:Any]()
                self.userDataObj = UserData(responseObj: dataObj)
                self.imgClassCover.setImageFromURL(imgUrl: self.userDataObj?.coach_banner_file ?? "", placeholderImage: nil)
                self.imgMovieIcon.isHidden = (self.userDataObj?.coach_trailer_file.isEmpty ?? false) ? true : false
                
                self.imgUserProfile.setImageFromURL(imgUrl: self.userDataObj?.user_image ?? "", placeholderImage: nil)
                self.imgThumbnail.setImageFromURL(imgUrl: self.userDataObj?.user_image ?? "", placeholderImage: nil)
                self.viewFollow.backgroundColor = (self.userDataObj?.is_followed ?? false) ? COLORS.BLUR_COLOR : COLORS.THEME_RED
                
                self.lblFollowers.text =  "\(self.userDataObj?.total_followers ?? "") Followers"
                let currencySybmol = getCurrencySymbol(from: self.userDataObj?.feesDataObj.fee_regional_currency ?? "")
                self.lblFees.text =  "\(currencySybmol)\(self.userDataObj?.feesDataObj.subscriber_fee ?? "")"
                self.lblUserName.text = "@ \(self.userDataObj?.username ?? "")"
                
                self.viewSubscription.backgroundColor = (self.userDataObj?.is_coach_subscribed ?? false) ? COLORS.BLUR_COLOR : COLORS.THEME_RED
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
        let param = [ "coach_id" : selectedCoachId,
                      "class_type" : isFromSelectedType == SelectedDemandClass.onDemand ? "on_demand" : "live",
                      "page_no" : pageNo,
                      "per_page" : perPageCount
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
            
            self.arrCoachRecipe.forEach { (model) in
                model.arrdietary_restriction.sort()
            }
            
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
    
    func callAddUserToCoachAPI(transaction_id: String) {
        showLoader()
        let param = [ "coach_id" : selectedCoachId,
                      "transaction_id" : transaction_id,
                      
        ] as [String : Any]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.ADD_USER_TO_COACH, parameters: param, headers: nil) { responseObj in
            
            let responseObj = ResponseDataModel(responseObj: responseObj)
            Utility.shared.showToast(responseObj.message)
            if !(self.userDataObj?.is_followed ?? false) {
                self.addRemoveFollowers(isShowLoader: false)
            } else {
                if Reachability.isConnectedToNetwork(){
                    self.getUserProfile(isShowLoader: false)
                }
            }
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func addRemoveFollowers(isShowLoader: Bool) {
        if isShowLoader {
            showLoader()
        }
        let param = [ "coach_id" : selectedCoachId,
                      "status" : (userDataObj?.is_followed ?? false) ? "no" : "yes",
                      
        ] as [String : Any]
        
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.ADD_REMOVE_FOLLOWERS, parameters: param, headers: nil) { responseObj in
            
            let responseObj = ResponseDataModel(responseObj: responseObj)
            if isShowLoader {
                Utility.shared.showToast(responseObj.message)
            }
            
            if Reachability.isConnectedToNetwork(){
                self.getUserProfile()
            }
            self.hideLoader()
            
        } failure: { (error) in
            return true
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
}

class TagsLayout: UICollectionViewFlowLayout {
    
    required override init() {super.init(); common()}
    required init?(coder aDecoder: NSCoder) {super.init(coder: aDecoder); common()}
    
    private func common() {
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        minimumLineSpacing = 10
        minimumInteritemSpacing = 10
    }
    
    override func layoutAttributesForElements(
        in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let att = super.layoutAttributesForElements(in:rect) else {return []}
        var x: CGFloat = sectionInset.left
        var y: CGFloat = -1.0
        
        for a in att {
            if a.representedElementCategory != .cell { continue }
            
            if a.frame.origin.y >= y { x = sectionInset.left }
            a.frame.origin.x = x
            x += a.frame.width + minimumInteritemSpacing
            y = a.frame.maxY
        }
        return att
    }
}

class HeaderTableView: UITableViewHeaderFooterView {
    
    // MARK: - OUTLET
    
    @IBOutlet weak var viwOnDemandLine: UIView!
    @IBOutlet weak var viwLiveLine: UIView!
    @IBOutlet weak var viwRecipeLine: UIView!
    
    @IBOutlet weak var btnOnDemand: UIButton!
    @IBOutlet weak var btnLive: UIButton!
    @IBOutlet weak var btnRecipe: UIButton!
    
    @IBOutlet weak var vewClass: UIView!
    @IBOutlet weak var lblClass: UILabel!
    @IBOutlet weak var btnClass: UIButton!
    
    // MARK: - VARIABLE AND OBJECT
    
    var didTapButton : ((_ recdType: String) -> Void)!
    var didTapBtnClass : ((_ recdType: String) -> Void)!
    
    // MARK: - CLICK EVENTS
    
    
    @IBAction func clickToBtnClass(_ sender: UIButton) {
        switch btnClass.tag {
            case 1:
                isFromSelectedType = SelectedDemandClass.onDemand
                didTapBtnClass(SelectedDemandClass.onDemand)
            case 2:
                isFromSelectedType = SelectedDemandClass.live
                didTapBtnClass(SelectedDemandClass.live)
            case 3:
                isFromSelectedType = SelectedDemandClass.recipe
                didTapBtnClass(SelectedDemandClass.recipe)
            default:
                didTapBtnClass(SelectedDemandClass.onDemand)
        }
    }
    
    @IBAction func clickToBtnClassTypeForCoach( _ sender : UIButton) {
        viwOnDemandLine.isHidden = true
        viwLiveLine.isHidden = true
        viwRecipeLine.isHidden = true
        
        switch sender {
        case btnOnDemand:
            viwOnDemandLine.isHidden = false
            isFromSelectedType = SelectedDemandClass.onDemand
            lblClass.text = "Upload On Demand Class"
            btnClass.tag = 1
            didTapButton(SelectedDemandClass.onDemand)
        case btnLive:
            viwLiveLine.isHidden = false
            isFromSelectedType = SelectedDemandClass.live
            didTapButton(SelectedDemandClass.live)
            lblClass.text = "Schedule Live Class"
            btnClass.tag = 2
        case btnRecipe:
            viwRecipeLine.isHidden = false
            isFromSelectedType = SelectedDemandClass.recipe
            didTapButton(SelectedDemandClass.recipe)
            lblClass.text = "Create Recipe"
            btnClass.tag = 3
        default:
            viwOnDemandLine.isHidden = false
            didTapButton(SelectedDemandClass.onDemand)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        /*DispatchQueue.main.async {
            self.clickToBtnClassTypeForCoach(self.btnOnDemand)
        }*/
    }
}

struct SelectedDemandClass {
    static let onDemand = "onDemand"
    static let live = "live"
    static let recipe = "recipe"
}

struct BaseCurrencyList {
    static let SGD = "SGD"
    static let USD = "USD"
    static let EUR = "EUR"
}

struct BaseCurrencySymbol {
    static let SGD = "S$"
    static let USD = "US$"
    static let EUR = "€"
}
