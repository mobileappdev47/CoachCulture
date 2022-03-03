//
//  CoachClassProfileViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 03/01/22.
//

import UIKit
import Charts

class CoachClassProfileViewController: BaseViewController {

    static func viewcontroller() -> CoachClassProfileViewController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "CoachClassProfileViewController") as! CoachClassProfileViewController
        return vc
    }
    
    static func viewcontrollerNav() -> UINavigationController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "CoachClassProfileViewControllerNavVC") as! UINavigationController
        return vc
    }
    
    @IBOutlet weak var heightConstantViewStackMain: NSLayoutConstraint!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var viwNoDataFound: UIView!
    @IBOutlet weak var viewSettings: UIView!
    @IBOutlet weak var tblOndemand: UITableView!
    @IBOutlet weak var lctOndemandTableHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewNavbar: UIView!
    @IBOutlet weak var lblNoDataFound: UILabel!

    @IBOutlet weak var lblTotalWorkoutDuration: UILabel!
    @IBOutlet weak var lblTotalBurnCalories: UILabel!
    @IBOutlet var chartView: CombinedChartView!
    @IBOutlet weak var viewTotalWorkout: UIView!
    @IBOutlet weak var viewTotalkcalBurnt: UIView!

    var arrCoachClassInfoList = [CoachClassPrevious]()
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
    let role = AppPrefsManager.sharedInstance.getUserRole()
    let safeAreaTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0.0
    var userWorkoutStatisticsModel = UserWorkoutStatisticsModel()
    var ITEM_COUNT  = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgThumbnail.blurImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetVariable()
        setUpUI()
        self.showTabBar()
    }
        
    // MARK: - Methods
    private func setUpUI() {
        if self.selectedCoachId.isEmpty || self.selectedCoachId == "" {
            self.selectedCoachId = AppPrefsManager.sharedInstance.getUserData().id
        }
        btnBack.isHidden = true
        viwNoDataFound.isHidden = false
        
        tblOndemand.register(UINib(nibName: "HeaderTableView", bundle: nil), forHeaderFooterViewReuseIdentifier: "HeaderTableView")

        tblOndemand.register(UINib(nibName: "CoachViseOnDemandClassItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseOnDemandClassItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
        
        tblOndemand.register(UINib(nibName: "CoachViseRecipeItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseRecipeItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
                
        if Reachability.isConnectedToNetwork() {
            callUserWorkoutStatisticsAPI()
            callFollowingCoachClassListAPI()
        }
    }
    
    func setupChartUI() {
        // MARK: General
        chartView.delegate                  = self
        chartView.drawGridBackgroundEnabled = false
        chartView.drawBarShadowEnabled      = false
        chartView.highlightFullBarEnabled   = false
        chartView.drawOrder                 = [DrawOrder.line.rawValue, DrawOrder.bar.rawValue]
        
        // MARK: xAxis
        let xAxis                           = chartView.xAxis
        xAxis.labelPosition                 = .bottom
        xAxis.axisMinimum                   = 0.0
        xAxis.labelFont = NSUIFont(name: "SFProText-Semibold", size: 7.0) ?? NSUIFont.systemFont(ofSize: 10)
        xAxis.granularity                   = 1.0
        xAxis.valueFormatter                = BarChartFormatter()
        xAxis.centerAxisLabelsEnabled = false
        xAxis.setLabelCount(ITEM_COUNT, force: true)
        
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = .white
        xAxis.avoidFirstLastClippingEnabled = true
        
        // MARK: leftAxis
        let leftAxis                        = chartView.leftAxis
        leftAxis.drawGridLinesEnabled       = false
        leftAxis.drawLabelsEnabled = false
        leftAxis.axisMinimum                = 0.0
        
        //leftAxis.nameAxis = "left Axis"
        //leftAxis.nameAxisEnabled = true

        // MARK: rightAxis
        let rightAxis                       = chartView.rightAxis
        rightAxis.drawGridLinesEnabled      = false
        rightAxis.axisMinimum               = 0.0
        rightAxis.drawLabelsEnabled = false

        //rightAxis.nameAxis = "right Axis"
        //rightAxis.nameAxisEnabled = true
    
        // MARK: legend
        let legend                          = chartView.legend
        legend.wordWrapEnabled              = true
        legend.horizontalAlignment          = .center
        legend.verticalAlignment            = .bottom
        legend.orientation                  = .horizontal
        legend.drawInside                   = false
        
        legend.form = .none
        legend.textColor = .clear
        // MARK: description
        chartView.chartDescription?.enabled = false
        
        setChartData()
    }
    
    func setChartData() {
        let data = CombinedChartData()
        data.lineData = generateLineData()
        data.barData = generateBarData()
        chartView.xAxis.axisMaximum = data.xMax + 0.25
        chartView.data = data
    }
    
    func generateLineData() -> LineChartData {
        // MARK: ChartDataEntry
        var entries = [ChartDataEntry]()
                
        for (index, model) in self.userWorkoutStatisticsModel.arrWeeklyDataObj.enumerated() {
            entries.append(ChartDataEntry(x: Double(index), y: Double(model.user_total_burn_calories) ?? 0.0))
        }
        
        // MARK: LineChartDataSet
        let set = LineChartDataSet(entries: entries)

        set.colors = [COLORS.RECIPE_COLOR]
        set.lineWidth = 2.5
        
        set.drawCirclesEnabled = false
        
        set.mode = .cubicBezier
        set.drawValuesEnabled = true
        set.valueTextColor = .clear
        set.axisDependency = .left
        
        // MARK: LineChartData
        let data = LineChartData()
        data.addDataSet(set)
        return data
    }
    
    func generateBarData() -> BarChartData {
        // MARK: BarChartDataEntry
        var entries1 = [BarChartDataEntry]()
        
        for index in 0..<ITEM_COUNT {
            let user_total_duration = self.userWorkoutStatisticsModel.arrWeeklyDataObj[index].user_total_duration.components(separatedBy: .whitespaces).first
            entries1.append(BarChartDataEntry(x: Double(index), y: Double(user_total_duration ?? "0.0") ?? 0.0))
        }
        
        // MARK: BarChartDataSet
        let set1            = BarChartDataSet(entries: entries1)
        set1.colors         = [COLORS.BARCHART_BG_COLOR]
        set1.valueTextColor = .clear
        set1.axisDependency = .left
                
        // MARK: BarChartData
        let groupSpace = 0.06
        let barSpace = 0.01
        let barWidth = 0.46
        
        let data = BarChartData(dataSets: [set1])
        data.barWidth = barWidth
        // make this BarData object grouped
        data.groupBars(fromX: 0.0, groupSpace: groupSpace, barSpace: barSpace)     // start at x = 0
        return data
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
        if role == UserType.user {
            self.viewSettings.isHidden = false
        }
        let userData = AppPrefsManager.sharedInstance.getUserData()
        
        lblUserName.text = "@" + userData.username
        imgUserProfile.setImageFromURL(imgUrl: userData.user_image, placeholderImage: nil)
        imgThumbnail.setImageFromURL(imgUrl: userData.user_image, placeholderImage: nil)
        
        switch isFromSelectedType {
        case SelectedDemandClass.onDemand:
            if arrCoachClassInfoList.count > 0 {
                if safeAreaTop > 20 {
                    lctOndemandTableHeight.constant = (self.view.frame.height - (self.viewNavbar.frame.height) - (safeAreaTop + 14))
                } else {
                    lctOndemandTableHeight.constant = (self.view.frame.height - (self.viewNavbar.frame.height) - (10.0 + safeAreaTop))
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
                    lctOndemandTableHeight.constant = (self.view.frame.height - (self.viewNavbar.frame.height) - (safeAreaTop + 14))
                } else {
                    lctOndemandTableHeight.constant = (self.view.frame.height - (self.viewNavbar.frame.height) - (10.0 + safeAreaTop))
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
                    lctOndemandTableHeight.constant = (self.view.frame.height - (self.viewNavbar.frame.height) - (safeAreaTop + 14))
                } else {
                    lctOndemandTableHeight.constant = (self.view.frame.height - (self.viewNavbar.frame.height) - (10.0 + safeAreaTop))
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
       // self.lctOndemandTableHeight.constant = self.tblOndemand.contentSize.height
        
        
    }
    
    // MARK: - CLICK EVENTS
    
    @IBAction func btnWorkoutStatisticsClick(_ sender: Any) {
        let nextVC = WorkoutStatisticVC.instantiate(fromAppStoryboard: .Followers)
        self.pushVC(To: nextVC, animated: true)
    }
    
    @IBAction func btnSettingsClick(_ sender: Any) {
        let nextVC = SettingsViewController.viewcontroller()
        DispatchQueue.main.async {
            self.pushVC(To: nextVC, animated: true)
        }
    }
    
    @IBAction func btnSubscriptionClick(_ sender: Any) {
        let vc = ManageSubscriptionListViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnCoachProfileClick(_ sender: Any) {
        let nextVC = CoachViseOnDemandClassViewController.viewcontroller()
        if role == UserType.coach {
            nextVC.selectedCoachId = self.selectedCoachId
            self.pushVC(To: nextVC, animated: true)
        }
    }
    
    @IBAction func clickToBtnCoachProfile( _ sender : UIButton) {
       
    }
    
    @IBAction func clickToBtnUser( _ sender : UIButton) {
        let vc = CoachViseOnDemandClassViewController.viewcontroller()
        if isFromSelectedType == SelectedDemandClass.recipe {
            vc.selectedCoachId = self.arrCoachRecipe[sender.tag].coachDetailsObj.id
        } else {
            vc.selectedCoachId = self.arrCoachClassInfoList[sender.tag].coachDetailsObj.id
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension CoachClassProfileViewController : UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            print(self.scrollView.contentOffset.y)
            if safeAreaTop > 20 {
                tblOndemand.isScrollEnabled = (self.scrollView.contentOffset.y >= 225)
            } else {
                tblOndemand.isScrollEnabled = (self.scrollView.contentOffset.y >= 230)
            }
        }
        
        if scrollView == self.tblOndemand {
            self.tblOndemand.isScrollEnabled = (tblOndemand.contentOffset.y > 0)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderTableView") as! HeaderTableView
        headerView.didTapButton = { recdType in
            switch recdType {
            case SelectedDemandClass.onDemand, SelectedDemandClass.live:
                self.resetVariable()
                self.callFollowingCoachClassListAPI()
            case SelectedDemandClass.recipe:
                self.resetRecipeVariable()
                self.getCoachesWiseRecipeList()
            default:
                self.resetVariable()
                self.callFollowingCoachClassListAPI()
            }
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
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
            cell.lblDuration.text = obj.duration
            
            cell.viewProfile.isHidden = false
            if cell.imgProfileBottom.image == nil {
                cell.imgProfileBottom.blurImage()
            }
            cell.viewProfile.addCornerRadius(10)
            cell.viewProfile.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            cell.lblUsername.text = "@\(obj.coachDetailsObj.username)"
            cell.imgProfileBottom.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "")
            cell.imgProfileBanner.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "")
            cell.btnUser.tag = indexPath.row
            cell.btnUser.addTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "")
            cell.lbltitle.text = obj.class_type_name
            cell.lbltitle.text = obj.class_subtitle
            //cell.lblClassDate.text = obj.created_atFormated // uncomment code
            cell.selectedIndex = indexPath.row
            cell.lblClassTime.text = obj.total_viewers + " Views"
            
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_class_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, recdType: SelectedDemandClass.onDemand, selectedIndex: cell.selectedIndex)
            }
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            
            if arrCoachClassInfoList.count - 1 == indexPath.row {
               
                callFollowingCoachClassListAPI()
            }

            cell.layoutIfNeeded()
            return cell
        } else if isFromSelectedType == SelectedDemandClass.live {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseOnDemandClassItemTableViewCell", for: indexPath) as! CoachViseOnDemandClassItemTableViewCell
            cell.lblClassType.text = "Live".uppercased()
            cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#CC2936")
            cell.selectedIndex = indexPath.row
            let obj = arrCoachClassInfoList[indexPath.row]
            cell.lblDuration.text = obj.duration
            
            cell.viewProfile.isHidden = false
            if cell.imgProfileBottom.image == nil {
                cell.imgProfileBottom.blurImage()
            }
            cell.viewProfile.addCornerRadius(10)
            cell.viewProfile.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            cell.lblUsername.text = "@\(obj.coachDetailsObj.username)"
            cell.imgProfileBottom.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "")
            cell.imgProfileBanner.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "")
            cell.btnUser.tag = indexPath.row
            cell.btnUser.addTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)

            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "")
            cell.lbltitle.text = obj.class_type_name
            cell.lbltitle.text = obj.class_subtitle
            //cell.lblClassDate.text = obj.created_atFormated
            cell.lblClassTime.text = obj.total_viewers + " Views"
            
            cell.lblUsername.text = "@\(obj.coachDetailsObj.username)"
            cell.imgProfileBottom.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "")
            cell.imgProfileBanner.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "")
            cell.imgProfileBottom.blurImage()

            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_class_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, recdType: SelectedDemandClass.live, selectedIndex: cell.selectedIndex)
            }
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            
            if arrCoachClassInfoList.count - 1 == indexPath.row {
               
                callFollowingCoachClassListAPI()
            }


            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseRecipeItemTableViewCell", for: indexPath) as! CoachViseRecipeItemTableViewCell
            let obj = arrCoachRecipe[indexPath.row]
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_recipe_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                self.callToAddRemoveBookmarkAPI(urlStr: API.ADD_REMOVE_BOOKMARK, params: param, recdType: SelectedDemandClass.recipe, selectedIndex: cell.selectedIndex)
            }
            cell.selectedIndex = indexPath.row
            cell.lbltitle.text = obj.title
            cell.lblDuration.text = obj.duration
            cell.lblRecipeType.text = obj.arrMealTypeString
            cell.btnUser.tag = indexPath.row
            cell.btnUser.addTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)
            
            var arrFilteredDietaryRestriction = [String]()
            
            if obj.arrdietary_restriction.count > 2 {
                arrFilteredDietaryRestriction.append(obj.arrdietary_restriction[0])
                arrFilteredDietaryRestriction.append(obj.arrdietary_restriction[1])
                cell.arrDietaryRestriction = arrFilteredDietaryRestriction
            } else {
                cell.arrDietaryRestriction = obj.arrdietary_restriction
            }
            
            cell.clvDietaryRestriction.reloadData()
            
            cell.viewProfile.isHidden = false
            if cell.imgProfileBottom.image == nil {
                cell.imgProfileBottom.blurImage()
            }
            cell.viewProfile.addCornerRadius(10)
            cell.viewProfile.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            cell.lblUsername.text = "@\(obj.coachDetailsObj.username)"
            cell.imgProfileBottom.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "")
            cell.imgProfileBanner.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "")

            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            if arrCoachRecipe.count - 1 == indexPath.row {
                
                getCoachesWiseRecipeList()
            }
            
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
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


extension CoachClassProfileViewController {
    
    func callUserWorkoutStatisticsAPI() {
        let api = API.GET_USER_WORKOUT_STATISTIC
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: api, parameters: nil, headers: nil) { responseObj in
            
            self.hideLoader()
            
            if let user_workout_statistics = responseObj["user_workout_statistics"] as? [String:Any] {
                self.userWorkoutStatisticsModel = UserWorkoutStatisticsModel(responseObj: user_workout_statistics)
                self.ITEM_COUNT = self.userWorkoutStatisticsModel.arrWeeklyDataObj.count
                if self.ITEM_COUNT > 0 {
                    self.userWorkoutStatisticsModel.arrWeeklyDataObj.forEach { (allModel) in
                        arrMonths.append(convertUTCToLocal(dateStr: allModel.date, sourceFormate: "yyyy-MM-dd", destinationFormate: "dd MMM"))
                    }
                    self.heightConstantViewStackMain.constant = 16.0
                    self.viewTotalWorkout.isHidden = false
                    self.viewTotalkcalBurnt.isHidden = false
                    self.lblTotalWorkoutDuration.text = self.userWorkoutStatisticsModel.allDataObj.user_total_duration
                    self.lblTotalBurnCalories.text = "\(self.userWorkoutStatisticsModel.allDataObj.user_total_burn_calories) kcal"
                    self.chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
                    self.setupChartUI()
                    self.view.layoutIfNeeded()
                }
            }
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func callFollowingCoachClassListAPI() {
        if(isDataLoading || !continueLoadingData){
            return
        }
        isDataLoading = true
        let classType = isFromSelectedType == SelectedDemandClass.onDemand ? "on_demand" : "live"
        let api = "\(API.FOLLOWING_COACH_CLASS_LIST)?class_type=\(classType)&page_no=\(pageNo)&per_page=\(perPageCount)"
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: api, parameters: nil, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_class_list"] as? [Any] ?? [Any]()
            let arr = CoachClassPrevious.getData(data: dataObj)

            if arr.count > 0 {
                self.arrCoachClassInfoList.append(contentsOf: arr)
            }
            self.setData()

            if arr.count < self.perPageCount
            {
                self.continueLoadingData = false
            }
            self.isDataLoading = false
            self.pageNo += 1
            
            self.hideLoader()

            /*let dataObj = responseObj["coach"] as? [String : Any] ?? [String : Any]()
            let coach_info = dataObj["coach_info"] as? [String : Any] ?? [String : Any]()
            let class_info = dataObj["class_info"] as? [ Any] ?? [ Any]()
                        
            self.arrCoachClassInfoList.append(contentsOf: CoachClassInfoList.getData(data: class_info))
            self.coachInfoDataObj = CoachInfoData(responseObj: coach_info)*/
            
        } failure: { (error) in
            return true
        }
    }
    
    func getCoachesWiseRecipeList() {
        if(isDataLoadingRecipe || !continueLoadingDataRecipe){
            return
        }
        showLoader()
        isDataLoadingRecipe = true
        let api = "\(API.FOLLOWING_COACH_RECIPE_LIST)?page_no=\(pageNoRecipe)&per_page=\(perPageCountRecipe)"

        _ =  ApiCallManager.requestApi(method: .get, urlString: api, parameters: nil, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_recipe_list"] as? [Any] ?? [Any]()
            let arr = PopularRecipeData.getData(data: dataObj)

            if arr.count > 0 {
                self.arrCoachRecipe.append(contentsOf: arr)
            }

            self.setData()
            
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
    
    func callToAddRemoveBookmarkAPI(urlStr: String, params: [String:Any], recdType : String, selectedIndex: Int) {
        showLoader()
        _ =  ApiCallManager.requestApi(method: .post, urlString: urlStr, parameters: params, headers: nil) { responseObj in
            
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
                if Reachability.isConnectedToNetwork() {
                    self.callFollowingCoachClassListAPI()
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


struct UserType {
    static let user = "user"
    static let coach = "coach"
}

extension CoachClassProfileViewController: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("chartValueSelected : x = \(highlight.x)")
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("chartValueNothingSelected")
    }
    
    public class BarChartFormatter: NSObject, IAxisValueFormatter
    {
        var months: [String]! = arrMonths
        
        public func stringForValue(_ value: Double, axis: AxisBase?) -> String
        {
            let modu =  Double(value).truncatingRemainder(dividingBy: Double(months.count))
            return months[Int(modu) ]
        }
    }
}
