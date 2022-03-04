//
//  YourCoachesViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit

class YourCoachesViewController: BaseViewController {
    
    static func viewcontroller() -> YourCoachesViewController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "YourCoachesViewController") as! YourCoachesViewController
        return vc
    }
    
    static func viewcontrollerNav() -> UINavigationController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "YourCoachesNavVc") as! UINavigationController
        return vc
    }
    
    //MARK: - OUTLET
    
    @IBOutlet weak var viewNoDataFoundNewClass: UIView!
    @IBOutlet weak var tblNewClass: UITableView!
    @IBOutlet weak var clvPopularTrainer : UICollectionView!
    @IBOutlet weak var lctOndemandTableHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - VARIABLE AND OBJECT
    
    var arrPopularTrainerList = [PopularTrainerList]()
    var kNewClassesTBLViewCellID = "NewClassesTBLViewCell"
    var kHomeNewClassHeaderViewID = "HomeNewClassHeaderView"
    var isDataLoading = false
    var continueLoadingData = true
    var pageNo = 1
    var perPageCount = 10
    var arrNewClass = [NewUploadList]()
    let safeAreaTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0.0
    
    //MARK: - VIEW CONTROLLER LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpUI()
        showTabBar()
    }
    
    //MARK: - FUNCTION
    
    func setUpUI() {
        tblNewClass.register(UINib(nibName: kHomeNewClassHeaderViewID, bundle: nil), forHeaderFooterViewReuseIdentifier: kHomeNewClassHeaderViewID)
        tblNewClass.register(UINib(nibName: kNewClassesTBLViewCellID, bundle: nil), forCellReuseIdentifier: kNewClassesTBLViewCellID)
        tblNewClass.delegate = self
        tblNewClass.dataSource = self
        
        clvPopularTrainer.register(UINib(nibName: "PopularTrainerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PopularTrainerCollectionViewCell")
        clvPopularTrainer.delegate = self
        clvPopularTrainer.dataSource = self
        
        if Reachability.isConnectedToNetwork(){
            callNewUploadAPI()
            callGetListOfClassDoneAPI()
        }
        
        self.tblNewClass.isScrollEnabled = false
        self.scrollView.delegate = self
    }
    
    @objc func clickToBtnUser( _ sender : UIButton) {
        let vc = CoachViseOnDemandClassViewController.viewcontroller()
        if arrNewClass[sender.tag].live?.coach_class_type == "live" {
            vc.selectedCoachId = self.arrNewClass[sender.tag].live?.coachDetailsObj.id ?? ""
        } else if arrNewClass[sender.tag].on_demand?.coach_class_type == "on_demand" {
            vc.selectedCoachId = self.arrNewClass[sender.tag].on_demand?.coachDetailsObj.id ?? ""
        } else {
            vc.selectedCoachId = self.arrNewClass[sender.tag].Recipe?.coachDetailsObj.id ?? ""
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - CLICK EVENTS
    
    @IBAction func clickToBtnSearch( _ sender : UIButton) {
        let vc = SearchFollowersViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: - EXTENSION TABLEVIEW DATASOURCE AND DELEGATE

extension YourCoachesViewController : UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            print(self.scrollView.contentOffset.y)
            if safeAreaTop > 20 {
                tblNewClass.isScrollEnabled = (self.scrollView.contentOffset.y >= 490)
            } else {
                tblNewClass.isScrollEnabled = (self.scrollView.contentOffset.y >= 260)
            }
        }
        if scrollView == self.tblNewClass {
            self.tblNewClass.isScrollEnabled = (tblNewClass.contentOffset.y > 0)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: kHomeNewClassHeaderViewID) as? HomeNewClassHeaderView {
            headerView.lblTitle.text = "New Uploads"
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
        return arrNewClass.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: kNewClassesTBLViewCellID, for: indexPath) as? NewClassesTBLViewCell else { return UITableViewCell() }
        
        cell.clvDietaryRestriction.isHidden = true
        var recdModel = CoachClassPrevious()
        var isFromLiveDemand = true
        cell.btnUser.tag = indexPath.row
        cell.btnUser.addTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)
        
        recdModel = arrNewClass[indexPath.row].live ?? CoachClassPrevious()
        
        if recdModel.id == "" || recdModel.id.isEmpty {
            recdModel = arrNewClass[indexPath.row].on_demand ?? CoachClassPrevious()
            isFromLiveDemand = recdModel.id == "" ? false : true
        }
                
        if isFromLiveDemand {
            cell.selectedIndex = indexPath.row
            if cell.imgBlurThumbnail.image == nil {
                cell.imgBlurThumbnail.blurImage()
            }
            
            cell.viewTime.addCornerRadius(5)
            cell.viewUsername.addCornerRadius(5)
            cell.viewClassType.addCornerRadius(5)
            cell.viewUserImage.addCornerRadius(cell.viewUserImage.bounds.height / 2)
            
            cell.viewBG.addCornerRadius(10)
            cell.viewBG.backgroundColor = COLORS.APP_THEME_COLOR
                    
            cell.imgUser.setImageFromURL(imgUrl: recdModel.coachDetailsObj.user_image, placeholderImage: "")
            cell.imgBanner.setImageFromURL(imgUrl: recdModel.thumbnail_image, placeholderImage: "")
            cell.imgBlurThumbnail.setImageFromURL(imgUrl: recdModel.thumbnail_image, placeholderImage: "")

            cell.imgBookmark.image = recdModel.bookmark == BookmarkType.No ? UIImage(named: "BookmarkLight") : UIImage(named: "Bookmark")
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_class_id] = recdModel.id
                param[Params.AddRemoveBookmark.bookmark] = recdModel.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                if cell.lblClassType.text == "ON DEMAND" {
                    if Reachability.isConnectedToNetwork(){
                        self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, selectedIndex: cell.selectedIndex, recdType: SelectedDemandClass.onDemand)
                    }
                } else {
                    if Reachability.isConnectedToNetwork(){
                        self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, selectedIndex: cell.selectedIndex, recdType: SelectedDemandClass.live)
                    }
                }
            }
            cell.lblTitle.text = recdModel.class_type_name
            cell.lblSubTitle.text = recdModel.class_subtitle
            cell.lblTime.text = recdModel.duration
            cell.lblUsername.text = "@\(recdModel.coachDetailsObj.username)"

            if recdModel.coach_class_type == CoachClassType.live {
                cell.viewClassType.backgroundColor = hexStringToUIColor(hex: "#CC2936")
                cell.lblClassType.text = "LIVE"
                cell.lblDateTime.text = convertUTCToLocal(dateStr: recdModel.class_time, sourceFormate: "HH:mm", destinationFormate: "HH:mm")
                cell.lblDate.text = convertUTCToLocal(dateStr: recdModel.class_date, sourceFormate: "yyyy-MM-dd", destinationFormate: "dd MMM yyyy")
            } else if recdModel.coach_class_type == CoachClassType.onDemand {
                cell.viewClassType.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
                cell.lblClassType.text = "ON DEMAND"
                cell.lblDate.text = "\(recdModel.total_viewers) Views"
                cell.lblDateTime.text = convertUTCToLocal(dateStr: recdModel.created_at, sourceFormate: "yyyy-MM-dd HH:mm:ss", destinationFormate: "dd MMM yyyy")
            }
            
            if arrNewClass.count - 1 == indexPath.row {
                if Reachability.isConnectedToNetwork(){
                    callNewUploadAPI()
                }
            }
        } else {
            cell.clvDietaryRestriction.isHidden = false
            if let recdModel = arrNewClass[indexPath.row].Recipe {
                cell.selectedIndex = indexPath.row
                if cell.imgBlurThumbnail.image == nil {
                    cell.imgBlurThumbnail.blurImage()
                }
                
                cell.viewTime.addCornerRadius(5)
                cell.viewUsername.addCornerRadius(5)
                cell.viewClassType.addCornerRadius(5)
                cell.viewUserImage.addCornerRadius(cell.viewUserImage.bounds.height / 2)
                
                cell.viewBG.addCornerRadius(10)
                cell.viewBG.backgroundColor = COLORS.APP_THEME_COLOR
                        
                cell.imgUser.setImageFromURL(imgUrl: recdModel.coachDetailsObj.user_image, placeholderImage: "")
                cell.imgBanner.setImageFromURL(imgUrl: recdModel.thumbnail_image, placeholderImage: "")
                cell.imgBlurThumbnail.setImageFromURL(imgUrl: recdModel.thumbnail_image, placeholderImage: "")

                cell.imgBookmark.image = recdModel.bookmark == BookmarkType.No ? UIImage(named: "BookmarkLight") : UIImage(named: "Bookmark")
                cell.didTapBookmarkButton = {
                    var param = [String:Any]()
                    param[Params.AddRemoveBookmark.coach_recipe_id] = recdModel.id
                    param[Params.AddRemoveBookmark.bookmark] = recdModel.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                    if Reachability.isConnectedToNetwork(){
                        self.callToAddRemoveBookmarkAPI(urlStr: API.ADD_REMOVE_BOOKMARK, params: param, selectedIndex: cell.selectedIndex, recdType: SelectedDemandClass.recipe)
                    }
                }
                cell.lblTitle.text = recdModel.title
                cell.lblSubTitle.text = recdModel.sub_title
                cell.lblTime.text = recdModel.duration
                cell.lblUsername.text = "@\(recdModel.coachDetailsObj.username)"

                cell.viewClassType.backgroundColor = COLORS.RECIPE_COLOR
                cell.lblClassType.text = "RECIPE"
                cell.lblDate.text = "\(recdModel.viewers) Views"
                cell.lblDateTime.text = convertUTCToLocal(dateStr: recdModel.created_at, sourceFormate: "yyyy-MM-dd HH:mm:ss", destinationFormate: "dd MMM yyyy")

                recdModel.arrdietary_restriction.sort()
                var arrFilteredDietaryRestriction = [String]()
                
                if recdModel.arrdietary_restriction.count > 2 {
                    arrFilteredDietaryRestriction.append(recdModel.arrdietary_restriction[0])
                    arrFilteredDietaryRestriction.append(recdModel.arrdietary_restriction[1])
                    cell.arrDietaryRestriction = arrFilteredDietaryRestriction
                } else {
                    cell.arrDietaryRestriction = recdModel.arrdietary_restriction
                }

                cell.clvDietaryRestriction.reloadData()

                if arrNewClass.count - 1 == indexPath.row {
                    if Reachability.isConnectedToNetwork(){
                        callNewUploadAPI()
                    }
                }
            }
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? NewClassesTBLViewCell  {
            if cell.lblClassType.text == "LIVE" {
                let vc = LiveClassDetailsViewController.viewcontroller()
                vc.selectedId = arrNewClass[indexPath.row].live?.id ?? arrNewClass[indexPath.row].on_demand?.id ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            } else if cell.lblClassType.text == "ON DEMAND" {
                let vc = LiveClassDetailsViewController.viewcontroller()
                vc.selectedId = arrNewClass[indexPath.row].on_demand?.id ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = RecipeDetailsViewController.viewcontroller()
                let obj = arrNewClass[indexPath.row].Recipe
                vc.recipeID = obj?.id ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func callToAddRemoveBookmarkAPI(urlStr: String, params: [String:Any], selectedIndex: Int, recdType : String) {
        showLoader()
        _ =  ApiCallManager.requestApi(method: .post, urlString: urlStr, parameters: params, headers: nil) { responseObj in
            
            let message = responseObj["message"] as? String ?? ""
            Utility.shared.showToast(message)
            
            switch recdType {
            case SelectedDemandClass.live:
                for (index, model) in self.arrNewClass.enumerated() {
                    if selectedIndex == index {
                        model.live?.bookmark = model.live?.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                        self.arrNewClass[index] = model
                        DispatchQueue.main.async {
                            self.tblNewClass.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                        break
                    }
                }
            case SelectedDemandClass.onDemand:
                for (index, model) in self.arrNewClass.enumerated() {
                    if selectedIndex == index {
                        model.on_demand?.bookmark = model.on_demand?.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                        self.arrNewClass[index] = model
                        DispatchQueue.main.async {
                            self.tblNewClass.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                        break
                    }
                }
            case SelectedDemandClass.recipe:
                for (index, model) in self.arrNewClass.enumerated() {
                    if selectedIndex == index {
                        model.Recipe?.bookmark = model.Recipe?.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                        self.arrNewClass[index] = model
                        DispatchQueue.main.async {
                            self.tblNewClass.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                        break
                    }
                }
            default:
                print("")
            }
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }
}
// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension YourCoachesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clvPopularTrainer {
            return arrPopularTrainerList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularTrainerCollectionViewCell", for: indexPath) as!  PopularTrainerCollectionViewCell
        cell.setData(obj: arrPopularTrainerList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == clvPopularTrainer {
            return CGSize(width: 110, height: 165)
        }
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == clvPopularTrainer {
            let vc = CoachViseOnDemandClassViewController.viewcontroller()
            vc.selectedCoachId = arrPopularTrainerList[indexPath.row].id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
extension YourCoachesViewController {
    
    func callNewUploadAPI() {
        showLoader()
        
        let api = "\(API.NEW_UPLOAD)?\(Params.GetMyCoachClassList.page_no)=\(pageNo)&\(Params.GetMyCoachClassList.per_page)=\(perPageCount)"
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: api, parameters: nil, headers: nil) { responseObj in
            
            let dataObj = responseObj["new_uploads_list"] as? [Any] ?? [Any]()
            let arr = NewUploadList.getData(data: dataObj as? [[String:Any]] ?? [[:]])
            
            if arr.count > 0 {
                self.arrNewClass.append(contentsOf: arr)
                DispatchQueue.main.async {
                    self.tblNewClass.reloadData()
                }
            }
            
            if self.arrNewClass.count > 0 {
                if self.safeAreaTop > 20 {
                    self.lctOndemandTableHeight.constant = (self.view.frame.height - (30) - (35.0 + self.safeAreaTop + 14))
                } else {
                    self.lctOndemandTableHeight.constant = (self.view.frame.height - (self.safeAreaTop + 30 + 40))
                }
            } else {
                self.lctOndemandTableHeight.constant = 200.0
            }
            
            self.viewNoDataFoundNewClass.isHidden = self.arrNewClass.count > 0 ? true : false
            
            if arr.count < self.perPageCount {
                self.continueLoadingData = false
            }
            self.isDataLoading = false
            self.pageNo += 1
            
            self.hideLoader()
            self.view.layoutIfNeeded()
        } failure: { (error) in
            return true
        }
    }
    
    func callGetListOfClassDoneAPI() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.LIST_OF_CLASS_DONE, parameters: nil, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach"] as? [Any] ?? [Any]()
            self.arrPopularTrainerList =  PopularTrainerList.getData(data: dataObj)
            self.clvPopularTrainer.reloadData()
            self.hideLoader()
            
        } failure: { (error) in
            return true
        }
    }
}
