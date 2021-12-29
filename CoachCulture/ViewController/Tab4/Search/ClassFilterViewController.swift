//
//  ClassFilterViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit

class ClassFilterViewController: BaseViewController {
    
    static func viewcontroller() -> ClassFilterViewController {
        let vc = UIStoryboard(name: "Search", bundle: nil).instantiateViewController(withIdentifier: "ClassFilterViewController") as! ClassFilterViewController
        return vc
    }
    
    @IBOutlet weak var clvClassType : UICollectionView!
    @IBOutlet weak var lctClassTypeHeight : NSLayoutConstraint!
    
    @IBOutlet weak var clvDifficultyLevel : UICollectionView!
    
    @IBOutlet weak var btnLive : UIButton!
    @IBOutlet weak var btnOnDemand : UIButton!
    @IBOutlet weak var btnMinClassDuration : UIButton!
    @IBOutlet weak var btnMaxClassDuration : UIButton!
    @IBOutlet weak var btnMyCoach : UIButton!
    @IBOutlet weak var btnBookMark : UIButton!

   
    var selectedButtonForDuration = UIButton()
    
    @IBOutlet weak var lblMinClassDuration : UILabel!
    @IBOutlet weak var lblMaxClassDuration : UILabel!

    @IBOutlet weak var viwLive : UIView!
    @IBOutlet weak var viwOnDemand : UIView!
    @IBOutlet weak var viwBookmarkOnly : UIView!
    @IBOutlet weak var viwMyCoachesOnly : UIView!
    
    var classDuration : ClassDuration!
    
    var arrClassTypeList = [ClassTypeList]()
    var arrClassDifficultyList = [ClassDifficultyList]()
    var previousClassVC : PreviousClassesViewController!
    var searchResultVC : SearchResultViewController!

    var isFromBookMarkPage = false
    
    var param = [String:Any]()
    
    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    
    // MARK: - METHODS
    func setUpUI() {
        
        clvClassType.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvClassType.delegate = self
        clvClassType.dataSource = self
        
        clvDifficultyLevel.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvDifficultyLevel.delegate = self
        clvDifficultyLevel.dataSource = self
        
        classDuration = Bundle.main.loadNibNamed("ClassDuration", owner: nil, options: nil)?.first as? ClassDuration
        classDuration.tapToBtnSelectItem { obj in
            if self.selectedButtonForDuration == self.btnMinClassDuration {
                self.lblMinClassDuration.text = obj + " mins"
            } else {
                self.lblMaxClassDuration.text = obj + " mins"
            }
            
        }
        
        viwBookmarkOnly.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        viwMyCoachesOnly.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        
        clickToBtnClassType(btnLive)
        
        getClassType()
        
    }
    
    func setData() {
        let coach_only = param["coach_only"] as? String ?? ""
        let bookmark_only = param["bookmark_only"] as? String ?? ""
        if coach_only == "yes" {
            viwMyCoachesOnly.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
            btnMyCoach.isSelected = true
        }
        
        if bookmark_only == "yes" {
            viwBookmarkOnly.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
            btnBookMark.isSelected = true
        }
        
        let clssType = param["class_type"] as? String ?? ""
        btnLive.isSelected = false
        btnOnDemand.isSelected = false
        if clssType == CoachClassType.live {
            clickToBtnClassType(btnLive)
        } else {
            clickToBtnClassType(btnOnDemand)
        }
        
        self.lblMinClassDuration.text = param["min_duration"] as? String ?? ""
        self.lblMaxClassDuration.text = param["max_duration"] as? String ?? ""
        
        if lblMaxClassDuration.text!.isEmpty {
            self.lblMaxClassDuration.text =  "0 mins"
        }
        
        if lblMinClassDuration.text!.isEmpty {
            self.lblMinClassDuration.text =  "0 mins"
        }
        
        
        let arrClassType = (param["class_type_name"] as? String ?? "").components(separatedBy: ",")
        
        for temp in arrClassType {
            let ind = arrClassTypeList.firstIndex { obj in
                return obj.class_type_name.lowercased() == temp.lowercased()
            }
            
            if ind != nil {
                arrClassTypeList[ind!].isSelected = true
            }
        }
        
        let arrclass_difficulty_name = (param["class_difficulty_name"] as? String ?? "").components(separatedBy: ",")
        
        for temp in arrclass_difficulty_name {
            let ind = arrClassDifficultyList.firstIndex { obj in
                return obj.class_difficulty_name.lowercased() == temp.lowercased()
            }
            
            if ind != nil {
                arrClassDifficultyList[ind!].isSelected = true
            }
        }
        
        if isFromBookMarkPage {
            viwBookmarkOnly.isHidden = true
        }
        
        clvClassType.reloadData()
        clvDifficultyLevel.reloadData()
    }
    
    func setClassDurationView(){
        classDuration.frame.size = self.view.frame.size
        self.view.addSubview(classDuration)
    }
    
    func removeClassDurationView(){
        if classDuration != nil{
            classDuration.removeFromSuperview()
        }
        
    }
    
    // MARK: -  CLICK EVENTS
    @IBAction func clickToBtnClassType ( _ sender : UIButton) {
        btnLive.isSelected = false
        btnOnDemand.isSelected = false
        if sender == btnLive {
            btnLive.isSelected = true
            viwLive.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
            viwOnDemand.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        } else {
            btnOnDemand.isSelected = true
            viwOnDemand.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
            viwLive.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        }
    }
    
    @IBAction func clickToBtnBookMarkOnly ( _ sender : UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            viwBookmarkOnly.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
        } else {
            viwBookmarkOnly.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        }
    }
    
    @IBAction func clickToBtnMyCoachOnly ( _ sender : UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            viwMyCoachesOnly.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
        } else {
            viwMyCoachesOnly.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        }
    }
    
    @IBAction func clickToBtnRecipeDuration(_ sender : UIButton) {
        selectedButtonForDuration = sender
        setClassDurationView()
    }
    
    @IBAction func clickToBtnApplyFilter(_ sender : UIButton) {
        var class_difficulty_name = ""
        for temp in arrClassDifficultyList {
            if temp.isSelected {
                if class_difficulty_name.isEmpty {
                    class_difficulty_name =  temp.class_difficulty_name
                } else {
                    class_difficulty_name += "," + temp.class_difficulty_name
                }
            }
        }
        
        var class_type = ""
        
        for temp in arrClassTypeList {
            if temp.isSelected {
                if class_type.isEmpty {
                    class_type = temp.class_type_name
                } else {
                    class_type += "," + temp.class_type_name
                }
            }
        }
        
        if searchResultVC != nil {
            searchResultVC!.resetVariable()
            searchResultVC!.coach_only = btnMyCoach.isSelected ? "yes" : "no"
            searchResultVC!.bookmark_only = btnBookMark.isSelected ? "yes" : "no"
            searchResultVC!.min_duration = self.lblMinClassDuration.text! == "0 mins" ? "" : self.lblMinClassDuration.text!
            searchResultVC!.max_duration = self.lblMaxClassDuration.text! == "0 mins" ? "" : self.lblMaxClassDuration.text!
            searchResultVC!.class_difficulty_name = class_difficulty_name
            searchResultVC!.class_type_name = class_type
            searchResultVC!.class_type = btnLive.isSelected ? "live" : "on_demand"
            searchResultVC!.setLiveDemandClass()
            searchResultVC!.getAllCoachClassList()
            
        }
        
        if previousClassVC != nil {
            previousClassVC!.resetVariable()
            previousClassVC!.coach_only = btnMyCoach.isSelected ? "yes" : "no"
            previousClassVC!.bookmark_only = isFromBookMarkPage ? "yes" : (btnBookMark.isSelected ? "yes" : "no")
            previousClassVC!.min_duration = self.lblMinClassDuration.text! == "0 mins" ? "" : self.lblMinClassDuration.text!
            previousClassVC!.max_duration = self.lblMaxClassDuration.text! == "0 mins" ? "" : self.lblMaxClassDuration.text!
            previousClassVC!.class_difficulty_name = class_difficulty_name
            previousClassVC!.class_type = btnLive.isSelected ? "live" : "on_demand"
            previousClassVC!.getPrevoisCoachClassList()
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
}


// MARK: - API CALL
extension ClassFilterViewController {
    
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
            
            self.getClassDifficultyList()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func getClassDifficultyList() {
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.CLASS_DIFFICULTY_LIST, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()
                self.arrClassDifficultyList = ClassDifficultyList.getData(data: dataObj)
                self.clvDifficultyLevel.reloadData()
            }
            
            self.setData()
            self.hideLoader()
            
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension ClassFilterViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == clvDifficultyLevel {
            return arrClassDifficultyList.count
        }
        return arrClassTypeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == clvDifficultyLevel {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MuscleItemCollectionViewCell", for: indexPath) as!  MuscleItemCollectionViewCell
            let obj  = arrClassDifficultyList[indexPath.row]
            cell.lblTitle.text = obj.class_difficulty_name
            cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
            
            if obj.isSelected {
                cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
            }
            return cell
        } else {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MuscleItemCollectionViewCell", for: indexPath) as!  MuscleItemCollectionViewCell
            let obj  = arrClassTypeList[indexPath.row]
            cell.lblTitle.text = obj.class_type_name
            cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#525F6F")
            
            if obj.isSelected {
                cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
            }
            return cell
        }
                        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width =  (clvClassType.frame.width - 30 ) / 3
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView == clvDifficultyLevel {
            arrClassDifficultyList[indexPath.row].isSelected = !arrClassDifficultyList[indexPath.row].isSelected
            clvDifficultyLevel.reloadData()

        } else {
            arrClassTypeList[indexPath.row].isSelected = !arrClassTypeList[indexPath.row].isSelected
            clvClassType.reloadData()
        }
    }
    
    
}
