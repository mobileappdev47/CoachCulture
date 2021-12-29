//
//  NationalityView.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 04/12/21.
//

import UIKit

class NationalityView: UIView {

    @IBOutlet weak var tblNationality: UITableView!
    @IBOutlet weak var lctTableNationalityHeight: NSLayoutConstraint!

    var arrNationalityData = [NationalityData]()
    var isFromCoachClass = false
    
    internal var handlerForBtnSelectNationality: ((NationalityData) -> Void)?
    
    public func tapToBtnSelectItem(_ handler: @escaping ( _ obj : NationalityData) -> Void)
    {
        self.handlerForBtnSelectNationality = nil
        self.handlerForBtnSelectNationality = handler
    }


    override func awakeFromNib() {
        
    }
    
    func setUpUI() {
        tblNationality.register(UINib(nibName: "NationalityTableViewCell", bundle: nil), forCellReuseIdentifier: "NationalityTableViewCell")
        tblNationality.delegate = self
        tblNationality.dataSource = self
        
        tblNationality.layoutIfNeeded()
        tblNationality.reloadData()
        lctTableNationalityHeight.constant = tblNationality.contentSize.height
    }

}

extension NationalityView : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNationalityData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NationalityTableViewCell", for: indexPath) as! NationalityTableViewCell
        let obj = arrNationalityData[indexPath.row]
        cell.lblName.text = obj.country_nationality
        if isFromCoachClass {
            cell.lblName.text = obj.currency + " " + obj.currency_symbol
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if handlerForBtnSelectNationality != nil
        {
            handlerForBtnSelectNationality!(arrNationalityData[indexPath.row])
            self.removeFromSuperview()
            
            
        }
    }
}
