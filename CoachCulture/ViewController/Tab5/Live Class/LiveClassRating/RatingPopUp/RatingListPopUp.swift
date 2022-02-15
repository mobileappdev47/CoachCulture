//
//  RatingListPopUp.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 21/12/21.
//

import UIKit

class RatingListPopUp: UIView {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblRateValue: UILabel!
    
    @IBOutlet weak var tblReview: UITableView!
    @IBOutlet weak var lctReviewTableHeight: NSLayoutConstraint!

    var arrClassRatingList = [ClassRatingList]()
    
    internal var handlerForBtnOk: (() -> Void)?


    
    public func tapToBtnOk(_ handler: @escaping () -> Void)
    {
        self.handlerForBtnOk = nil
    }
   
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    func setUpUI() {
        
        tblReview.register(UINib(nibName: "UserReviewItemTableViewCell", bundle: nil), forCellReuseIdentifier: "UserReviewItemTableViewCell")
        tblReview.delegate = self
        tblReview.dataSource = self
       
    }
    
    func reloadTable() {
        tblReview.layoutIfNeeded()
        tblReview.reloadData()
        tblReview.layoutIfNeeded()
        lctReviewTableHeight.constant = tblReview.contentSize.height
    }
    
    func setData(title : String,SubTitle : String,rateValue : String) {
        lblTitle.text = title
        lblSubTitle.text = SubTitle
        lblRateValue.text = "\(round(Double(rateValue) ?? 0.0 * 10) / 10.0)"

    }
    
    @IBAction func clickToBtnOK( _ sender : UIButton) {
        self.removeFromSuperview()
    }
}



// MARK: - UITableViewDelegate, UITableViewDataSource
extension RatingListPopUp : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrClassRatingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserReviewItemTableViewCell", for: indexPath) as! UserReviewItemTableViewCell
        let obj = arrClassRatingList[indexPath.row]
        cell.lbluserName.text = obj.userDataObj.username
        cell.lblReviewDes.text = obj.comments
        cell.viwRating.value = CGFloat(Double(obj.rating)!)
        cell.lblDate.text = obj.created_atFormated
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
