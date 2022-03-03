//
//  RecipeFilterViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit

class RecipeFilterViewController: BaseViewController {
    
    static func viewcontroller() -> RecipeFilterViewController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "RecipeFilterViewController") as! RecipeFilterViewController
        return vc
    }

    @IBOutlet weak var clvMealType: UICollectionView!
    @IBOutlet weak var clvDietaryRestriction: UICollectionView!
    
    @IBOutlet weak var lctvDietaryRestrictionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viwMyCoachesOnly : UIView!
    
    @IBOutlet weak var btnMyCoachesOnly : UIButton!
    
    @IBOutlet weak var lblMinRecipeDuration : UILabel!

    
    var arrMealTypeListData = [MealTypeListData]()
    var arrDietaryRestrictionListData = [DietaryRestrictionListData]()
    var classDuration : ClassDuration!
    var popularSearchResultCoachRecipeViewController : PopularSearchResultCoachRecipeViewController!
    var selectedParam = [String : Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    // MARK: - Methods
    func setUpUI() {
        
        if Reachability.isConnectedToNetwork(){
            getMealTypeList()
        }
        
        viwMyCoachesOnly.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        clvMealType.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvMealType.delegate = self
        clvMealType.dataSource = self
        
        clvDietaryRestriction.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvDietaryRestriction.delegate = self
        clvDietaryRestriction.dataSource = self
        
        classDuration = Bundle.main.loadNibNamed("ClassDuration", owner: nil, options: nil)?.first as? ClassDuration
        classDuration.tapToBtnSelectItem { obj in
            self.lblMinRecipeDuration.text = obj + " mins"
        }
        
    }
    
    func setData() {
        let coach_only = selectedParam["coach_only"] as? String ?? ""
        if coach_only == "yes" {
            btnMyCoachesOnly.isSelected = true
            viwMyCoachesOnly.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
        } else{
            btnMyCoachesOnly.isSelected = false
            viwMyCoachesOnly.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        }
        
        lblMinRecipeDuration.text = selectedParam["duration"] as? String ?? ""
        
        let strMealType = selectedParam["meal_type_name"] as? String ?? ""
        if !strMealType.isEmpty {
            let arrMealType = strMealType.components(separatedBy: ",")
            for temp in arrMealType {
                let ind = arrMealTypeListData.firstIndex { obj in
                    return obj.meal_type_name.lowercased() == temp.lowercased()
                }
                
                if ind != nil {
                    arrMealTypeListData[ind!].isSelected = true
                }
            }
        }
        
        let strDietaryRes = selectedParam["dietary_restriction_name"] as? String ?? ""
        if !strDietaryRes.isEmpty {
            let arrMealType = strDietaryRes.components(separatedBy: ",")
            for temp in arrMealType {
                let ind = arrDietaryRestrictionListData.firstIndex { obj in
                    return obj.dietary_restriction_name.lowercased() == temp.lowercased()
                }
                
                if ind != nil {
                    arrDietaryRestrictionListData[ind!].isSelected = true
                }
            }
        }
        
        clvDietaryRestriction.reloadData()
        clvMealType.reloadData()
        
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
    
    @IBAction func clickToBtnMyCoachOnly ( _ sender : UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            viwMyCoachesOnly.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
        } else {
            viwMyCoachesOnly.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        }
    }
    
    @IBAction func clickToBtnRecipeDuration(_ sender : UIButton) {
        setClassDurationView()
    }
    
    @IBAction func clickToBtnApplyFilter(_ sender : UIButton) {
        
        var meal_type = ""
        for temp in arrMealTypeListData {
            if temp.isSelected {
                if meal_type.isEmpty {
                    meal_type = temp.meal_type_name
                } else {
                    meal_type += "," + temp.meal_type_name
                }
            }
        }
        
        var dietary_restriction = ""
        for temp in arrDietaryRestrictionListData {
            if temp.isSelected {
                if dietary_restriction.isEmpty {
                    dietary_restriction = temp.dietary_restriction_name
                } else {
                    dietary_restriction += "," + temp.dietary_restriction_name
                }
            }
        }
        var duration = ""
        if lblMinRecipeDuration.text!.lowercased() != "0 mins".lowercased() {
            duration = lblMinRecipeDuration.text!
        }
        popularSearchResultCoachRecipeViewController!.resetAll()
        popularSearchResultCoachRecipeViewController!.getAllCoachRecipeList(duration: duration, meal_type_name: meal_type, dietary_restriction_name: dietary_restriction, coach_only: btnMyCoachesOnly.isSelected ? "yes" : "no")
        self.navigationController?.popViewController(animated: true)
    }

}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension RecipeFilterViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == clvDietaryRestriction {
            return arrDietaryRestrictionListData.count
        }
        
        return arrMealTypeListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        if collectionView == clvDietaryRestriction {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MuscleItemCollectionViewCell", for: indexPath) as!  MuscleItemCollectionViewCell
            let obj  = arrDietaryRestrictionListData[indexPath.row]
            cell.lblTitle.text = obj.dietary_restriction_name
            
            if obj.isSelected {
                cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
            } else {
                cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
            }
            
            return cell
        } else {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MuscleItemCollectionViewCell", for: indexPath) as!  MuscleItemCollectionViewCell
            let obj  = arrMealTypeListData[indexPath.row]
            cell.lblTitle.text = obj.meal_type_name
            
            if obj.isSelected {
                cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
            } else {
                cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
            }
            
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == clvDietaryRestriction {
            let width =  (clvDietaryRestriction.frame.width - 40 ) / 3
            return CGSize(width: width, height: 40)
        } else {
            let width =  (clvMealType.frame.width - 40 ) / 3
            return CGSize(width: width, height: 40)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        if collectionView == clvDietaryRestriction {
            arrDietaryRestrictionListData[indexPath.row].isSelected = !arrDietaryRestrictionListData[indexPath.row].isSelected
        } else {
            arrMealTypeListData[indexPath.row].isSelected = !arrMealTypeListData[indexPath.row].isSelected
        }
        
        collectionView.reloadData()
    }
    
    
}


// MARK: - API CALL
extension RecipeFilterViewController {
    func getMealTypeList() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.MEAL_TYPE_LIST, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()
                self.arrMealTypeListData = MealTypeListData.getData(data: dataObj)
                self.clvMealType.reloadData()
            }
         
            //self.hideLoader()
            self.getDietaryList()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func getDietaryList() {
        
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.DIETARY_RES_LIST, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()
                self.arrDietaryRestrictionListData = DietaryRestrictionListData.getData(data: dataObj)
                self.clvDietaryRestriction.reloadData()
                self.lctvDietaryRestrictionHeight.constant = self.clvDietaryRestriction.collectionViewLayout.collectionViewContentSize.height
            }
            
            self.setData()
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
}
