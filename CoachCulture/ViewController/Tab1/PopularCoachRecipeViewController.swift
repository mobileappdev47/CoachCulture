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
    
    @IBOutlet weak var tblCoachRecipe : UITableView!
    @IBOutlet weak var lctCoachRecipeTableHeight : NSLayoutConstraint!
    
   private var isDataLoading = false
    private var continueLoadingData = true
    private var pageNo = 1
    private var perPageCount = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showTabBar()
    }
    
    
    // MARK: - METHODS
    func setUpUI() {
        
        clvPopularRecipeItem.register(UINib(nibName: "PopularRecipeItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PopularRecipeItemCollectionViewCell")
        clvPopularRecipeItem.delegate = self
        clvPopularRecipeItem.dataSource = self
        
        tblCoachRecipe.register(UINib(nibName: "YourCoachRecipeItemTableViewCell", bundle: nil), forCellReuseIdentifier: "YourCoachRecipeItemTableViewCell")
        tblCoachRecipe.delegate = self
        tblCoachRecipe.dataSource = self
        tblCoachRecipe.layoutIfNeeded()
       
        if Reachability.isConnectedToNetwork(){
        getPopularRecipeList(str: "")
        }
        
    }
    
    // MARK: - CLICK EVENTS
    @IBAction func clickToBtnSearch( _ sender : UIButton) {
        let vc = PopularSearchResultCoachRecipeViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToBtnBookMark( _ sender : UIButton) {
        
        let obj = arrCoachRecipeData[sender.tag]
        
        if obj.bookmark.lowercased() == "no".lowercased() {
            addOrRemoveFromBookMark(bookmark: "yes", coach_recipe_id: obj.id, selectedIndex: sender.tag)
        } else {
            addOrRemoveFromBookMark(bookmark: "no", coach_recipe_id: obj.id, selectedIndex: sender.tag)
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
        
        let obj = arrPopularRecipeData[indexPath.row]
        
        cell.lblTitle.text = obj.title
        cell.lblSubtitle.text = obj.sub_title
        cell.lblUserName.text = "@" + obj.coachDetailsObj.username
        cell.lblViews.text =  obj.viewers + "K Views"
        cell.imgRecipe.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
        cell.imgThumbnail.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
        cell.imgThumbnail.blurImage()
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: 155, height: 190)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
    }
    
    
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension PopularCoachRecipeViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrCoachRecipeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "YourCoachRecipeItemTableViewCell", for: indexPath) as! YourCoachRecipeItemTableViewCell
        let obj = arrCoachRecipeData[indexPath.row]
        cell.lblTitle.text = obj.title
        cell.lblDuration.text = obj.duration
        cell.lblRecipeType.text = obj.arrMealTypeString
        cell.lblUserName.text = obj.coachDetailsObj.username
        cell.imgUser.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: nil)
        cell.imgThumbnail.setImageFromURL(imgUrl: obj.coachDetailsObj.user_image, placeholderImage: nil)
        cell.imgThumbnail.blurImage()
        cell.imgRecipe.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: nil)
        if obj.bookmark.lowercased() == "no".lowercased() {
            cell.imgBookmark.image = UIImage(named: "BookmarkLight")
        } else {
            cell.imgBookmark.image = UIImage(named: "Bookmark")
        }
        
        cell.btnBookmark.tag = indexPath.row
        cell.btnBookmark.addTarget(self, action: #selector(self.clickToBtnBookMark(_:)), for: .touchUpInside)
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



//MARK: - API call

extension PopularCoachRecipeViewController {
    func getPopularRecipeList(str : String) {
        
        showLoader()
        let param = [ "search" : str]
        
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_POPULAR_RECIPE_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["popular_recipe_list"] as? [Any] ?? [Any]()
            self.arrPopularRecipeData = PopularRecipeData.getData(data: dataObj)
            self.clvPopularRecipeItem.reloadData()
            
            self.hideLoader()
            self.getYourCoachRecipeList()
            
        } failure: { (error) in
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
            self.arrCoachRecipeData.append(contentsOf: arr)
            self.tblCoachRecipe.reloadData()
            self.lctCoachRecipeTableHeight.constant = self.tblCoachRecipe.contentSize.height
            
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
