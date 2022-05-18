
import UIKit
import Charts

var arrMonths = [String]()

class WorkoutStatisticVC: BaseViewController {
    
    //MARK: - OUTLET
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tblPreviousClassView: UITableView!
    @IBOutlet weak var lctOndemandTableHeight: NSLayoutConstraint!
    @IBOutlet weak var viewNoDataFound: UIView!
    @IBOutlet weak var viewNavbar: UIView!
    @IBOutlet weak var viewTotalWorkoutDuration: UIView!
    @IBOutlet weak var lblTotalWorkoutDuration: UILabel!
    @IBOutlet weak var lblTotalBurnCalories: UILabel!
    @IBOutlet var chartView: CombinedChartView!
    @IBOutlet weak var viewTotalWorkout: UIView!
    @IBOutlet weak var viewTotalkcalBurnt: UIView!
    
    //MARK: - VARIABLE AND OBJECT
    
    let safeAreaTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0.0
    var kHomeNewClassHeaderViewID = "HomeNewClassHeaderView"
    var arrCoachClassInfoList = [CoachClassPrevious]()
    var kCoachViseOnDemandClassItemTableViewCellID = "CoachViseOnDemandClassItemTableViewCell"
    var userWorkoutStatisticsModel = UserWorkoutStatisticsModel()
    var pageNo = 1
    var perPageCount = 10
    var isDataLoading = false
    var continueLoadingData = true
    var maxMin = 0.0
    var ITEM_COUNT  = 0
    
    //MARK: - VIEW CONTROLLER LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initialSetupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.showTabBar()
    }
    
    //MARK: - FUNCTION
    
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
        xAxis.labelFont = NSUIFont(name: "SFProText-Regular", size: 8.0) ?? NSUIFont.systemFont(ofSize: 10)
        xAxis.axisMinimum                   = -0.5
        xAxis.granularity                   = -0.5
        xAxis.valueFormatter                = BarChartFormatter()
        xAxis.centerAxisLabelsEnabled = false
        xAxis.setLabelCount(ITEM_COUNT + 2, force: true)
                
//        xAxis.granularity = 1.0
//        xAxis.granularityEnabled = true
//        xAxis.labelCount = 9
        
        xAxis.drawGridLinesEnabled = false
        xAxis.labelTextColor = .white
        xAxis.avoidFirstLastClippingEnabled = true
        
        // MARK: leftAxis
        let leftAxis                        = chartView.leftAxis
        leftAxis.drawGridLinesEnabled       = false
        leftAxis.axisMinimum                = 0.0
        leftAxis.drawLabelsEnabled = false
        
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
    
    private func getGradientFilling() -> CGGradient {
        // Setting fill gradient color
        let coloTop = UIColor(red: 141/255, green: 133/255, blue: 220/255, alpha: 1).cgColor
        let colorBottom = UIColor(red: 230/255, green: 155/255, blue: 210/255, alpha: 1).cgColor
        // Colors of the gradient
        let gradientColors = [coloTop, colorBottom] as CFArray
        // Positioning of the gradient
        let colorLocations: [CGFloat] = [0.7, 0.0]
        // Gradient Object
        return CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)!
    }

    func setChartData() {
        let data = CombinedChartData()
        data.barData = generateBarData()
        data.lineData = generateLineData()
        chartView.xAxis.axisMaximum = data.xMax + 0.25
        chartView.data = data
    }
    
    func generateLineData() -> LineChartData {
        // MARK: ChartDataEntry
        var entries = [ChartDataEntry]()
                
        for i in 0..<self.ITEM_COUNT + 2 {
            if i != 0 && i != 8 {
                let model = self.userWorkoutStatisticsModel.arrWeeklyDataObj
                let value = Double(model[i - 1].user_total_burn_calories)! * 1000
                let devideValue = value / maxMin
                let mainValue = devideValue / 1000
                entries.append(ChartDataEntry(x: Double(i), y: 2))
            } else {
                entries.append(ChartDataEntry(x: 0, y: 0))
            }
        }
        
        // MARK: LineChartDataSet
        let set = LineChartDataSet(entries: entries)

        set.colors = [COLORS.RECIPE_COLOR]
        set.lineWidth = 2.5
        set.drawCirclesEnabled = false
        set.circleColors = [COLORS.RECIPE_COLOR]
        set.circleHoleRadius = 2.5
        set.fillColor = COLORS.RECIPE_COLOR
        
        set.mode = .cubicBezier
        set.drawValuesEnabled = true
        set.valueFont = NSUIFont(name: "SFProText-Regular", size: 9) ?? NSUIFont.systemFont(ofSize: CGFloat(9.0))
        set.valueColors = [COLORS.RECIPE_COLOR]
        set.valueTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        set.axisDependency = .left
        
        // MARK: LineChartData
        let data = LineChartData()
        data.addDataSet(set)
        return data
    }
    
    func generateBarData() -> BarChartData {
        // MARK: BarChartDataEntry
        var entries1 = [BarChartDataEntry]()
        
        for index in 0..<ITEM_COUNT + 2 {
            if index != 0 || index != 8 {
                let user_total_duration = "20"//self.userWorkoutStatisticsModel.arrWeeklyDataObj[index].user_total_duration.components(separatedBy: .whitespaces).first
                entries1.append(BarChartDataEntry(x: Double(index), y: Double(user_total_duration ?? "0.0") ?? 0.0))
                if Double("20" ?? "")! > maxMin {
                    maxMin = Double(100)
                }
            } else {
                entries1.append(BarChartDataEntry(x: Double(0), y: Double(0)))
            }
        }
        
        // MARK: BarChartDataSet
        let set1            = BarChartDataSet(entries: entries1)
        set1.colors         = [UIColor(cgColor: #colorLiteral(red: 0, green: 0.9607843137, blue: 1, alpha: 1)),UIColor(cgColor: #colorLiteral(red: 0.8862745098, green: 0, blue: 1, alpha: 1))]
        set1.valueTextColor = .white
        set1.valueFont      = NSUIFont(name: "SFProText-Regular", size: 10) ?? NSUIFont.systemFont(ofSize: CGFloat(10.0))
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

    func initialSetupUI() {
        ChartUtils.getAndSetForWorkoutStat(isFromStat: true)
        //self.chartView.backgroundColor = COLORS.CHART_BG_COLOR
        self.hideTabBar()
        tblPreviousClassView.register(UINib(nibName: kHomeNewClassHeaderViewID, bundle: nil), forHeaderFooterViewReuseIdentifier: kHomeNewClassHeaderViewID)
        tblPreviousClassView.register(UINib(nibName: kCoachViseOnDemandClassItemTableViewCellID, bundle: nil), forCellReuseIdentifier: kCoachViseOnDemandClassItemTableViewCellID)
        tblPreviousClassView.delegate = self
        tblPreviousClassView.dataSource = self
        
        self.tblPreviousClassView.isScrollEnabled = false
        self.scrollView.delegate = self

        if Reachability.isConnectedToNetwork() {
            callUserWorkoutStatisticsAPI()
            callgetUserPreviousClassAPI()
        }
    }
    
    func resetVariable() {
        arrCoachClassInfoList.removeAll()
        isDataLoading = false
        continueLoadingData = true
        pageNo = 1
        perPageCount = 10
    }

    //MARK: - API CALLING
    
    func callgetUserPreviousClassAPI() {
        if(isDataLoading || !continueLoadingData){
            return
        }
        
        isDataLoading = true

        let api = "\(API.GET_USER_PREVIOUS_CLASS)?page_no=\(pageNo)&per_page=\(perPageCount)" 
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: api, parameters: nil, headers: nil) { responseObj in
            
            let dataObj = responseObj["user_previous_class"] as? [Any] ?? [Any]()
            let arr = CoachClassPrevious.getData(data: dataObj)

            if arr.count > 0 {
                self.arrCoachClassInfoList.append(contentsOf: arr)
            }

            if self.arrCoachClassInfoList.count > 0 {
                if self.safeAreaTop > 20 {
                    self.lctOndemandTableHeight.constant = (self.view.frame.height - (self.viewNavbar.frame.height) - (self.safeAreaTop + 44))
                } else {
                    self.lctOndemandTableHeight.constant = (self.view.frame.height - (self.viewNavbar.frame.height) - (self.safeAreaTop))
                }
                self.viewNoDataFound.isHidden = true
                DispatchQueue.main.async {
                    self.tblPreviousClassView.reloadData()
                }
            } else {
                self.lctOndemandTableHeight.constant = 200.0
                self.viewNoDataFound.isHidden = false
            }
            
            if arr.count < self.perPageCount {
                self.continueLoadingData = false
            }
            
            self.isDataLoading = false
            self.pageNo += 1
            
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func callUserWorkoutStatisticsAPI() {
        let api = API.GET_USER_WORKOUT_STATISTIC
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: api, parameters: nil, headers: nil) { responseObj in
            
            self.hideLoader()
            
            if let user_workout_statistics = responseObj["user_workout_statistics"] as? [String:Any] {
                self.userWorkoutStatisticsModel = UserWorkoutStatisticsModel(responseObj: user_workout_statistics)
                self.ITEM_COUNT = self.userWorkoutStatisticsModel.arrWeeklyDataObj.count
                if self.ITEM_COUNT > 0 {
                    arrMonths = []
                    self.userWorkoutStatisticsModel.arrWeeklyDataObj.forEach { (allModel) in
                        arrMonths.append(convertUTCToLocal(dateStr: allModel.date, sourceFormate: "yyyy-MM-dd", destinationFormate: "dd MMM"))
                    }
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
    
    //MARK: - ACTION
}

//MARK: - EXTENSION TABLE

extension WorkoutStatisticVC : UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            print(self.scrollView.contentOffset.y)
            tblPreviousClassView.isScrollEnabled = (self.scrollView.contentOffset.y >= 320)
        }
        
        if scrollView == self.tblPreviousClassView {
            self.tblPreviousClassView.isScrollEnabled = (tblPreviousClassView.contentOffset.y > 0)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: kHomeNewClassHeaderViewID) as? HomeNewClassHeaderView {
            headerView.lblTitle.text = "Previous Classes"
            return headerView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrCoachClassInfoList.count
    }
    
    @objc func clickToBtnUser( _ sender : UIButton) {
        let vc = CoachViseOnDemandClassViewController.viewcontroller()
        vc.selectedCoachId = self.arrCoachClassInfoList[sender.tag].coachDetailsObj.id
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let obj = self.arrCoachClassInfoList[indexPath.row]

        if obj.coach_class_type == "on_demand" {
            let cell = tableView.dequeueReusableCell(withIdentifier: kCoachViseOnDemandClassItemTableViewCellID, for: indexPath) as! CoachViseOnDemandClassItemTableViewCell
            
            cell.lblClassType.text = "On demand".uppercased()
            cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
            cell.viewDuration.layer.maskedCorners = [.layerMinXMinYCorner]
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
            
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "")
            cell.lbltitle.text = obj.class_type_name
            cell.lblClassDate.text = convertUTCToLocal(dateStr: obj.created_at, sourceFormate: "yyyy-MM-dd HH:mm:ss", destinationFormate: "dd MMM yyyy")
            cell.selectedIndex = indexPath.row
            cell.lblClassTime.text = obj.total_viewers + " Views"
            cell.lblClassDifficultyLevel.text = obj.class_subtitle
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_class_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                if Reachability.isConnectedToNetwork() {
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
                    callgetUserPreviousClassAPI()
                }
            }
            cell.btnUser.tag = indexPath.row
            cell.btnUser.removeTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)
            cell.btnUser.addTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)

            cell.layoutIfNeeded()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseOnDemandClassItemTableViewCell", for: indexPath) as! CoachViseOnDemandClassItemTableViewCell
            cell.lblClassType.text = "Live".uppercased()
            cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#CC2936")
            cell.selectedIndex = indexPath.row
            cell.viewDuration.layer.maskedCorners = [.layerMinXMinYCorner]
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
            
            cell.imgUser.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "")
            cell.lbltitle.text = obj.class_type_name
            cell.lblClassDate.text = convertUTCToLocal(dateStr: obj.created_at, sourceFormate: "yyyy-MM-dd HH:mm:ss", destinationFormate: "dd MMM yyyy")
            cell.lblClassTime.text = obj.total_viewers + " Views"
            
            cell.lblUsername.text = "@\(obj.coachDetailsObj.username)"
            cell.imgProfileBottom.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "")
            cell.imgProfileBanner.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "")
            cell.imgProfileBottom.blurImage()
            cell.lblClassDifficultyLevel.text = obj.class_subtitle
            
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_class_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                if Reachability.isConnectedToNetwork() {
                    self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, recdType: SelectedDemandClass.live, selectedIndex: cell.selectedIndex)
                }
            }
            if obj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            
            if arrCoachClassInfoList.count != 1 {
                if arrCoachClassInfoList.count - 1 == indexPath.row {
                    callgetUserPreviousClassAPI()
                }
            }
            cell.btnUser.tag = indexPath.row
            cell.btnUser.removeTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)
            cell.btnUser.addTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)

            return cell
        }
    }
    
    func callToAddRemoveBookmarkAPI(urlStr: String, params: [String:Any], recdType : String, selectedIndex: Int) {
        showLoader()
        _ =  ApiCallManager.requestApi(method: .post, urlString: urlStr, parameters: params, headers: nil) { responseObj in
            
            if let message = responseObj["message"] as? String {
                Utility.shared.showToast(message)
            }
            
            switch recdType {
            case SelectedDemandClass.onDemand, SelectedDemandClass.live:
                for (index, model) in self.arrCoachClassInfoList.enumerated() {
                    if selectedIndex == index {
                        model.bookmark = model.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                        self.arrCoachClassInfoList[index] = model
                        DispatchQueue.main.async {
                            self.tblPreviousClassView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                        break
                    }
                }
            default:
                self.resetVariable()
                if Reachability.isConnectedToNetwork() {
                    self.callgetUserPreviousClassAPI()
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
        let vc = LiveClassDetailsViewController.viewcontroller()
        let obj = arrCoachClassInfoList[indexPath.row]
        vc.selectedId = obj.id
        self.pushVC(To: vc, animated: true)
    }
}

extension WorkoutStatisticVC: ChartViewDelegate {
    
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
            let tempValue = Double(value).truncatingRemainder(dividingBy: Double(months.count)).rounded()
            let modu = tempValue <= 0 ? 0 : tempValue
            return months[Int(modu)]
        }
    }
}
