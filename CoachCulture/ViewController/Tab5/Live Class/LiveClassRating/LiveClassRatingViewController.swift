//
//  LiveClassRatingViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 17/12/21.
//

import UIKit
import HCSStarRatingView
import KMPlaceholderTextView

class LiveClassRatingViewController: BaseViewController {
    
    static func viewcontroller() -> LiveClassRatingViewController {
        let vc = UIStoryboard(name: "Recipe", bundle: nil).instantiateViewController(withIdentifier: "LiveClassRatingViewController") as! LiveClassRatingViewController
        return vc
    }
    
    @IBOutlet weak var lblClassTypeLiveOndemand: UILabel!
    @IBOutlet weak var lblClassType: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblClassTitle: UILabel!
    @IBOutlet weak var lblClassSubTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblCharCount: UILabel!

    @IBOutlet weak var viwClassType: UIView!

    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var imgClassCover: UIImageView!
    @IBOutlet weak var imgThumbNail: UIImageView!
    
    @IBOutlet weak var viwRating: HCSStarRatingView!
    
    @IBOutlet weak var txtTellUsAbout: KMPlaceholderTextView!

    var selectedId = ""
    var classDetailDataObj = ClassDetailData()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    private func setUpUI() {
        txtTellUsAbout.delegate = self
        getClassDetails()
    }
    
    func setData() {
        imgClassCover.setImageFromURL(imgUrl: classDetailDataObj.thumbnail_image, placeholderImage: nil)
        lblClassType.text = classDetailDataObj.class_difficulty
        lblDuration.text = classDetailDataObj.duration
        lblClassTitle.text = classDetailDataObj.class_type
        lblClassSubTitle.text = classDetailDataObj.class_subtitle
       
        lblUserName.text = "@" + classDetailDataObj.coachDetailsDataObj.username
        imgUserProfile.setImageFromURL(imgUrl: classDetailDataObj.thumbnail_image, placeholderImage: nil)
        imgThumbNail.setImageFromURL(imgUrl: classDetailDataObj.coachDetailsDataObj.user_image, placeholderImage: nil)
        imgThumbNail.blurImage()
        
        if classDetailDataObj.coach_class_type == CoachClassType.live {
            lblClassTypeLiveOndemand.text = "LIVE"
            viwClassType.backgroundColor = hexStringToUIColor(hex: "#CC2936")
            
            lblDate.text = classDetailDataObj.class_date
            lblTime.text = classDetailDataObj.class_time
        } else {
            lblClassTypeLiveOndemand.text = "ON DEMAND"
            viwClassType.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
            
            lblDate.text = classDetailDataObj.total_viewers + " views"
            lblTime.text = classDetailDataObj.created_atForamted
        }
        
        txtTellUsAbout.text = classDetailDataObj.user_class_comments
        lblCharCount.text = "\(txtTellUsAbout.text!.count)" + "/300"
        
        if !classDetailDataObj.user_class_rating.isEmpty {
            viwRating.value = CGFloat(Double(classDetailDataObj.user_class_rating)!)
        }
    }

    // MARK: - Click events
    @IBAction func clickToBtnNext(_ sender : UIButton) {
        giveRatting()
    }

}


// MARK: - UITextViewDelegate
extension LiveClassRatingViewController : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let finalString = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        if finalString.count < 300 {
                      
            lblCharCount.text = "\(finalString.count)" + "/300"
            return true
        } else {
            return false
        }
    }
    
}


// MARK: - API CALL
extension LiveClassRatingViewController {
    func giveRatting() {
        showLoader()
        let param = ["coach_class_id" : self.classDetailDataObj.id,
                     "rating" : "\(Int(Double(self.viwRating.value)))",
                     "comments" : self.txtTellUsAbout.text!]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.COACH_CLASS_RATING, parameters: param, headers: nil) { responseObj in
            
          
            let responseModel = ResponseDataModel(responseObj: responseObj)
            Utility.shared.showToast(responseModel.message)
            self.navigationController?.popViewController(animated: true)
            
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    func getClassDetails() {
        showLoader()
        let param = ["id" : selectedId]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.COACH_CLASS_DETAILS, parameters: param, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_class"] as? [String:Any] ?? [String:Any]()
            self.classDetailDataObj = ClassDetailData(responseObj: dataObj)
            self.setData()
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
  
}
