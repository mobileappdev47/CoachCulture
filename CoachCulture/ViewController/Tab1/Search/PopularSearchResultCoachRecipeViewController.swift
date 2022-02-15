//
//  PopularSearchResultCoachRecipeViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit

class PopularSearchResultCoachRecipeViewController: BaseViewController {
    
    static func viewcontroller() -> PopularSearchResultCoachRecipeViewController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "PopularSearchResultCoachRecipeViewController") as! PopularSearchResultCoachRecipeViewController
        return vc
    }
    
    @IBOutlet weak var tblCoachRecipe : UITableView!
    
    @IBOutlet weak var txtSearch : UITextField!
    
    var arrCoachRecipeData = [CoachRecipeData]()
    var selectedParam = [String : Any]()
    var isDataLoading = false
    var continueLoadingData = true
    var pageNo = 1
    var perPageCount = 10
    var searchString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    
    // MARK: - METHODS
    func setUpUI() {
        
        
        tblCoachRecipe.register(UINib(nibName: "YourCoachRecipeItemTableViewCell", bundle: nil), forCellReuseIdentifier: "YourCoachRecipeItemTableViewCell")
        tblCoachRecipe.delegate = self
        tblCoachRecipe.dataSource = self
        
        txtSearch.delegate = self
        hideTabBar()
        self.getAllCoachRecipeList(duration: "", meal_type_name: "", dietary_restriction_name: "", coach_only: "no")
    }
    
    func resetAll() {
        isDataLoading = false
        continueLoadingData = true
        pageNo = 1
        perPageCount = 10
        arrCoachRecipeData.removeAll()
    }
    
    // MARK: - CLICK EVENTS
    @IBAction func clicToBtnFilter(_ sender : UIButton) {
        let vc = RecipeFilterViewController.viewcontroller()
        vc.popularSearchResultCoachRecipeViewController = self
        vc.selectedParam = self.selectedParam
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



// MARK: - UITableViewDelegate, UITableViewDataSource
extension PopularSearchResultCoachRecipeViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrCoachRecipeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "YourCoachRecipeItemTableViewCell", for: indexPath) as! YourCoachRecipeItemTableViewCell
        let obj = arrCoachRecipeData[indexPath.row]
        cell.lblDuration.text = obj.duration
        cell.lblUserName.text = obj.username
        cell.lblTitle.text = obj.title
        cell.lblRecipeType.text = obj.meal_type_name
        cell.lblDuration.text = obj.duration
        cell.imgRecipe.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
        cell.imgUser.setImageFromURL(imgUrl: obj.coach_image, placeholderImage: nil)
        cell.imgThumbnail.setImageFromURL(imgUrl: obj.coach_image, placeholderImage: nil)
        cell.imgThumbnail.blurImage()
        cell.arrDietaryRestriction = obj.arrDietaryRestrictionName
        cell.clvDietaryRestriction.reloadData()
        
        if arrCoachRecipeData.count - 1 == indexPath.row
        {
            let coach_only = selectedParam["coach_only"] as? String ?? ""
            self.getAllCoachRecipeList(duration: selectedParam["duration"] as? String ?? "", meal_type_name: selectedParam["meal_type_name"] as? String ?? "", dietary_restriction_name: selectedParam["dietary_restriction_name"] as? String ?? "", coach_only: coach_only)
        }
        
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

//MARK: - UITextFieldDelegate
extension PopularSearchResultCoachRecipeViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let finalString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        searchString = finalString
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.resetAll()
        let coach_only = selectedParam["coach_only"] as? String ?? ""
        self.getAllCoachRecipeList(duration: selectedParam["duration"] as? String ?? "", meal_type_name: selectedParam["meal_type_name"] as? String ?? "", dietary_restriction_name: selectedParam["dietary_restriction_name"] as? String ?? "", coach_only: coach_only)
    }
    
}

// MARK: - API Call
extension PopularSearchResultCoachRecipeViewController {
    
    func getAllCoachRecipeList(duration : String,meal_type_name: String,dietary_restriction_name : String,coach_only : String) {
        if(isDataLoading || !continueLoadingData){
            return
        }
        
        isDataLoading = true
        
        showLoader()
        let param = [ "page_no" : "\(pageNo)",
                      "per_page" : "\(perPageCount)",
                      "duration" : duration,
                      "meal_type_name" : meal_type_name,
                      "dietary_restriction_name" : dietary_restriction_name,
                      "coach_only" : coach_only,
                      "search" : searchString
        ]
        
        self.selectedParam = param
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_ALL_COACH_RECIPE_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_recipe_list"] as? [Any] ?? [Any]()
           let arr = CoachRecipeData.getData(data: dataObj)
            self.arrCoachRecipeData.append(contentsOf: arr)
            self.tblCoachRecipe.reloadData()
            
            if arr.count < self.perPageCount
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
}
