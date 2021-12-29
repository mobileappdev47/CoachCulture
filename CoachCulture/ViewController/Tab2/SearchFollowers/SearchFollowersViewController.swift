//
//  SearchFollowersViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit
import Alamofire

class SearchFollowersViewController: BaseViewController {
    
    static func viewcontroller() -> SearchFollowersViewController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "SearchFollowersViewController") as! SearchFollowersViewController
        return vc
    }
    
    @IBOutlet weak var tblSearchFollowers : UITableView!
    
    @IBOutlet weak var txtSearch : UITextField!
    
    @IBOutlet weak var viwLine1 : UIView!
    @IBOutlet weak var viwLine2 : UIView!
    @IBOutlet weak var viwNoDataFound : UIView!
    
    @IBOutlet weak var btnFollower : UIButton!
    @IBOutlet weak var btnAll : UIButton!
    var arrCoachSearchList = [CoachSearchList]()
    
    var dataRequest : DataRequest?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    func setUpUI() {
        hideTabBar()
        txtSearch.delegate = self
        tblSearchFollowers.register(UINib(nibName: "SearchFollowerItemTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchFollowerItemTableViewCell")
        tblSearchFollowers.delegate = self
        tblSearchFollowers.dataSource = self
        viwNoDataFound.isHidden = true
        
        clickToBtnFollowerAll(btnFollower)
        getAllCoachesListWithSearch(str: "")
       
    }
    
    //MARK: - CLICK EVENTS
    @IBAction func clickToBtnFollowerAll( _ sender : UIButton) {
        if sender == btnFollower {
            viwLine1.isHidden = false
            viwLine2.isHidden = true
        } else {
            viwLine1.isHidden = true
            viwLine2.isHidden = false
        }
        
        getAllCoachesListWithSearch(str: txtSearch.text!)
    }

}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension SearchFollowersViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrCoachSearchList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchFollowerItemTableViewCell", for: indexPath) as! SearchFollowerItemTableViewCell
        let obj = arrCoachSearchList[indexPath.row]
        cell.lblFollowers.text = "@" + obj.username
        cell.imgUser.setImageFromURL(imgUrl: obj.user_image, placeholderImage: nil)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = CoachViseOnDemandClassViewController.viewcontroller()
        vc.selectedCoachId = arrCoachSearchList[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - API call

extension SearchFollowersViewController {
    func getAllCoachesListWithSearch(str : String) {
        dataRequest?.cancel()
        
        showLoader()
        let param = [ "search" : str]
        
        var url = API.COACH_FOLLOWING_SEARCH_LIST
        if viwLine2.isHidden == false {
            url = API.COACH_ALL_SEARCH_LIST
        }
        
        dataRequest =  ApiCallManager.requestApi(method: .post, urlString: url, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach"] as? [Any] ?? [Any]()
            self.arrCoachSearchList = CoachSearchList.getData(data: dataObj)
            self.tblSearchFollowers.reloadData()
            if self.arrCoachSearchList.isEmpty {
                self.viwNoDataFound.isHidden = false
            } else {
                self.viwNoDataFound.isHidden = true
            }
            
            self.hideLoader()
            
        } failure: { (error) in
            return true
        }
    }
}


//MARK: - UITextFieldDelegate
extension SearchFollowersViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let finalString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
       
        self.getAllCoachesListWithSearch(str: finalString)
        
        
        return true
    }
    
}
