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
    
    @IBOutlet weak var viewNoDataFound: UIView!
    @IBOutlet weak var tblManageSubscription: UITableView!
    
    @IBOutlet weak var txtSearch: UITextField!
    var arrSubsciptionList = [SubsciptionList]()
    
    private var isDataLoading = false
    private var continueLoadingData = true
    private var pageNo = 1
    private var perPageCount = 10
    var searchString = ""

    var dataRequest: DataRequest?
    
    
    var cancelSubScription: CancelSubScription!
    
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
        
        cancelSubScription = Bundle.main.loadNibNamed("CancelSubScription", owner: nil, options: nil)?.first as? CancelSubScription
        cancelSubScription.tapToBtnYes {
            
        }
        
        cancelSubScription.tapToBtnNo {
            self.cancelSubScription.removeFromSuperview()
        }
        
        getCoachSubscriptionList(isShowLoader: true)
        
    }
    
    func setCancelSubScription() {
        
        cancelSubScription.frame.size = self.view.frame.size
        self.view.addSubview(cancelSubScription)
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
        cell.selectedIndex = indexPath.row
        cell.viwUnsubscribe.isHidden = obj.unsubscribe_status ? true : false
        cell.viwSubscribe.isHidden = obj.unsubscribe_status ? false : true
        
        let recdCurrency = obj.feesDataObj.fee_regional_currency
        var currencySybmol = ""
        
        switch recdCurrency {
        case BaseCurrencyList.SGD:
            currencySybmol = BaseCurrencySymbol.SGD
        case BaseCurrencyList.USD:
            currencySybmol = BaseCurrencySymbol.USD
        case BaseCurrencyList.EUR:
            currencySybmol = BaseCurrencySymbol.EUR
        default:
            currencySybmol = ""
        }
        cell.lblPrice.text =  "\(currencySybmol)\(obj.feesDataObj.subscriber_fee)"

        cell.didTapUnsubscribeClick = {
            self.callUnsubscribeToCoachAPI(selectedIndex: cell.selectedIndex, id: obj.id)
        }
        cell.lblUserName.text = "@" + obj.username
        cell.lblDate.text = "end " +  obj.endDate
        cell.imgUser.setImageFromURL(imgUrl: obj.user_image, placeholderImage: nil)
        if arrSubsciptionList.count - 1 == indexPath.row {
            isDataLoading = false
            continueLoadingData = true
            self.getCoachSubscriptionList(isShowLoader: true)
        }
        cell.layoutIfNeeded()
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
    
    func getCoachSubscriptionList(isShowLoader: Bool) {
        
        dataRequest?.cancel()
        
        if isDataLoading || !continueLoadingData{
            return
        }
        
        isDataLoading = true
        
        if isShowLoader {
            showLoader()
        }
        let param = [ "search" : searchString,
                      "page_no" : "\(pageNo)",
                      "per_page" : "\(perPageCount)"]
        
        
        dataRequest =  ApiCallManager.requestApi(method: .post, urlString: API.GET_SUBSCRIPTION_COACH_LIST, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_list"] as? [Any] ?? [Any]()
            let arr = SubsciptionList.getData(data: dataObj)
            
            if arr.count > 0 {
                self.arrSubsciptionList.append(contentsOf: arr)
                self.tblManageSubscription.reloadData()
            }
            
            if arr.count < self.perPageCount
            {
                self.continueLoadingData = false
            }
            self.isDataLoading = false
            self.pageNo += 1

            if self.arrSubsciptionList.count > 0 {
                self.viewNoDataFound.isHidden = true
            } else {
                self.viewNoDataFound.isHidden = false
            }
            
            self.hideLoader()
            
            
        } failure: { (error) in
            return true
        }
    }
    
    func callUnsubscribeToCoachAPI(selectedIndex: Int, id: String) {
        showLoader()
        let param = [ "coach_id" : id]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.UNSUBSCRIBE_TO_COACH, parameters: param, headers: nil) { responseObj in
            
            self.hideLoader()
            for (index, model) in self.arrSubsciptionList.enumerated() {
                if selectedIndex == index {
                    model.unsubscribe_status = true
                    self.arrSubsciptionList[index] = model
                    DispatchQueue.main.async {
                        self.tblManageSubscription.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                    break
                }
            }
            
        } failure: { (error) in
            self.hideLoader()
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
        getCoachSubscriptionList(isShowLoader: true)
    }

}
