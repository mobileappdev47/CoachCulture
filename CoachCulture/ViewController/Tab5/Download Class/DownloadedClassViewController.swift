//
//  DownloadedClassViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 25/12/21.
//

import UIKit


class DownloadedClassViewController: BaseViewController {
    
    static func viewcontroller() -> DownloadedClassViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "DownloadedClassViewController") as! DownloadedClassViewController
        return vc
    }
    @IBOutlet weak var viewNoDataFound: UIView!
    @IBOutlet weak var lblNoDataFound: UILabel!
    @IBOutlet weak var tblOndemand: UITableView!
    var arrCoachClassPrevious = [ClassDetailData]()
    var arrMainCoachClassPrevious = [ClassDetailData]()
    
    @IBOutlet weak var txtSearch: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setUpUI()
    }
    // MARK: - Methods
    func setUpUI() {
        hideTabBar()
        tblOndemand.register(UINib(nibName: "SearchResultItemTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchResultItemTableViewCell")
        tblOndemand.delegate = self
        tblOndemand.dataSource = self
        //tblOndemand.reloadData()
        txtSearch.delegate = self
        
        if Reachability.isConnectedToNetwork(){
            getMultipleDownloadedClassDetailsList()
        }else{
            arrCoachClassPrevious = AppPrefsManager.sharedInstance.getClassData()
            arrMainCoachClassPrevious = AppPrefsManager.sharedInstance.getClassData()

            if self.arrCoachClassPrevious.count > 0 {
                self.viewNoDataFound.isHidden = true
            } else {
                self.viewNoDataFound.isHidden = false
            }
            
            self.tblOndemand.reloadData()
        }
            
    }
    
    func search(str : String) {
        arrCoachClassPrevious.removeAll()
        if str.isEmpty {
            arrCoachClassPrevious.append(contentsOf: arrMainCoachClassPrevious)
        } else {
            let arr = arrMainCoachClassPrevious.filter({ obj in
                return obj.class_subtitle.lowercased().contains(str.lowercased())
            })
            
            arrCoachClassPrevious.append(contentsOf: arr)
        }
        
        tblOndemand.reloadData()
        
    }
    
    @objc func clickToBtnUser( _ sender : UIButton) {
        let vc = CoachViseOnDemandClassViewController.viewcontroller()
        vc.selectedCoachId = self.arrMainCoachClassPrevious[sender.tag].coachDetailsDataObj.id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DownloadedClassViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrCoachClassPrevious.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultItemTableViewCell", for: indexPath) as! SearchResultItemTableViewCell
        let obj = arrCoachClassPrevious[indexPath.row]
        cell.selectedIndex = indexPath.row
        cell.viewBlur.isHidden = true
        cell.lblClassType.text = "On demand".uppercased()
        cell.viwClassTypeContainer.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
        cell.imgUser.setImageFromURL(imgUrl: obj.coachDetailsDataObj.user_image, placeholderImage: "coverBG")
        if cell.imgThumbnail.image == nil {
            cell.imgThumbnail.blurImage()
        }
        cell.imgThumbnail.setImageFromURL(imgUrl: obj.coachDetailsDataObj.user_image, placeholderImage: "coverBG")
        cell.imgClassCover.setImageFromURL(imgUrl: obj.thumbnail_image, placeholderImage: "coverBG")
        cell.lbltitle.text = obj.class_subtitle
        cell.lblClassDifficultyLevel.text = obj.class_difficulty
        cell.lblClassDate.text = obj.class_subtitle
        cell.lblUserName.text = "@" + obj.coachDetailsDataObj.username
        cell.lblClassTime.text = obj.total_viewers + " Views"
        cell.viewDuration.layer.maskedCorners = [.layerMinXMinYCorner]
        cell.lblDuration.text = obj.duration
        cell.viwRating.value = 0
        cell.btnUser.tag = indexPath.row
        cell.btnUser.addTarget(self, action: #selector(self.clickToBtnUser(_:)), for: .touchUpInside)
        if obj.bookmark == "no" {
            cell.imgBookMark.image = UIImage(named: "BookmarkLight")
        } else {
            cell.imgBookMark.image = UIImage(named: "Bookmark")
        }
        cell.didTapBookmarkButton = {
            if Reachability.isConnectedToNetwork() {
                var param = [String:Any]()
                param[Params.AddRemoveBookmark.coach_class_id] = obj.id
                param[Params.AddRemoveBookmark.bookmark] = obj.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                if Reachability.isConnectedToNetwork() {
                    self.callToAddRemoveBookmarkAPI(urlStr: API.COACH_CLASS_BOOKMARK, params: param, recdType: SelectedDemandClass.onDemand, selectedIndex: cell.selectedIndex)
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
            case SelectedDemandClass.onDemand:
                for (index, model) in self.arrCoachClassPrevious.enumerated() {
                    if selectedIndex == index {
                        model.bookmark = model.bookmark == BookmarkType.No ? BookmarkType.Yes : BookmarkType.No
                        self.arrCoachClassPrevious[index] = model
                        DispatchQueue.main.async {
                            self.tblOndemand.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        }
                        break
                    }
                }
            default:
                if Reachability.isConnectedToNetwork() {
                    self.getMultipleDownloadedClassDetailsList()
                }
            }
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = LiveClassDetailsViewController.viewcontroller()
        vc.selectedId = arrCoachClassPrevious[indexPath.row].id
        vc.isFromClassDownloadedPage = true
        vc.deleteID = indexPath.row
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
    
    
}


extension DownloadedClassViewController {
    func getMultipleDownloadedClassDetailsList() {
        
        var ids = ""
        
        for temp in  AppPrefsManager.sharedInstance.getClassData(){
            if ids.isEmpty {
                ids = temp.id
            } else {
                ids += "," + temp.id
            }
        }
        
        showLoader()
        let param = [ "id" : "\(ids)"]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_MULTIPLE_CLASS_DETAILS, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_detail_list"] as? [Any] ?? [Any]()
            self.arrCoachClassPrevious = ClassDetailData.getData(data: dataObj)
            self.arrMainCoachClassPrevious = ClassDetailData.getData(data: dataObj)

            if self.arrCoachClassPrevious.count > 0 {
                self.viewNoDataFound.isHidden = true
            } else {
                self.viewNoDataFound.isHidden = false
            }
            
            self.tblOndemand.reloadData()
            self.hideLoader()
            
        } failure: { (error) in
            return true
        }
    }
}


//MARK: - UITextFieldDelegate
extension DownloadedClassViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let str = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        search(str: str)
        
        return true
    }

    
}
