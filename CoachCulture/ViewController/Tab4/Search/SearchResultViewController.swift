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
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        getAllCoachClassList()
    }
    
    func setUpUI() {
        setLiveDemandClass()
        
        customDatePickerForSelectTime = CustomDatePickerViewForTextFeild(textField: txtDummyTime, format: "HH:mm", mode: .time)
        customDatePickerForSelectTime.pickerView { (str, date) in
            self.lblTime.text = str
        }
        
        clvDateTime.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvDateTime.delegate = self
        clvDateTime.dataSource = self
        clvDateTime.reloadData()
        
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
            for i in 0...3 {
                let nsDate = Date().addDays(0+i).getDateStringWithFormate("EEE dd", timezone: "UTC")
                let date = Date().addDays(0+i).getDateStringWithFormate("yyyy-MM-dd", timezone: "UTC")
                
                let obj = ClassDate()
                obj.strDate = nsDate
                obj.date = date
                arrDates.append(obj)
            }
            
            lblTime.text = Date().getDateStringWithFormate("HH:mm", timezone: "UTC")
            
            clvDateTime.reloadData()
            
            class_date = arrDates.first!.date
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
        if class_date.isEmpty {
            class_date = arrDates[indexPath.row].date
        } else {
            class_date = ""
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultItemTableViewCell", for: indexPath) as! SearchResultItemTableViewCell
        let obj = arrCoachClassList[indexPath.row]
        cell.lblClassType.text = "On demand".uppercased()
        cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
        cell.imgUser.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "coverBG")
        cell.imgThumbnail.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: "coverBG")
        cell.imgThumbnail.blurImage()
        cell.imgClassCover.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "coverBG")
        cell.lbltitle.text = obj.class_type_name
        cell.lblClassDifficultyLevel.text = obj.class_difficulty_name
        cell.lblClassDate.text = obj.class_date
        cell.lblUserName.text = "@" + obj.coachDetailsObj.username
        cell.lblClassTime.text = obj.class_time
        cell.lblDuration.text = obj.duration
        
        if obj.bookmark == "no" {
            cell.imgBookMark.image = UIImage(named: "BookmarkLight")
        } else {
            cell.imgBookMark.image = UIImage(named: "Bookmark")
        }
        
        if arrCoachClassList.count - 1 == indexPath.row {
           
            getAllCoachClassList()
        }
        
        return cell
        
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



extension SearchResultViewController {
    
    func getAllCoachClassList() {
        
        if(isDataLoading || !continueLoadingData){
            return
        }
        
        isDataLoading = true
        showLoader()
        var param = [String:Any]()
        
        param["page_no"] = "\(pageNo)"
        param["per_page"] = "\(perPageCount)"
        param["coach_only"] = "\(coach_only)"
        param["bookmark_only"] = "\(bookmark_only)"
        param["max_duration"] = "\(max_duration)"
        param["min_duration"] = "\(min_duration)"
        param["class_difficulty_name"] = "\(class_difficulty_name)"
        param["class_type_name"] = "\(class_type_name)"
        param["class_date"] = "\(class_date)"
        param["class_time"] = lblTime.text
        param["search"] = "\(searchString)"
        param["class_type"] = "\(class_type)"

        
        paramForApi = param
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_COACH_CLASS_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_class_list"] as? [Any] ?? [Any]()
            let arr = CoachClassPrevious.getData(data: dataObj)
            self.arrCoachClassList.append(contentsOf: arr)
            self.tblSearchResult.layoutIfNeeded()
            self.tblSearchResult.reloadData()
            
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
        getAllCoachClassList()
    }
    
}


