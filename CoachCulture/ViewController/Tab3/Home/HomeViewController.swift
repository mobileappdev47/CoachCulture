//
//  HomeViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 02/12/21.
//

import UIKit
import SDWebImage
import FirebaseDatabase

class HomeViewController: BaseViewController {
    
    static func viewcontroller() -> HomeViewController {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        return vc
    }
    
    static func viewcontrollerNav() -> UINavigationController {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeViewNavVc") as! UINavigationController
        return vc
    }
    @IBOutlet weak var viewNoDataFoundPopularClasses: UIView!
    @IBOutlet weak var viewNoDataFoundPopularTrainers: UIView!
    @IBOutlet weak var viewNoDataFoundNewClass: UIView!
    @IBOutlet weak var tblNewClass: UITableView!
    @IBOutlet weak var lblPopularTitle : UILabel!
    @IBOutlet weak var lblNavTitle : UILabel!
    @IBOutlet weak var lblPopularClassesTitle : UILabel!
    @IBOutlet weak var lblCoachClassType : UILabel!
    @IBOutlet weak var lblDuration : UILabel!
    @IBOutlet weak var lblUserName : UILabel!
    @IBOutlet weak var lblClassDate : UILabel!
    @IBOutlet weak var lblClassTime : UILabel!
    @IBOutlet weak var btnClassbookMark : UIButton!
    @IBOutlet weak var imgUser : UIImageView!
    @IBOutlet weak var clvPopularTrainer : UICollectionView!
    @IBOutlet weak var clvPopularClasses : UICollectionView!
    @IBOutlet weak var lctOndemandTableHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!

    var upCommingLiveClassObj = UpCommingLiveClass()
    var arrPopularClassList = [PopularClassList]()
    var arrPopularTrainerList = [PopularTrainerList]()
    var kNewClassesTBLViewCellID = "NewClassesTBLViewCell"
    var kHomeNewClassHeaderViewID = "HomeNewClassHeaderView"
    var isDataLoading = false
    var continueLoadingData = true
    var pageNo = 1
    var perPageCount = 10
    var arrNewClass = [CoachClassPrevious]()
    let safeAreaTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0.0

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = Database.database().reference()

        ref.child("stripe").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let sk = value?["sk"] as? String ?? ""
            print(sk)
            StripeConstant.Secret_key = sk
            // ...
        }) { (error) in
                    print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpUI()
        showTabBar()
    }
    
    // MARK: - Methods
    func setUpUI() {
        tblNewClass.register(UINib(nibName: kHomeNewClassHeaderViewID, bundle: nil), forHeaderFooterViewReuseIdentifier: kHomeNewClassHeaderViewID)
        tblNewClass.register(UINib(nibName: kNewClassesTBLViewCellID, bundle: nil), forCellReuseIdentifier: kNewClassesTBLViewCellID)
        tblNewClass.delegate = self
        tblNewClass.dataSource = self
        
        clvPopularTrainer.register(UINib(nibName: "PopularTrainerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PopularTrainerCollectionViewCell")
        clvPopularTrainer.delegate = self
        clvPopularTrainer.dataSource = self
        
        clvPopularClasses.register(UINib(nibName: "PopularClassesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PopularClassesCollectionViewCell")
        clvPopularClasses.delegate = self
        clvPopularClasses.dataSource = self
        
        if Reachability.isConnectedToNetwork(){
            callGetMyCoachClassListAPI()
            getPopularTrainerList()
            getPopularClassList()
        }
        
        self.tblNewClass.isScrollEnabled = false
        self.scrollView.delegate = self
    }
    
    func resetVariable() {
        arrNewClass.removeAll()
        isDataLoading = false
        continueLoadingData = true
        pageNo = 1
        perPageCount = 10
    }

    func setData() {
        lblDuration.text = upCommingLiveClassObj.duration
        lblCoachClassType.text = upCommingLiveClassObj.coach_class_type
        imgUser.setImageFromURL(imgUrl: upCommingLiveClassObj.user_image, placeholderImage: nil)
        lblClassDate.text = upCommingLiveClassObj.classDateFormated
        lblClassTime.text = upCommingLiveClassObj.classTimeFormated
    }
    
    //MARK: - ACTION
    
    @IBAction func clickToBtnSearch( _ sender : UIButton) {
        let vc = SearchFollowersViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == clvPopularClasses {
            return arrPopularClassList.count
        }
        return arrPopularTrainerList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == clvPopularClasses {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularClassesCollectionViewCell", for: indexPath) as!  PopularClassesCollectionViewCell
            cell.setData(obj: arrPopularClassList[indexPath.row])
            
            return cell
        } else {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularTrainerCollectionViewCell", for: indexPath) as!  PopularTrainerCollectionViewCell
            cell.setData(obj: arrPopularTrainerList[indexPath.row])

            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == clvPopularClasses {
            let width =  (clvPopularClasses.frame.width - 20 ) / 2.3
            return CGSize(width: width, height: 190)
        } else {
            let width =  (clvPopularClasses.frame.width - 20 ) / 3.3
            return CGSize(width: width, height: 165)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == clvPopularClasses {
            let vc = LiveClassDetailsViewController.viewcontroller()
            vc.selectedId = arrPopularClassList[indexPath.row].coach_class_id
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc = CoachViseOnDemandClassViewController.viewcontroller()
            vc.selectedCoachId = arrPopularTrainerList[indexPath.row].coach_id
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}



//MARK: - API call

extension HomeViewController {
    func callGetMyCoachClassListAPI() {
        showLoader()
        
        var params = [String:Any]()
        params[Params.GetMyCoachClassList.page_no] = pageNo
        params[Params.GetMyCoachClassList.per_page] = perPageCount
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_MY_COACH_CLASS_LIST, parameters: params, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_class_list"] as? [Any] ?? [Any]()
            let arr = CoachClassPrevious.getData(data: dataObj)
            
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
    
    func getPopularClassList() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_POPULAR_CLASS_LIST, parameters: nil, headers: nil) { responseObj in
            
            let dataObj = responseObj["popular_class_list"] as? [Any] ?? [Any]()
            self.arrPopularClassList =  PopularClassList.getData(data: dataObj)
            if self.arrPopularClassList.count == 0 {
                self.viewNoDataFoundPopularClasses.isHidden = false
            } else {
                self.viewNoDataFoundPopularClasses.isHidden = true
                self.clvPopularClasses.reloadData()
            }
            self.hideLoader()
            
        } failure: { (error) in
            return true
        }
    }
    
    func getPopularTrainerList() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_POPULAR_TRAINER_LIST, parameters: nil, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_list"] as? [Any] ?? [Any]()
            self.arrPopularTrainerList =  PopularTrainerList.getData(data: dataObj)
            if self.arrPopularTrainerList.count == 0 {
                self.viewNoDataFoundPopularTrainers.isHidden = false
            } else {
                self.viewNoDataFoundPopularTrainers.isHidden = true
                self.clvPopularTrainer.reloadData()
            }
            self.hideLoader()
            
        } failure: { (error) in
            return true
        }
    }
    
    @objc func clickToBtnUser( _ sender : UIButton) {
        let vc = CoachViseOnDemandClassViewController.viewcontroller()
        vc.selectedCoachId = self.arrNewClass[sender.tag].coachDetailsObj.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            print(self.scrollView.contentOffset.y)
            if safeAreaTop > 20 {
                tblNewClass.isScrollEnabled = (self.scrollView.contentOffset.y >= 490)
            } else {
                tblNewClass.isScrollEnabled = (self.scrollView.contentOffset.y >= 500)
            }
        }
        if scrollView == self.tblNewClass {
            self.tblNewClass.isScrollEnabled = (tblNewClass.contentOffset.y > 0)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: kHomeNewClassHeaderViewID) as? HomeNewClassHeaderView {
            headerView.lblTitle.text = "    Recommended Classes"
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
        
        let model = arrNewClass[indexPath.row]
        cell.selectedIndex = indexPath.row
        if cell.imgBlurThumbnail.image == nil {
            cell.imgBlurThumbnail.blurImage()
        }
        
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
                self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, selectedIndex: cell.selectedIndex)
            }
        }
        cell.lblTitle.text = model.class_type_name
        cell.lblSubTitle.text = model.class_subtitle
        cell.lblTime.text = model.duration
        cell.lblUsername.text = "@\(model.coachDetailsObj.username)"

        cell.lblDateTime.textAlignment = .left
        cell.lblDate.textAlignment = .left

        if model.coach_class_type == CoachClassType.live {
            cell.viewClassType.backgroundColor = hexStringToUIColor(hex: "#CC2936")
            cell.lblClassType.text = "LIVE"
            cell.lblDateTime.font = UIFont(name: "SFProText-Heavy", size: 25.0)
            cell.lblDate.font = UIFont(name: "SFProText-Heavy", size: 15.0)
            cell.lblDateTime.text = convertUTCToLocal(dateStr: model.class_time, sourceFormate: "HH:mm", destinationFormate: "HH:mm")
            cell.lblDate.text = convertUTCToLocal(dateStr: model.class_date, sourceFormate: "yyyy-MM-dd", destinationFormate: "dd MMM yyyy")
        } else if model.coach_class_type == CoachClassType.onDemand {
            cell.viewClassType.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
            cell.lblDate.font = UIFont(name: "SFProText-Bold", size: 18.0)
            cell.lblDateTime.font = UIFont(name: "SFProText-Heavy", size: 14.0)
            cell.lblClassType.text = "ON DEMAND"
            cell.lblDate.text = "\(model.total_viewers) Views"
            cell.lblDateTime.text = convertUTCToLocal(dateStr: model.created_at, sourceFormate: "yyyy-MM-dd HH:mm:ss", destinationFormate: "dd MMM yyyy")
        }
        
        if arrNewClass.count - 1 == indexPath.row {
            if Reachability.isConnectedToNetwork(){
                callGetMyCoachClassListAPI()
            }
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = arrNewClass[indexPath.row]
        let vc = LiveClassDetailsViewController.viewcontroller()
        vc.selectedId = model.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func callToAddRemoveBookmarkAPI(urlStr: String, params: [String:Any], selectedIndex: Int) {
        showLoader()
        _ =  ApiCallManager.requestApi(method: .post, urlString: urlStr, parameters: params, headers: nil) { responseObj in
            
            let message = responseObj["message"] as? String ?? ""
            Utility.shared.showToast(message)
            
            for (index, model) in self.arrNewClass.enumerated() {
                if selectedIndex == index {
                    model.bookmark = model.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                    self.arrNewClass[index] = model
                    DispatchQueue.main.async {
                        self.tblNewClass.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                    break
                }
            }
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }
}
