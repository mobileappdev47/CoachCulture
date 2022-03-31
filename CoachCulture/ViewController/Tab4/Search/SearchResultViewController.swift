//
//  SearchResultViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 18/12/21.
//

import UIKit

class SearchResultViewController: BaseViewController {
    
    static func viewcontroller() -> SearchResultViewController {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "SearchResultViewController") as! SearchResultViewController
        return vc
    }
    
    @IBOutlet weak var viewNoDataFound: UIView!
    @IBOutlet weak var clvDateTime: UICollectionView!
    @IBOutlet weak var tblSearchResult: UITableView!
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var txtDummyTime: UITextField!

    @IBOutlet weak var viwLiveClassTime: UIView!
    @IBOutlet weak var viwSearchFilter: UIView!
    
    var customDatePickerForSelectTime:CustomDatePickerViewForTextFeild!
    
    var arrCoachClassList = [CoachClassPrevious]()
    
    var isDataLoading = false
    var continueLoadingData = true
    var pageNo = 1
    var perPageCount = 10
    var class_date = ""
    
    var searchString = ""
    var class_type_name = ""
    var class_type = ""
    var coach_only = "no"
    var bookmark_only = "no"
    var max_duration = ""
    var min_duration = ""
    var class_difficulty_name = ""
    
    var arrDates = [ClassDate]()
    var paramForApi = [String:Any]()
    var start_datetime = ""
    var end_datetime = ""
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        getAllCoachClassList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let layout = clvDateTime.collectionViewLayout as! UICollectionViewFlowLayout

        let noOfCell: CGFloat = 4
        let totalGivenMarginToCLNView: CGFloat = 10
        let minimumInteritemSpacingForSectionAt: CGFloat = 10
        let margin = totalGivenMarginToCLNView + minimumInteritemSpacingForSectionAt
        
        let width  = (self.clvDateTime.frame.width - margin) / noOfCell
        let height  = CGFloat(35.0)

        layout.itemSize = CGSize(width: width, height: height)
        clvDateTime.collectionViewLayout = layout
        DispatchQueue.main.async {
            self.clvDateTime.reloadData()
        }
    }
    
    func setUpUI() {
        setLiveDemandClass()
        
        customDatePickerForSelectTime = CustomDatePickerViewForTextFeild(textField: txtDummyTime, format: "HH:mm", mode: .time)
        customDatePickerForSelectTime.pickerView { (str, date) in
            let currentHrsMinutes = str.components(separatedBy: ":")
            self.lblTime.text = "\(currentHrsMinutes.first ?? "00"):\(Int(currentHrsMinutes.last ?? "00")?.roundMinutes() ?? "00")"
        }
        
        clvDateTime.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvDateTime.delegate = self
        clvDateTime.dataSource = self
        clvDateTime.reloadData()
        
        tblSearchResult.register(UINib(nibName: "CoachViseOnDemandClassItemTableViewCell", bundle: nil), forCellReuseIdentifier: "CoachViseOnDemandClassItemTableViewCell")

        tblSearchResult.register(UINib(nibName: "SearchResultItemTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchResultItemTableViewCell")
        tblSearchResult.delegate = self
        tblSearchResult.dataSource = self
        txtSearch.delegate = self
        
        hideTabBar()
    }
    
    func setLiveDemandClass() {
        if class_type == CoachClassType.live {
            viwSearchFilter.isHidden = true
            viwLiveClassTime.isHidden = false
            arrDates.removeAll()
            for i in 0...4 {
                let nsDate = Date().addDays(0+i).getDateStringWithFormate("EEE dd", timezone: "UTC")
                let date = Date().addDays(0+i).getDateStringWithFormate("yyyy-MM-dd", timezone: "UTC")
                
                let obj = ClassDate()
                obj.strDate = nsDate
                obj.date = date
                arrDates.append(obj)
            }
            let currentHrsMinutes = Calendar.current.dateComponents([.hour, .minute], from: Date())
            lblTime.text = "\(currentHrsMinutes.hour ?? 00):\(currentHrsMinutes.minute?.roundMinutes() ?? "00")"
            
            clvDateTime.reloadData()
            
            class_date = arrDates.first!.date
            start_datetime = convertToUTC(dateToConvert: "\(class_date) \(lblTime.text ?? "")", dateFormate: "yyyy-MM-dd HH:mm")
            end_datetime = convertToUTC(dateToConvert: "\(class_date) 23:59", dateFormate: "yyyy-MM-dd HH:mm")
        } else {
            viwSearchFilter.isHidden = false
            viwLiveClassTime.isHidden = true
        }
    }
    
    func resetVariable() {
        isDataLoading = false
        continueLoadingData = true
        pageNo = 1
        perPageCount = 10
        arrCoachClassList.removeAll()
        
    }
    
    // MARK: - CLICK EVENTS
    @IBAction func clickToBtnFilter( _ sender : UIButton) {
        
        let vc = ClassFilterViewController.viewcontroller()
        vc.searchResultVC = self
        vc.param = self.paramForApi
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension SearchResultViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrDates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MuscleItemCollectionViewCell", for: indexPath) as!  MuscleItemCollectionViewCell
        
        cell.lblTitle.text = arrDates[indexPath.row].strDate
        if class_date == arrDates[indexPath.row].date {
            cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
        } else {
            cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width =  (clvDateTime.frame.width - 20 ) / 4
        
        return CGSize(width: width, height: 35)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if class_date == arrDates[indexPath.row].date {
            class_date = ""
        } else {
            class_date = arrDates[indexPath.row].date
            start_datetime = convertToUTC(dateToConvert: "\(class_date) \(lblTime.text ?? "")", dateFormate: "yyyy-MM-dd HH:mm")
            end_datetime = convertToUTC(dateToConvert: "\(class_date) 23:59", dateFormate: "yyyy-MM-dd HH:mm")
        }

        collectionView.reloadData()
        self.resetVariable()
        getAllCoachClassList()
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchResultViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrCoachClassList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoachViseOnDemandClassItemTableViewCell", for: indexPath) as! CoachViseOnDemandClassItemTableViewCell
        
        if indexPath.row < arrCoachClassList.count {
            let obj = arrCoachClassList[indexPath.row]

            if class_type == CoachClassType.live {
                cell.lblClassType.text = "Live".uppercased()
                cell.lblClassTime.text = convertUTCToLocal(dateStr: obj.class_time, sourceFormate: "HH:mm", destinationFormate: "HH:mm")
                cell.viwClassTypeContainer.backgroundColor = COLORS.THEME_RED
            } else {
                cell.lblClassType.text = "On demand".uppercased()
                cell.lblClassTime.text = obj.total_viewers + " Views"
                cell.viwClassTypeContainer.backgroundColor = COLORS.ON_DEMAND_COLOR
            }
            cell.lblDuration.layer.maskedCorners = [.layerMinXMinYCorner]
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
            cell.lblClassDifficultyLevel.text = obj.class_subtitle
            cell.lblClassDate.text = convertUTCToLocal(dateStr: obj.created_at, sourceFormate: "yyyy-MM-dd HH:mm:ss", destinationFormate: "dd MMM yyyy")
            cell.selectedIndex = indexPath.row
                    
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
            
            if arrCoachClassList.count - 1 == indexPath.row {
               
                getAllCoachClassList()
            }
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func callToAddRemoveBookmarkAPI(urlStr: String, params: [String:Any], recdType : String, selectedIndex: Int) {
        showLoader()
        _ =  ApiCallManager.requestApi(method: .post, urlString: urlStr, parameters: params, headers: nil) { responseObj in
            
            if let message = responseObj["message"] as? String, !message.isEmpty {
                Utility.shared.showToast(message)
            }
            switch recdType {
            case SelectedDemandClass.onDemand, SelectedDemandClass.live:
                for (index, model) in self.arrCoachClassList.enumerated() {
                    if selectedIndex == index {
                        model.bookmark = model.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                        self.arrCoachClassList[index] = model
                        DispatchQueue.main.async {
                            self.tblSearchResult.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                        break
                    }
                }
            default:
                self.resetVariable()
                self.getAllCoachClassList()
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
        let obj = arrCoachClassList[indexPath.row]
        vc.selectedId = obj.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



extension SearchResultViewController {
    
    func getAllCoachClassList() {
        
        if(isDataLoading || !continueLoadingData){
            return
        }
        
        isDataLoading = true
        showLoader()
        
        var param = [String:Any]()

        if !class_difficulty_name.isEmpty || class_difficulty_name != "" {
            param["class_difficulty_name"] = class_difficulty_name
        }
        if !class_type_name.isEmpty || class_type_name != "" {
            param["class_type_name"] = class_type_name
        }
        if !min_duration.isEmpty || min_duration != "" {
            param["min_duration"] = min_duration
        }
        if !max_duration.isEmpty || max_duration != "" {
            param["max_duration"] = max_duration
        }
        if !searchString.isEmpty || searchString != "" {
            param["search"] = searchString
        }
        if (!class_date.isEmpty || class_date != "") && class_type != CoachClassType.onDemand {
            param["start_datetime"] = start_datetime
            param["end_datetime"] = end_datetime
        }
        
        param["page_no"] = "\(pageNo)"
        param["per_page"] = "\(perPageCount)"
        param["coach_only"] = "\(coach_only)"
        param["bookmark_only"] = "\(bookmark_only)"
        param["class_type"] = "\(class_type)"
        
        paramForApi = param
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_COACH_CLASS_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_class_list"] as? [Any] ?? [Any]()
            let arr = CoachClassPrevious.getData(data: dataObj)
            
            if arr.count > 0 {
                self.arrCoachClassList.append(contentsOf: arr)
            }
            if self.arrCoachClassList.count > 0 {
                self.viewNoDataFound.isHidden = true
                self.tblSearchResult.layoutIfNeeded()
                self.tblSearchResult.reloadData()
            } else {
                self.viewNoDataFound.isHidden = false
            }
            
            if arr.count < self.perPageCount
            {
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
}

//MARK: - UITextFieldDelegate
extension SearchResultViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        searchString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.resetVariable()
        if Reachability.isConnectedToNetwork(){
            getAllCoachClassList()
        }
    }
    
}


extension Int {
    func roundMinutes() -> String {
        var roundMinutes = "00"
        switch self {
        case 0...14:
            roundMinutes = "00"
        case 15...29:
            roundMinutes = "15"
        case 30...44:
            roundMinutes = "30"
        case 45...59:
            roundMinutes = "45"
        default:
            roundMinutes = "00"
        }
        return roundMinutes
    }
}
