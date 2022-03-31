
import UIKit

class NotificationVC: BaseViewController {
    
    //MARK: - OUTLET
    
    @IBOutlet weak var viewNoDataFound: UIView!
    @IBOutlet weak var tblNotificationView: UITableView!
    
    //MARK: - VARIABLE AND OBJECT
    
    var arrNotificationList = [ModelNotificationClass]()
    var kCoachViseOnDemandClassItemTableViewCell = "CoachViseOnDemandClassItemTableViewCell"
    var kCoachViseRecipeItemTableViewCell = "CoachViseRecipeItemTableViewCell"
    
    //MARK: - VIEW CONTROLLER LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initialSetupUI()
        if Reachability.isConnectedToNetwork() {
            self.getNotificationListAPI()
        }
    }
        
    //MARK: - FUNCTION
    
    private func initialSetupUI() {
        self.hideTabBar()
        tblNotificationView.register(UINib(nibName: kCoachViseOnDemandClassItemTableViewCell, bundle: nil), forCellReuseIdentifier: kCoachViseOnDemandClassItemTableViewCell)
        
        tblNotificationView.register(UINib(nibName: kCoachViseRecipeItemTableViewCell, bundle: nil), forCellReuseIdentifier: kCoachViseRecipeItemTableViewCell)
        tblNotificationView.delegate = self
        tblNotificationView.dataSource = self
    }
    
    //MARK: - API CALLING
    
    func getNotificationListAPI() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.GET_NOTIFICATION_LIST, parameters: nil, headers: nil) { responseObj in
            
            let dataObj = responseObj["data"] as? [Any] ?? [Any]()
            let arr = ModelNotificationClass.getData(data: dataObj)
            if arr.count > 0 {
                self.arrNotificationList = arr
                self.viewNoDataFound.isHidden = true
                DispatchQueue.main.async {
                    self.tblNotificationView.reloadData()
                }
            } else {
                self.viewNoDataFound.isHidden = false
            }
            self.hideLoader()
        } failure: { (error) in
            self.viewNoDataFound.isHidden = false
            return true
        }
    }
    
    func callToAddRemoveBookmarkAPI(urlStr: String, params: [String:Any], recdType : String, selectedIndex: Int) {
        showLoader()
        _ =  ApiCallManager.requestApi(method: .post, urlString: urlStr, parameters: params, headers: nil) { responseObj in
            
            if let message = responseObj["message"] as? String {
                Utility.shared.showToast(message)
            }
            switch recdType {
            case SelectedDemandClass.onDemand, SelectedDemandClass.live, SelectedDemandClass.recipe:
                for (index, model) in self.arrNotificationList.enumerated() {
                    if selectedIndex == index {
                        model.meta.bookmark = model.meta.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                        self.arrNotificationList[index] = model
                        DispatchQueue.main.async {
                            self.tblNotificationView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                            self.tblNotificationView.endUpdates()
                        }
                        break
                    }
                }
            default:
                if Reachability.isConnectedToNetwork() {
                    self.getNotificationListAPI()
                }
            }
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }
    
    //MARK: - ACTION
    
    @IBAction func clickToBtnUser( _ sender : UIButton) {
        var coachID = String()
        let vc = CoachViseOnDemandClassViewController.viewcontroller()
        if self.arrNotificationList[sender.tag].meta.coachDetailsObj.id.isEmpty || self.arrNotificationList[sender.tag].meta.coachDetailsObj.id != "" {
            coachID = self.arrNotificationList[sender.tag].meta.coachDetailsObj.id
        } else {
            coachID = self.arrNotificationList[sender.tag].meta.coach.id
        }
        vc.selectedCoachId = coachID
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - EXTENSION TABLE DATASOURCE AND DELEGATE

extension NotificationVC : UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNotificationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let obj = arrNotificationList[indexPath.row]

        if obj.notification_type == NotificationType.on_demand {
            let cell = tableView.dequeueReusableCell(withIdentifier: kCoachViseOnDemandClassItemTableViewCell, for: indexPath) as! CoachViseOnDemandClassItemTableViewCell
            
            cell.viewSubscribe.isHidden = false
            cell.viewClassDetail.isHidden = false
            cell.lblClassType.text = "On demand".uppercased()
            cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
            let metaObj = arrNotificationList[indexPath.row].meta
            
            cell.viewProfile.isHidden = false
            if cell.imgProfileBottom.image == nil {
                cell.imgProfileBottom.blurImage()
            }
            cell.viewProfile.addCornerRadius(10)
            cell.viewProfile.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            cell.imgProfileBottom.setImageFromURL(imgUrl: metaObj.coachDetailsObj.user_image, placeholderImage: "")
            cell.imgProfileBanner.setImageFromURL(imgUrl: metaObj.coachDetailsObj.user_image, placeholderImage: "")
            cell.btnUser.tag = indexPath.row
            cell.btnUser.addTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)
            cell.imgUser.setImageFromURL(imgUrl: metaObj.thumbnail_image, placeholderImage: "")
            cell.selectedIndex = indexPath.row
            cell.lbltitle.text = metaObj.class_type
            cell.lblClassDifficultyLevel.text = metaObj.class_subtitle
            cell.lblClassDate.text = getRealDate(date: metaObj.created_at)
            cell.lblUsername.text = "@" + metaObj.coachDetailsObj.username
            cell.lblClassTime.text = metaObj.viewers + " Views"
            cell.lblClassDate.font = UIFont(name: cell.lblClassTime.font.fontName, size: 13)
            cell.lblClassTime.font = UIFont(name: cell.lblClassTime.font.fontName, size: 12)
            cell.lblDuration.layer.maskedCorners = [.layerMinXMinYCorner]
            cell.lblDuration.text = metaObj.duration
            cell.didTapBookmarkButton = {
                self.tblNotificationView.beginUpdates()
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_class_id] = obj.meta.id
                param[Params.AddRemoveBookmark.bookmark] = metaObj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                if Reachability.isConnectedToNetwork() {
                    self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, recdType: SelectedDemandClass.onDemand, selectedIndex: cell.selectedIndex)
                }
            }
            if metaObj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            
            cell.lblSubscribedTime.text = Date().getDateStringVariation(from: obj.datetime)
            cell.lblSubscribedName.text = obj.message

            cell.layoutIfNeeded()
            return cell
        } else if obj.notification_type == NotificationType.live {
            let cell = tableView.dequeueReusableCell(withIdentifier: kCoachViseOnDemandClassItemTableViewCell, for: indexPath) as! CoachViseOnDemandClassItemTableViewCell
            cell.viewSubscribe.isHidden = false
            cell.viewClassDetail.isHidden = false
            cell.lblClassType.text = "Live".uppercased()
            cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#CC2936")
            cell.selectedIndex = indexPath.row
            let metaObj = arrNotificationList[indexPath.row].meta
            cell.viewProfile.isHidden = false
            if cell.imgProfileBottom.image == nil {
                cell.imgProfileBottom.blurImage()
            }
            cell.viewProfile.addCornerRadius(10)
            cell.viewProfile.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            cell.imgProfileBottom.setImageFromURL(imgUrl: metaObj.coachDetailsObj.user_image, placeholderImage: "")
            cell.imgProfileBanner.setImageFromURL(imgUrl: metaObj.coachDetailsObj.user_image, placeholderImage: "")
            cell.btnUser.tag = indexPath.row
            cell.btnUser.addTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)
            
            cell.imgUser.setImageFromURL(imgUrl: metaObj.thumbnail_image, placeholderImage: "")
            //cell.lblClassDate.text = obj.created_atFormated
            cell.lbltitle.text = metaObj.class_type
            cell.lblClassDifficultyLevel.text = metaObj.class_subtitle
            cell.lblUsername.text = "@" + metaObj.coachDetailsObj.username
            cell.lblDuration.layer.maskedCorners = [.layerMinXMinYCorner]
            cell.lblDuration.text = metaObj.duration
            
            cell.lblClassDate.text = getRealDate(date: metaObj.created_at)
            cell.lblClassTime.text = convertUTCToLocal(dateStr: metaObj.class_time, sourceFormate: "HH:mm:ss", destinationFormate: "HH:mm")
            cell.lblClassDate.font = UIFont(name: cell.lblClassTime.font.fontName, size: 13)
            cell.lblClassTime.font = UIFont(name: cell.lblClassTime.font.fontName, size: 14)
            cell.lblClassDate.sizeToFit()
            cell.lblClassTime.sizeToFit()
            
            cell.imgProfileBottom.setImageFromURL(imgUrl: metaObj.coachDetailsObj.user_image, placeholderImage: "")
            cell.imgProfileBanner.setImageFromURL(imgUrl: metaObj.coachDetailsObj.user_image, placeholderImage: "")
            
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_class_id] = obj.meta.id
                param[Params.AddRemoveBookmark.bookmark] = metaObj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                if Reachability.isConnectedToNetwork(){
                    self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, recdType: SelectedDemandClass.live, selectedIndex: cell.selectedIndex)
                }
            }
            if metaObj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            
            cell.lblSubscribedTime.text = Date().getDateStringVariation(from: obj.datetime)
            cell.lblSubscribedName.text = obj.message

            cell.layoutIfNeeded()
            return cell
        } else if obj.notification_type == NotificationType.recipe {
            let cell = tableView.dequeueReusableCell(withIdentifier: kCoachViseRecipeItemTableViewCell, for: indexPath) as! CoachViseRecipeItemTableViewCell
            cell.viewSubscribe.isHidden = false
            cell.viewClassDetail.isHidden = false
            let metaObj = arrNotificationList[indexPath.row].meta
            cell.didTapBookmarkButton = {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_recipe_id] = obj.meta.id
                param[Params.AddRemoveBookmark.bookmark] = metaObj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                if Reachability.isConnectedToNetwork(){
                    self.callToAddRemoveBookmarkAPI(urlStr: API.ADD_REMOVE_BOOKMARK, params: param, recdType: SelectedDemandClass.recipe, selectedIndex: cell.selectedIndex)
                }
            }
            cell.selectedIndex = indexPath.row
            cell.lbltitle.text = metaObj.title
            cell.lblDuration.text = metaObj.duration
            cell.lblRecipeType.text = metaObj.arrMealTypeString
            cell.btnUser.tag = indexPath.row
            cell.btnUser.addTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)
            
            var arrFilteredDietaryRestriction = [String]()
            
            if metaObj.arrdietary_restriction.count > 2 {
                arrFilteredDietaryRestriction.append(metaObj.arrdietary_restriction[0])
                arrFilteredDietaryRestriction.append(metaObj.arrdietary_restriction[1])
                cell.arrDietaryRestriction = arrFilteredDietaryRestriction
            } else {
                cell.arrDietaryRestriction = metaObj.arrdietary_restriction
            }
            
            cell.clvDietaryRestriction.reloadData()
            
            cell.viewProfile.isHidden = false
            if cell.imgProfileBottom.image == nil {
                cell.imgProfileBottom.blurImage()
            }
            cell.viewProfile.addCornerRadius(10)
            cell.viewProfile.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            cell.lblUsername.text = "@\(metaObj.coach.username)"
            cell.imgProfileBottom.setImageFromURL(imgUrl: metaObj.coachDetailsObj.user_image, placeholderImage: "")
            cell.imgProfileBanner.setImageFromURL(imgUrl: metaObj.coachDetailsObj.user_image, placeholderImage: "")
            
            cell.imgUser.setImageFromURL(imgUrl: metaObj.thumbnail_image, placeholderImage: nil)
            if metaObj.bookmark == "no" {
                cell.imgBookMark.image = UIImage(named: "BookmarkLight")
            } else {
                cell.imgBookMark.image = UIImage(named: "Bookmark")
            }
            
            cell.lblSubscribedTime.text = Date().getDateStringVariation(from: obj.datetime)
            cell.lblSubscribedName.text = obj.message

            cell.layoutIfNeeded()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kCoachViseOnDemandClassItemTableViewCell, for: indexPath) as! CoachViseOnDemandClassItemTableViewCell
            cell.viewSubscribe.isHidden = false
            cell.viewClassDetail.isHidden = true
            
            cell.lblSubscribedTime.text = Date().getDateStringVariation(from: obj.datetime)
            cell.lblSubscribedName.text = obj.message

            cell.layoutIfNeeded()
            return cell
        }
    }
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 10))
        headerView.backgroundColor = .clear
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let obj = arrNotificationList[indexPath.row]
        switch obj.notification_type {
        case NotificationType.on_demand, NotificationType.live, NotificationType.recipe:
            return 150
        default:
            return 45
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = arrNotificationList[indexPath.row]
        if obj.notification_type == NotificationType.on_demand || obj.notification_type == NotificationType.live {
            let vc = LiveClassDetailsViewController.viewcontroller()
            let obj = arrNotificationList[indexPath.row]
            vc.selectedId = obj.meta.id
            self.navigationController?.pushViewController(vc, animated: true)
        } else if obj.notification_type == NotificationType.recipe {
            let vc = RecipeDetailsViewController.viewcontroller()
            let obj = arrNotificationList[indexPath.row]
            vc.recipeID = obj.meta.id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - NOTIFICATION TYPE

struct NotificationType {
    static let subscribed = 1
    static let following = 2
    static let recipe = 3
    static let live = 4
    static let on_demand = 5
}
