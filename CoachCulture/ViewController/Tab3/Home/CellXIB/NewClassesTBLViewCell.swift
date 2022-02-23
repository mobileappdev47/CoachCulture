
import UIKit

class NewClassesTBLViewCell: UITableViewCell {

    //MARK:- OUTLET
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewClassType: UIView!
    @IBOutlet weak var lblClassType: UILabel!
    @IBOutlet weak var viewTime: UIView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewUserImage: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var viewUsername: UIView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var imgBookmark: UIImageView!
    @IBOutlet weak var imgBanner: UIImageView!
    @IBOutlet weak var imgBlurThumbnail: UIImageView!
    
    //MARK:- VARIABLE AND OBJECT
    
    var didTapBookmarkButton : (() -> Void)!
    var selectedIndex = 0

    //MARK:- CELL LIFE CYCLE
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK:- FUNCTION
    
    //MARK:- ACTION
    
    @IBAction func btnBookmarkClick(_ sender: Any) {
        if didTapBookmarkButton != nil {
            didTapBookmarkButton()
        }
    }
}
