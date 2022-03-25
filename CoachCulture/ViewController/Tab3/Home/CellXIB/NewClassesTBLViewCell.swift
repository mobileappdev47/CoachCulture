
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
    @IBOutlet weak var btnUser: UIButton!
    @IBOutlet weak var clvDietaryRestriction: UICollectionView!

    //MARK:- VARIABLE AND OBJECT
    
    var didTapBookmarkButton : (() -> Void)!
    var selectedIndex = 0
    var arrDietaryRestriction = [String]()

    //MARK:- CELL LIFE CYCLE
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initialSetupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    //MARK:- FUNCTION
    
    func initialSetupUI() {
        clvDietaryRestriction.register(UINib(nibName: "RecipeDietartyItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RecipeDietartyItemCollectionViewCell")
        clvDietaryRestriction.delegate = self
        clvDietaryRestriction.dataSource = self
        clvDietaryRestriction.collectionViewLayout = TagsLayout()
    }
    
    //MARK:- ACTION
    
    @IBAction func btnBookmarkClick(_ sender: Any) {
        if didTapBookmarkButton != nil {
            didTapBookmarkButton()
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension NewClassesTBLViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return arrDietaryRestriction.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeDietartyItemCollectionViewCell", for: indexPath) as!  RecipeDietartyItemCollectionViewCell
        cell.lblTitle.text = arrDietaryRestriction[indexPath.row]
        cell.lblTitle.textColor = UIColor.white
        cell.lblTitle.sizeToFit()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: 20)
    }
    
}
