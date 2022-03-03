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
    
    @IBOutlet weak var viewClassTypeMain: UIView!
    @IBOutlet weak var viewMaxClassDurationExtra: UIView!
    @IBOutlet weak var viewMyCoachOnlyExtra: UIView!
    @IBOutlet weak var viwBookmarkOnly : UIView!
    @IBOutlet weak var viwMyCoachesOnly : UIView!
    @IBOutlet weak var viewMinClassDuration: UIView!
    @IBOutlet weak var viewMaxClassDuration: UIView!
    
    @IBOutlet weak var heightConstantViewMyCoachesOnly: NSLayoutConstraint!
    @IBOutlet weak var clvClassType : UICollectionView!
    @IBOutlet weak var lctClassTypeHeight : NSLayoutConstraint!
    @IBOutlet weak var clvDifficultyLevel : UICollectionView!
    
    @IBOutlet weak var btnLive : UIButton!
    @IBOutlet weak var btnOnDemand : UIButton!
    @IBOutlet weak var btnMinClassDuration : UIButton!
    @IBOutlet weak var btnMaxClassDuration : UIButton!
    @IBOutlet weak var btnDuration : UIButton!
    @IBOutlet weak var btnMyCoach : UIButton!
    @IBOutlet weak var btnMyCoachExtra : UIButton!
    @IBOutlet weak var btnBookMark : UIButton!

   
    var selectedButtonForDuration = UIButton()
    
    @IBOutlet weak var lblMinClassDuration : UILabel!
    @IBOutlet weak var lblMaxClassDuration : UILabel!
    @IBOutlet weak var lblMaxClassDurationExtra : UILabel!
    @IBOutlet weak var viwLive : UIView!
    @IBOutlet weak var viwOnDemand : UIView!
    
    var classDuration : ClassDuration!
    
    var arrClassTypeList = [ClassTypeList]()
    var arrClassDifficultyList = [ClassDifficultyList]()
    var previousClassVC : PreviousClassesViewController!
    var previousUploadVC : PreviousUploadViewController!
    var searchResultVC : SearchResultViewController!
    var isFromBookMarkPage = false
    var isFromRecipe = false
    var param = [String:Any]()
    var arrMealType = [MealTypeListData]()
    var arrDietaryRestrictionListData = [DietaryRestrictionListData]()

    // MARK: - LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    
    // MARK: - METHODS
    func setUpUI() {
        if previousClassVC != nil && isFromRecipe {
            self.viwBookmarkOnly.isHidden = true
            self.viwMyCoachesOnly.isHidden = true
            self.viewMinClassDuration.isHidden = true
            self.viewMaxClassDuration.isHidden = true
            viewMyCoachOnlyExtra.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
            if Reachability.isConnectedToNetwork(){
                self.callMealTypeAndDietaryRestrictionList()
            }
        } else if previousUploadVC != nil && isFromRecipe {
            self.viwBookmarkOnly.isHidden = true
            self.viwMyCoachesOnly.isHidden = true
            self.viewMinClassDuration.isHidden = true
            self.viewMaxClassDuration.isHidden = true
            viewMyCoachOnlyExtra.isHidden = true
            if Reachability.isConnectedToNetwork(){
                self.callMealTypeAndDietaryRestrictionList()
            }
        } else if previousUploadVC != nil && !isFromRecipe {
            viwMyCoachesOnly.isHidden = true
            self.viewMyCoachOnlyExtra.isHidden = true
            self.viewMaxClassDurationExtra.isHidden = true
            if Reachability.isConnectedToNetwork(){
                getClassType()
            }
        } else if previousClassVC != nil && !isFromRecipe {
            viwMyCoachesOnly.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
            self.viewMyCoachOnlyExtra.isHidden = true
            self.viewMaxClassDurationExtra.isHidden = true
            if Reachability.isConnectedToNetwork(){
                getClassType()
            }
        } else {
            self.viewClassTypeMain.isHidden = false
            self.viewMyCoachOnlyExtra.isHidden = true
            self.viewMaxClassDurationExtra.isHidden = true
            if Reachability.isConnectedToNetwork(){
                getClassType()
            }
        }
        clvClassType.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvClassType.delegate = self
        clvClassType.dataSource = self
        
        clvDifficultyLevel.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvDifficultyLevel.delegate = self
        clvDifficultyLevel.dataSource = self
        
        classDuration = Bundle.main.loadNibNamed("ClassDuration", owner: nil, options: nil)?.first as? ClassDuration
        classDuration.tapToBtnSelectItem { obj in
            if self.selectedButtonForDuration == self.btnMinClassDuration {
                if self.selectedButtonForDuration.isSelected {
                    self.viewMinClassDuration.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
                } else {
                    self.viewMinClassDuration.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
                }
                self.lblMinClassDuration.text = obj + " mins"
            } else if self.selectedButtonForDuration == self.btnMaxClassDuration {
                if self.selectedButtonForDuration.isSelected {
                    self.viewMaxClassDuration.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
                } else {
                    self.viewMaxClassDuration.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
                }
                self.lblMaxClassDuration.text = obj + " mins"
            } else if self.selectedButtonForDuration == self.btnDuration {
                if self.previousClassVC != nil && self.isFromRecipe || (self.previousUploadVC != nil && self.isFromRecipe) {
                    if self.selectedButtonForDuration.isSelected {
                        self.viewMaxClassDurationExtra.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
                    } else {
                        self.viewMaxClassDurationExtra.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
                    }
                    self.lblMaxClassDurationExtra.text = obj + " mins"
                }
            } else {
                self.lblMaxClassDuration.text = obj + " mins"
            }
        }
        viwBookmarkOnly.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        self.view.layoutIfNeeded()
    }
    
    func setData() {
        if previousClassVC != nil && isFromRecipe || previousUploadVC != nil && isFromRecipe {
            let coach_only = param["coach_only"] as? String ?? ""
            if coach_only == "yes" {
                viewMyCoachOnlyExtra.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
                btnMyCoachExtra.isSelected = true
            }
            
            self.lblMaxClassDurationExtra.text = param["duration"] as? String ?? ""
            
            if lblMaxClassDurationExtra.text!.isEmpty {
                self.lblMaxClassDurationExtra.text =  "0 mins"
            } else {
                self.btnDuration.isSelected = true
                self.viewMaxClassDurationExtra.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
            }
                        
            let arrDietaryRestrictionName = (param["dietary_restriction_name"] as? String ?? "").components(separatedBy: ",")
            
            for temp in arrDietaryRestrictionName {
                let ind = self.arrDietaryRestrictionListData.firstIndex { obj in
                    return obj.dietary_restriction_name.lowercased() == temp.lowercased()
                }
                if ind != nil {
                    arrDietaryRestrictionListData[ind!].isSelected = true
                }
            }
            
            let arrMealTypeName = (param["meal_type_name"] as? String ?? "").components(separatedBy: ",")
            
            for temp in arrMealTypeName {
                let ind = self.arrMealType.firstIndex { obj in
                    return obj.meal_type_name.lowercased() == temp.lowercased()
                }
                if ind != nil {
                    arrMealType[ind!].isSelected = true
                }
            }
        } else {
            let coach_only = param["coach_only"] as? String ?? ""
            let bookmark_only = param["bookmark_only"] as? String ?? ""
            if coach_only == "yes" {
                viwMyCoachesOnly.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
                btnMyCoach.isSelected = true
            } else {
                viwMyCoachesOnly.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
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
            
            if lblMinClassDuration.text!.isEmpty {
                self.lblMinClassDuration.text =  "5 mins"
            } else {
                self.btnMinClassDuration.isSelected = true
                self.viewMinClassDuration.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
            }

            if lblMaxClassDuration.text!.isEmpty {
                self.lblMaxClassDuration.text =  "150 mins"
            } else {
                self.btnMaxClassDuration.isSelected = true
                self.viewMaxClassDuration.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
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
        if previousClassVC != nil && isFromRecipe {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                viewMyCoachOnlyExtra.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
            } else {
                viewMyCoachOnlyExtra.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
            }
        } else {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                viwMyCoachesOnly.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
            } else {
                viwMyCoachesOnly.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
            }
        }
    }
    
    @IBAction func clickToBtnRecipeDuration(_ sender : UIButton) {
        if sender == self.btnDuration {
            if (self.previousClassVC != nil && self.isFromRecipe) || (self.previousUploadVC != nil && self.isFromRecipe) {
                self.btnDuration.isSelected = !self.btnDuration.isSelected
                if self.btnDuration.isSelected {
                    selectedButtonForDuration = sender
                    setClassDurationView()
                } else {
                    self.viewMaxClassDurationExtra.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
                }
            }
        } else if sender == self.btnMinClassDuration {
            self.btnMinClassDuration.isSelected = !self.btnMinClassDuration.isSelected
            if self.btnMinClassDuration.isSelected {
                selectedButtonForDuration = sender
                setClassDurationView()
            } else {
                self.viewMinClassDuration.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
            }
        } else if sender == self.btnMaxClassDuration {
            self.btnMaxClassDuration.isSelected = !self.btnMaxClassDuration.isSelected
            if self.btnMaxClassDuration.isSelected {
                selectedButtonForDuration = sender
                setClassDurationView()
            } else {
                self.viewMaxClassDuration.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
            }
        } else {
            selectedButtonForDuration = sender
            setClassDurationView()
        }
    }
    
    @IBAction func clickToBtnApplyFilter(_ sender : UIButton) {
        var class_difficulty_name = ""
        var class_type = ""
        var meal_type_name = ""
        var dietary_restriction_name = ""
        
        if previousClassVC != nil && isFromRecipe {
            for temp in arrMealType {
                if temp.isSelected {
                    if meal_type_name.isEmpty {
                        meal_type_name =  temp.meal_type_name
                    } else {
                        meal_type_name += "," + temp.meal_type_name
                    }
                }
            }
            
            for temp in arrDietaryRestrictionListData {
                if temp.isSelected {
                    if dietary_restriction_name.isEmpty {
                        dietary_restriction_name = temp.dietary_restriction_name
                    } else {
                        dietary_restriction_name += "," + temp.dietary_restriction_name
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
                previousClassVC!.coach_only = btnMyCoachExtra.isSelected ? "yes" : "no"
                
                if self.btnDuration.isSelected {
                    previousClassVC!.duration = self.lblMaxClassDurationExtra.text! == "0 mins" ? "" : self.lblMaxClassDurationExtra.text!
                } else {
                    previousClassVC!.duration.removeAll()
                }
                previousClassVC!.dietary_restriction_name = dietary_restriction_name
                
                let arrFilterMealTypeNameModel = arrMealType.filter({$0.isSelected})
                let arrFilterMealTypeName = arrFilterMealTypeNameModel.map({$0.meal_type_name})
                
                previousClassVC.meal_type_name = arrFilterMealTypeName.joined(separator: ",")
                
                previousClassVC.resetVariable()
                previousClassVC.resetRecipeVariable()
                previousClassVC!.getPrevoisCoachRecipeList()
            }

        } else if previousUploadVC != nil && isFromRecipe {
            for temp in arrMealType {
                if temp.isSelected {
                    if meal_type_name.isEmpty {
                        meal_type_name =  temp.meal_type_name
                    } else {
                        meal_type_name += "," + temp.meal_type_name
                    }
                }
            }
            
            for temp in arrDietaryRestrictionListData {
                if temp.isSelected {
                    if dietary_restriction_name.isEmpty {
                        dietary_restriction_name = temp.dietary_restriction_name
                    } else {
                        dietary_restriction_name += "," + temp.dietary_restriction_name
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
            
            if previousUploadVC != nil {
                previousUploadVC.resetVariable()
                if self.btnDuration.isSelected {
                    previousUploadVC!.duration = self.lblMaxClassDurationExtra.text! == "0 mins" ? "" : self.lblMaxClassDurationExtra.text!
                } else {
                    previousUploadVC!.duration.removeAll()
                }
                previousUploadVC!.dietary_restriction_name = dietary_restriction_name
                
                let arrFilterMealTypeNameModel = arrMealType.filter({$0.isSelected})
                let arrFilterMealTypeName = arrFilterMealTypeNameModel.map({$0.meal_type_name})
                
                previousUploadVC.meal_type_name = arrFilterMealTypeName.joined(separator: ",")
                
                previousUploadVC.resetRecipeVariable()
                previousUploadVC!.getCoachesWiseRecipeList()
            }

        } else if previousUploadVC != nil && !isFromRecipe {
            for temp in arrClassDifficultyList {
                if temp.isSelected {
                    if class_difficulty_name.isEmpty {
                        class_difficulty_name =  temp.class_difficulty_name
                    } else {
                        class_difficulty_name += "," + temp.class_difficulty_name
                    }
                }
            }
            
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
            
            if previousUploadVC != nil {
                previousUploadVC!.resetVariable()
                previousUploadVC!.isFromBookMarkPage = btnBookMark.isSelected ? true : false
                previousUploadVC!.bookmark_only = isFromBookMarkPage ? "yes" : (btnBookMark.isSelected ? "yes" : "no")
                
                if self.btnMinClassDuration.isSelected {
                    previousUploadVC!.min_duration = self.lblMinClassDuration.text! == "5 mins" ? "5 mins" : self.lblMinClassDuration.text!
                } else {
                    previousUploadVC!.min_duration.removeAll()
                }
                if self.btnMinClassDuration.isSelected && !self.btnMaxClassDuration.isSelected {
                    previousUploadVC!.max_duration = self.lblMaxClassDuration.text! == "150 mins" ? "150 mins" : self.lblMaxClassDuration.text!
                } else if self.btnMaxClassDuration.isSelected {
                    previousUploadVC!.max_duration = self.lblMaxClassDuration.text! == "150 mins" ? "150 mins" : self.lblMaxClassDuration.text!
                } else {
                    previousUploadVC!.max_duration.removeAll()
                }
                
                previousUploadVC!.class_difficulty_name = class_difficulty_name
                
                let arrfilterClassTypeNameModel = arrClassTypeList.filter({$0.isSelected})
                let arrfilterClassTypeName = arrfilterClassTypeNameModel.map({$0.class_type_name})
                
                previousUploadVC.class_type_name = arrfilterClassTypeName.joined(separator: ",")
                
                if Reachability.isConnectedToNetwork(){
                    previousUploadVC!.getCoachesWiseClassList()
                }
            }
        } else {
            for temp in arrClassDifficultyList {
                if temp.isSelected {
                    if class_difficulty_name.isEmpty {
                        class_difficulty_name =  temp.class_difficulty_name
                    } else {
                        class_difficulty_name += "," + temp.class_difficulty_name
                    }
                }
            }
            
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
                
                if self.btnMinClassDuration.isSelected {
                    searchResultVC!.min_duration = self.lblMinClassDuration.text! == "5 mins" ? "5 mins" : self.lblMinClassDuration.text!
                } else {
                    searchResultVC!.min_duration.removeAll()
                }
                if self.btnMinClassDuration.isSelected && !self.btnMaxClassDuration.isSelected {
                    searchResultVC!.max_duration = self.lblMaxClassDuration.text! == "150 mins" ? "150 mins" : self.lblMaxClassDuration.text!
                } else if self.btnMaxClassDuration.isSelected {
                    searchResultVC!.max_duration = self.lblMaxClassDuration.text! == "150 mins" ? "150 mins" : self.lblMaxClassDuration.text!
                } else {
                    searchResultVC!.max_duration.removeAll()
                }
                
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
                
                if self.btnMinClassDuration.isSelected {
                    previousClassVC!.min_duration = self.lblMinClassDuration.text! == "5 mins" ? "5 mins" : self.lblMinClassDuration.text!
                } else {
                    previousClassVC!.min_duration.removeAll()
                }
                if self.btnMaxClassDuration.isSelected {
                    previousClassVC!.max_duration = self.lblMaxClassDuration.text! == "150 mins" ? "150 mins" : self.lblMaxClassDuration.text!
                } else {
                    previousClassVC!.max_duration.removeAll()
                }
                
                previousClassVC!.class_difficulty_name = class_difficulty_name
                //previousClassVC!.class_type = btnLive.isSelected ? "live" : "on_demand"
                
                let arrfilterClassTypeNameModel = arrClassTypeList.filter({$0.isSelected})
                let arrfilterClassTypeName = arrfilterClassTypeNameModel.map({$0.class_type_name})
                
                previousClassVC.class_type_name = arrfilterClassTypeName.joined(separator: ",")
                previousClassVC!.getPrevoisCoachClassList()
            }
        }
        navigationController?.popViewController(animated: true)
        
    }
    
}


// MARK: - API CALL
extension ClassFilterViewController {
    
    func callMealTypeAndDietaryRestrictionList() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.MEAL_TYPE_AND_DIETARY_RESTRICTION_LIST, parameters: nil, headers: nil) { responseObj in
            self.hideLoader()
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                if let dataObj = responseObj["data"] as? [String:Any] {
                    if let arrDietaryRestriction = dataObj["dietary_restriction"] as? [[String:Any]] {
                        self.arrDietaryRestrictionListData = DietaryRestrictionListData.getData(data: arrDietaryRestriction)
                    }
                    if let arrMealType = dataObj["meal_type"] as? [[String:Any]] {
                        self.arrMealType = MealTypeListData.getData(data: arrMealType)
                    }
                }
                self.clvDifficultyLevel.reloadData()
                self.clvClassType.reloadData()
                self.lctClassTypeHeight.constant = self.clvClassType.collectionViewLayout.collectionViewContentSize.height
                self.setData()
            }
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
            
            if Reachability.isConnectedToNetwork(){
                self.getClassDifficultyList()
            }
            
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
                self.arrClassDifficultyList.reverse()
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
        if (previousClassVC != nil && isFromRecipe) || (previousUploadVC != nil && isFromRecipe) {
            if collectionView == clvDifficultyLevel {
                return arrMealType.count
            }
            return arrDietaryRestrictionListData.count
        } else {
            if collectionView == clvDifficultyLevel {
                return arrClassDifficultyList.count
            }
            return arrClassTypeList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if (previousClassVC != nil && isFromRecipe) || (previousUploadVC != nil && isFromRecipe) {
            if collectionView == clvDifficultyLevel {
                let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MuscleItemCollectionViewCell", for: indexPath) as!  MuscleItemCollectionViewCell
                let obj  = arrMealType[indexPath.row]
                cell.lblTitle.text = obj.meal_type_name
                cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
                
                if obj.isSelected {
                    cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
                }
                return cell
            } else {
                let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MuscleItemCollectionViewCell", for: indexPath) as!  MuscleItemCollectionViewCell
                let obj  = arrDietaryRestrictionListData[indexPath.row]
                cell.lblTitle.text = obj.dietary_restriction_name
                cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
                
                if obj.isSelected {
                    cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
                }
                return cell
            }
        } else {
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
                cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
                
                if obj.isSelected {
                    cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
                }
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width =  (clvClassType.frame.width - 30 ) / 3
        return CGSize(width: width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if (previousClassVC != nil && isFromRecipe) || (previousUploadVC != nil && isFromRecipe) {
            if collectionView == clvDifficultyLevel {
                arrMealType[indexPath.row].isSelected = !arrMealType[indexPath.row].isSelected
                clvDifficultyLevel.reloadData()
            } else {
                arrDietaryRestrictionListData[indexPath.row].isSelected = !arrDietaryRestrictionListData[indexPath.row].isSelected
                clvClassType.reloadData()
            }
        } else {
            if collectionView == clvDifficultyLevel {
                arrClassDifficultyList[indexPath.row].isSelected = !arrClassDifficultyList[indexPath.row].isSelected
                clvDifficultyLevel.reloadData()

            } else {
                arrClassTypeList[indexPath.row].isSelected = !arrClassTypeList[indexPath.row].isSelected
                clvClassType.reloadData()
            }
        }
    }
    
    
}
