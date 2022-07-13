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
    
    @IBOutlet weak var viewNoRecipeFound: UIView!
    @IBOutlet weak var lblRecipeCenter: UILabel!
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
        if Reachability.isConnectedToNetwork(){
            self.getAllCoachRecipeList(duration: "", meal_type_name: "", dietary_restriction_name: "", coach_only: "no")
        }
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
        if arrCoachRecipeData.count > 0 {
            let obj = arrCoachRecipeData[indexPath.row]
            cell.setUpUI()
            cell.viewProfile.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            cell.viewDuration.layer.maskedCorners = [.layerMinXMinYCorner]
            cell.lblUserName.text = obj.username
            cell.lblTitle.text = obj.title
            cell.lblRecipeType.text = obj.meal_type_name
            cell.lblDuration.text = obj.duration
            cell.lblDuration.addCornerRadius(5)
            cell.imgRecipe.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
            cell.imgUser.setImageFromURL(imgUrl: obj.coach_image, placeholderImage: nil)
            if cell.imgThumbnail.image == nil {
                cell.imgThumbnail.blurImage()
            }
            cell.imgThumbnail.setImageFromURL(imgUrl: obj.coach_image, placeholderImage: nil)
            
            var arrFilteredDietaryRestriction = [String]()
            
            if obj.arrDietaryRestrictionName.count > 2 {
                arrFilteredDietaryRestriction.append(obj.arrDietaryRestrictionName[0])
                arrFilteredDietaryRestriction.append(obj.arrDietaryRestrictionName[1])
                cell.arrDietaryRestriction = arrFilteredDietaryRestriction
            } else {
                cell.arrDietaryRestriction = obj.arrDietaryRestrictionName
            }
            
            DispatchQueue.main.async {
                cell.clvDietaryRestriction.reloadData()
            }

            if obj.bookmark == "no" {
                cell.imgBookmark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookmark.image = UIImage(named: "Bookmark")
            }
            if arrCoachRecipeData.count - 1 == indexPath.row
            {
                let coach_only = selectedParam["coach_only"] as? String ?? ""
                if Reachability.isConnectedToNetwork(){
                    self.getAllCoachRecipeList(duration: selectedParam["duration"] as? String ?? "", meal_type_name: selectedParam["meal_type_name"] as? String ?? "", dietary_restriction_name: selectedParam["dietary_restriction_name"] as? String ?? "", coach_only: coach_only)
                }
            }
            cell.selectedIndex = indexPath.row
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_recipe_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                if Reachability.isConnectedToNetwork(){
                    self.callToAddRemoveBookmarkAPI(urlStr: API.ADD_REMOVE_BOOKMARK, params: param, recdType: SelectedDemandClass.recipe, selectedIndex: cell.selectedIndex)
                }
            }
        }
        return cell
    }
    
    func callToAddRemoveBookmarkAPI(urlStr: String, params: [String:Any], recdType : String, selectedIndex: Int) {
        showLoader()
        _ =  ApiCallManager.requestApi(method: .post, urlString: urlStr, parameters: params, headers: nil) { responseObj in
            
            if let message = responseObj["message"] as? String, !message.isEmpty {
                Utility.shared.showToast(message)
            }
            switch recdType {
            case SelectedDemandClass.recipe:
                for (index, model) in self.arrCoachRecipeData.enumerated() {
                    if selectedIndex == index {
                        model.bookmark = model.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                        self.arrCoachRecipeData[index] = model
                        DispatchQueue.main.async {
                            self.tblCoachRecipe.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                        break
                    }
                }
            default:
                self.resetAll()
                if Reachability.isConnectedToNetwork(){
                    self.getAllCoachRecipeList(duration: "", meal_type_name: "", dietary_restriction_name: "", coach_only: "no")
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
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = RecipeDetailsViewController.viewcontroller()
        vc.recipeID = arrCoachRecipeData[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - UITextFieldDelegate
extension PopularSearchResultCoachRecipeViewController : UITextFieldDelegate {

    @objc func getHintsFromTextField(textField: UITextField) {
        self.resetAll()
        let coach_only = selectedParam["coach_only"] as? String ?? ""
        if Reachability.isConnectedToNetwork(){
            self.getAllCoachRecipeList(duration: selectedParam["duration"] as? String ?? "", meal_type_name: selectedParam["meal_type_name"] as? String ?? "", dietary_restriction_name: selectedParam["dietary_restriction_name"] as? String ?? "", coach_only: coach_only)
        }
        print("Hints for textField: \(textField)")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let finalString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        searchString = finalString
        NSObject.cancelPreviousPerformRequests(
                withTarget: self,
                selector: #selector(self.getHintsFromTextField),
                object: textField)
            self.perform(
                #selector(self.getHintsFromTextField),
                with: textField,
                afterDelay: 1)
            return true
        //textFieldDidEndEditing(textField)
        return true
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        self.resetAll()
//        let coach_only = selectedParam["coach_only"] as? String ?? ""
//        if Reachability.isConnectedToNetwork(){
//            self.getAllCoachRecipeList(duration: selectedParam["duration"] as? String ?? "", meal_type_name: selectedParam["meal_type_name"] as? String ?? "", dietary_restriction_name: selectedParam["dietary_restriction_name"] as? String ?? "", coach_only: coach_only)
//        }
//    }
    
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
            
            if self.arrCoachRecipeData.count == 0 {
                self.viewNoRecipeFound.isHidden = false
            } else {
                self.viewNoRecipeFound.isHidden = true
            }
            
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
