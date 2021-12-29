//
//  ManageSubscriptionListViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 23/12/21.
//

import UIKit
import Alamofire

class ManageSubscriptionListViewController: BaseViewController {
    
    static func viewcontroller() -> ManageSubscriptionListViewController {
        let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "ManageSubscriptionListViewController") as! ManageSubscriptionListViewController
        return vc
    }
    
    @IBOutlet weak var tblManageSubscription: UITableView!
    
    @IBOutlet weak var txtSearch: UITextField!
    var arrSubsciptionList = [SubsciptionList]()
    
    private var isDataLoading = false
    private var continueLoadingData = true
    private var pageNo = 1
    private var perPageCount = 10
    var searchString = ""
    
    var dataRequest: DataRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SubscriptionItemTableViewCell
        setUpUI()
    }
    
    // MARK: - Methods
    func setUpUI() {
        
        tblManageSubscription.register(UINib(nibName: "SubscriptionItemTableViewCell", bundle: nil), forCellReuseIdentifier: "SubscriptionItemTableViewCell")
        tblManageSubscription.delegate = self
        tblManageSubscription.dataSource = self
        txtSearch.delegate = self
        
        getCoachSubscriptionList()
        
    }
    
    func resetAll() {
       isDataLoading = false
       continueLoadingData = true
       pageNo = 1
       perPageCount = 10
        arrSubsciptionList.removeAll()
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension ManageSubscriptionListViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrSubsciptionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionItemTableViewCell", for: indexPath) as! SubscriptionItemTableViewCell
        let obj = arrSubsciptionList[indexPath.row]
        cell.lblUserName.text = "@" + obj.username
        cell.lblDate.text = "end " +  obj.endDate
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
        
    }
}

extension ManageSubscriptionListViewController {
    
    func getCoachSubscriptionList() {
        
        dataRequest?.cancel()
        
        if(isDataLoading || !continueLoadingData){
            return
        }
        
        isDataLoading = true
        
        showLoader()
        let param = [ "search" : searchString,
                      "page_no" : "\(pageNo)",
                      "per_page" : "\(perPageCount)"]
        
        
        dataRequest =  ApiCallManager.requestApi(method: .post, urlString: API.GET_SUBSCRIPTION_COACH_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_list"] as? [Any] ?? [Any]()
            let arr = SubsciptionList.getData(data: dataObj)
            self.arrSubsciptionList.append(contentsOf: arr)
            self.tblManageSubscription.reloadData()
            
            if arr.count < self.perPageCount
            {
                self.continueLoadingData = false
            }
            self.isDataLoading = false
            
            self.hideLoader()
            
            
        } failure: { (error) in
            return true
        }
    }
}


//MARK: - UITextFieldDelegate
extension ManageSubscriptionListViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
       searchString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
       
        return true
    }
    
  
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.resetAll()
        getCoachSubscriptionList()
    }

}
