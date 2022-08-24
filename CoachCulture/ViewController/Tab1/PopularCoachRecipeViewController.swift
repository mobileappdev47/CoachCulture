//
//  PopularCoachRecipeViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit

class PopularCoachRecipeViewController: BaseViewController {
    
    static func viewcontroller() -> PopularCoachRecipeViewController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "PopularCoachRecipeViewController") as! PopularCoachRecipeViewController
        return vc
    }
    
    static func viewcontrollerNav() -> UINavigationController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "PopularCoachRecipeNavView") as! UINavigationController
        return vc
    }
    
    
    @IBOutlet weak var clvPopularRecipeItem : UICollectionView!
    var arrPopularRecipeData = [PopularRecipeData]()
    var arrCoachRecipeData = [PopularRecipeData]()
    let safeAreaTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0.0
    var kHomeNewClassHeaderViewID = "HomeNewClassHeaderView"
    @IBOutlet weak var tblCoachRecipe : UITableView!
    @IBOutlet weak var lctCoachRecipeTableHeight : NSLayoutConstraint!
    @IBOutlet weak var lblPopularRecipeCenter: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lblNoDataFoundNewRecipies: UILabel!

    private var isDataLoading = false
    private var continueLoadingData = true
    private var pageNo = 1
    private var perPageCount = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpUI()
        if Reachability.isConnectedToNetwork(){
            self.getPopularRecipeList(str: "")
            self.getYourCoachRecipeList()
            self.isDataLoading = false
            self.continueLoadingData = true
            self.pageNo = 1
        }
        showTabBar()
    }
    
    
    // MARK: - METHODS
    func setUpUI() {
        self.tblCoachRecipe.register(UINib(nibName: kHomeNewClassHeaderViewID, bundle: nil), forHeaderFooterViewReuseIdentifier: kHomeNewClassHeaderViewID)
        self.tblCoachRecipe.register(UINib(nibName: "NewClassesTBLViewCell", bundle: nil), forCellReuseIdentifier: "NewClassesTBLViewCell")
        self.tblCoachRecipe.delegate = self
        self.tblCoachRecipe.dataSource = self
        self.tblCoachRecipe.layoutIfNeeded()
        
        self.clvPopularRecipeItem.register(UINib(nibName: "PopularRecipeItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PopularRecipeItemCollectionViewCell")
        self.clvPopularRecipeItem.delegate = self
        self.clvPopularRecipeItem.dataSource = self
        
        self.tblCoachRecipe.isScrollEnabled = false
        self.scrollView.delegate = self
    }
    
    // MARK: - CLICK EVENTS
    @IBAction func clickToBtnSearch( _ sender : UIButton) {
        let vc = PopularSearchResultCoachRecipeViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToBtnBookMark( _ sender : UIButton) {
        
        let obj = arrCoachRecipeData[sender.tag]
        
        if obj.bookmark.lowercased() == "no".lowercased() {
            if Reachability.isConnectedToNetwork(){
                addOrRemoveFromBookMark(bookmark: "yes", coach_recipe_id: obj.id, selectedIndex: sender.tag)
            }
        } else {
            if Reachability.isConnectedToNetwork(){
                addOrRemoveFromBookMark(bookmark: "no", coach_recipe_id: obj.id, selectedIndex: sender.tag)
            }
        }
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension PopularCoachRecipeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return arrPopularRecipeData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularRecipeItemCollectionViewCell", for: indexPath) as!  PopularRecipeItemCollectionViewCell
        
        lblPopularRecipeCenter.isHidden = true
        let obj = arrPopularRecipeData[indexPath.row]
        
        var arrFilteredDietaryRestriction = [String]()
        
        if obj.arrdietary_restriction.count > 2 {
            cell.viewSecondDietry.isHidden = false
            arrFilteredDietaryRestriction.append(obj.arrdietary_restriction[0])
            arrFilteredDietaryRestriction.append(obj.arrdietary_restriction[1])
            cell.lblDietaryRestrictionFirst.text = arrFilteredDietaryRestriction.first
            cell.lblDietaryRestrictionSecond.text = arrFilteredDietaryRestriction.last
        } else {
            if obj.arrdietary_restriction.count == 2 {
                cell.viewSecondDietry.isHidden = false
                arrFilteredDietaryRestriction.append(obj.arrdietary_restriction[0])
                arrFilteredDietaryRestriction.append(obj.arrdietary_restriction[1])
                cell.lblDietaryRestrictionFirst.text = arrFilteredDietaryRestriction.first
                cell.lblDietaryRestrictionSecond.text = arrFilteredDietaryRestriction.last
            } else {
                cell.viewSecondDietry.isHidden = true
                arrFilteredDietaryRestriction.append(obj.arrdietary_restriction[0])
                cell.lblDietaryRestrictionFirst.text = arrFilteredDietaryRestriction.first
            }
        }
        
        cell.lblDuration.text = obj.duration
        cell.lblTitle.text = obj.title
        cell.lblSubtitle.text = obj.sub_title
        cell.lblUserName.text = "@" + obj.coachDetailsObj.username
//        cell.lblViews.text =  obj.viewers + "K Views"
        cell.imgRecipe.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
        if cell.imgThumbnail.image == nil {
            cell.imgThumbnail.blurImage()
        }
        cell.imgThumbnail.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: 145, height: 190)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = RecipeDetailsViewController.viewcontroller()
        vc.recipeID = arrPopularRecipeData[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func clickToBtnUser( _ sender : UIButton) {
        let vc = CoachViseOnDemandClassViewController.viewcontroller()
        vc.selectedCoachId = self.arrCoachRecipeData[sender.tag].coachDetailsObj.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension PopularCoachRecipeViewController : UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate  {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            print(self.scrollView.contentOffset.y)
            tblCoachRecipe.isScrollEnabled = (self.scrollView.contentOffset.y >= 260)
        }
        if scrollView == self.tblCoachRecipe {
            self.tblCoachRecipe.isScrollEnabled = (tblCoachRecipe.contentOffset.y > 0)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: kHomeNewClassHeaderViewID) as? HomeNewClassHeaderView {
            headerView.lblTitle.text = "    New Recipes"
            return headerView
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrCoachRecipeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewClassesTBLViewCell", for: indexPath) as? NewClassesTBLViewCell else { return UITableViewCell() }
        
        let model = arrCoachRecipeData[indexPath.row]
        cell.selectedIndex = indexPath.row
        if cell.imgBlurThumbnail.image == nil {
            cell.imgBlurThumbnail.blurImage()
        }
        
        var arrFilteredDietaryRestriction = [String]()
        
        if model.arrdietary_restriction.count > 2 {
            arrFilteredDietaryRestriction.append(model.arrdietary_restriction[0])
            arrFilteredDietaryRestriction.append(model.arrdietary_restriction[1])
            cell.arrDietaryRestriction = arrFilteredDietaryRestriction
        } else {
            cell.arrDietaryRestriction = model.arrdietary_restriction
        }
        
        cell.clvDietaryRestriction.reloadData()
        
        cell.viewTime.addCornerRadius(5)
        cell.viewUsername.addCornerRadius(5)
        cell.viewClassType.addCornerRadius(5)
        cell.viewUserImage.addCornerRadius(cell.viewUserImage.bounds.height / 2)
        cell.btnUser.tag = indexPath.row
        cell.btnUser.addTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)
        cell.viewBG.addCornerRadius(10)
        cell.viewBG.backgroundColor = COLORS.APP_THEME_COLOR
        
        cell.imgUser.setImageFromURL(imgUrl: model.coachDetailsObj.user_image, placeholderImage: "")
        cell.imgBanner.setImageFromURL(imgUrl: model.thumbnail_image, placeholderImage: "")
        cell.imgBlurThumbnail.setImageFromURL(imgUrl: model.thumbnail_image, placeholderImage: "")
        
        cell.imgBookmark.image = model.bookmark == BookmarkType.No ? UIImage(named: "BookmarkLight") : UIImage(named: "Bookmark")
        
        cell.didTapBookmarkButton = {
            var param = [String:Any]()
            param[Params.AddRemoveBookmark.coach_class_id] = model.id
            param[Params.AddRemoveBookmark.bookmark] = model.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
            if Reachability.isConnectedToNetwork(){
                self.addOrRemoveFromBookMark(bookmark: model.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No, coach_recipe_id: model.id,  selectedIndex: cell.selectedIndex)
            }
        }
        if model.bookmark.lowercased() == "no".lowercased() {
            cell.imgBookmark.image = UIImage(named: "BookmarkLight")
        } else {
            cell.imgBookmark.image = UIImage(named: "Bookmark")
        }
        cell.lblTitle.text = model.title
        cell.lblSubTitle.text = model.sub_title
        cell.lblTime.text = model.duration
        cell.lblUsername.text = "@\(model.coachDetailsObj.username)"
        cell.viewClassType.backgroundColor = hexStringToUIColor(hex: "#4DB748")
        cell.lblClassType.text = "RECIPE"
        cell.lblDateTime.text = convertUTCToLocal(dateStr: model.created_at, sourceFormate: "yyyy-MM-dd HH:mm:ss", destinationFormate: "dd MMM yyyy")
        cell.lblDate.text = "\(model.viewers) views"
      
        if arrCoachRecipeData.count - 1 == indexPath.row {
            if Reachability.isConnectedToNetwork(){
                getPopularRecipeList(str: "")
            }
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = RecipeDetailsViewController.viewcontroller()
        vc.recipeID = arrCoachRecipeData[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



//MARK: - API call

extension PopularCoachRecipeViewController {
    func getPopularRecipeList(str : String) {
        
        showLoader()
        let param = [ "search" : str]
        
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_POPULAR_RECIPE_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["popular_recipe_list"] as? [Any] ?? [Any]()
            self.arrPopularRecipeData = PopularRecipeData.getData(data: dataObj)
            
            if self.arrPopularRecipeData.count > 0 {
                self.lblPopularRecipeCenter.isHidden = true
                self.arrPopularRecipeData.forEach { (model) in
                    model.arrdietary_restriction.sort()
                }
                self.clvPopularRecipeItem.reloadData()
            } else {
                self.lblPopularRecipeCenter.isHidden = false
            }
            self.hideLoader()
            self.getYourCoachRecipeList()
            
        } failure: { (error) in
            self.lblPopularRecipeCenter.isHidden = false
            return true
        }
    }
    
    func getYourCoachRecipeList() {
        if(isDataLoading || !continueLoadingData){
            return
        }
        
        isDataLoading = true
        
        showLoader()
        let param = [ "page_no" : "\(pageNo)",
                      "per_page" : "\(perPageCount)",
                      
        ]
        
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_YOUR_COACH_RECIPE_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_recipe_list"] as? [Any] ?? [Any]()
            let arr = PopularRecipeData.getData(data: dataObj)
            
            self.arrCoachRecipeData = []
            if arr.count > 0 {
                self.arrCoachRecipeData.append(contentsOf: arr)
                
                self.arrCoachRecipeData.forEach { (model) in
                    model.arrdietary_restriction.sort()
                }
                
                DispatchQueue.main.async {
                    self.tblCoachRecipe.reloadData()
                }
            }
            
            if self.arrCoachRecipeData.count > 0 {
                if self.safeAreaTop > 20 {
                    self.lctCoachRecipeTableHeight.constant = (self.view.frame.height - (30) - (35.0 + self.safeAreaTop + 14))
                } else {
                    self.lctCoachRecipeTableHeight.constant = (self.view.frame.height - (self.safeAreaTop + 30 + 40))
                }
            } else {
                self.lctCoachRecipeTableHeight.constant = 150.0
            }
            
            self.lblNoDataFoundNewRecipies.isHidden = self.arrCoachRecipeData.count > 0 ? true : false
            
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
    
    func addOrRemoveFromBookMark(bookmark : String, coach_recipe_id: String, selectedIndex: Int) {
        showLoader()
        let param = ["coach_recipe_id" : coach_recipe_id,"bookmark" : bookmark]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.ADD_REMOVE_BOOKMARK, parameters: param, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            self.arrCoachRecipeData[selectedIndex].bookmark = bookmark
            self.tblCoachRecipe.reloadData()
            Utility.shared.showToast(responseModel.message)
           
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
}


public extension UIImageView {


    func blurImage() {
        let darkBlur = UIBlurEffect(style: .light)

        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = self.bounds
        self.addSubview(blurView)
    }
}
