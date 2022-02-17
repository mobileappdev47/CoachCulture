//
//  HomeViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 02/12/21.
//

import UIKit
import SDWebImage


class HomeViewController: BaseViewController {
    
    static func viewcontroller() -> HomeViewController {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        return vc
    }
    
    static func viewcontrollerNav() -> UINavigationController {
        let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeViewNavVc") as! UINavigationController
        return vc
    }
    
    @IBOutlet weak var lblPopularTitle : UILabel!
    @IBOutlet weak var lblNavTitle : UILabel!
    @IBOutlet weak var lblPopularClassesTitle : UILabel!
    @IBOutlet weak var lblCoachClassType : UILabel!
    @IBOutlet weak var lblDuration : UILabel!
    @IBOutlet weak var lblUserName : UILabel!
    @IBOutlet weak var lblClassDate : UILabel!
    @IBOutlet weak var lblClassTime : UILabel!
        
    @IBOutlet weak var btnClassbookMark : UIButton!
    
    @IBOutlet weak var imgUser : UIImageView!
    
    
    @IBOutlet weak var clvPopularTrainer : UICollectionView!
    @IBOutlet weak var clvPopularClasses : UICollectionView!
    
    var upCommingLiveClassObj = UpCommingLiveClass()
    var arrPopularClassList = [PopularClassList]()
    var arrPopularTrainerList = [PopularTrainerList]()

    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showTabBar()
    }
    
    // MARK: - Methods
    func setUpUI() {
        clvPopularTrainer.register(UINib(nibName: "PopularTrainerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PopularTrainerCollectionViewCell")
        clvPopularTrainer.delegate = self
        clvPopularTrainer.dataSource = self
        
        clvPopularClasses.register(UINib(nibName: "PopularClassesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PopularClassesCollectionViewCell")
        clvPopularClasses.delegate = self
        clvPopularClasses.dataSource = self
        
        if Reachability.isConnectedToNetwork(){
            getUpComingLiveClass()
            getPopularTrainerList()
            getPopularClassList()
        }
    }
    
    func setData() {
        lblDuration.text = upCommingLiveClassObj.duration
        lblCoachClassType.text = upCommingLiveClassObj.coach_class_type
        imgUser.setImageFromURL(imgUrl: upCommingLiveClassObj.user_image, placeholderImage: nil)
        lblClassDate.text = upCommingLiveClassObj.classDateFormated
        lblClassTime.text = upCommingLiveClassObj.classTimeFormated
    }
    
    //MARK: - ACTION
    
    @IBAction func clickToBtnSearch( _ sender : UIButton) {
        let vc = SearchFollowersViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if collectionView == clvPopularClasses {
            return arrPopularClassList.count
        }
        return arrPopularTrainerList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == clvPopularClasses {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularClassesCollectionViewCell", for: indexPath) as!  PopularClassesCollectionViewCell
            cell.setData(obj: arrPopularClassList[indexPath.row])
            
            return cell
        } else {
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularTrainerCollectionViewCell", for: indexPath) as!  PopularTrainerCollectionViewCell
            cell.setData(obj: arrPopularTrainerList[indexPath.row])

            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == clvPopularClasses {
            return CGSize(width: 130, height: 190)
        } else {
            return CGSize(width: 110, height: 165)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == clvPopularClasses {
            let vc = LiveClassDetailsViewController.viewcontroller()
            vc.selectedId = arrPopularClassList[indexPath.row].coach_class_id
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = CoachViseOnDemandClassViewController.viewcontroller()
            vc.selectedCoachId = arrPopularTrainerList[indexPath.row].coach_id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}



//MARK: - API call

extension HomeViewController {
    func getUpComingLiveClass() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_UPCOMMING_LIVE_CLASS_LIST, parameters: nil, headers: nil) { responseObj in
            
            let dataObj = responseObj["upcoming_live_class"] as? [String:Any] ?? [String:Any]()
            self.upCommingLiveClassObj = UpCommingLiveClass(responseObj: dataObj)
            self.setData()
            self.hideLoader()
            
        } failure: { (error) in
            return true
        }
    }
    
    func getPopularClassList() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_POPULAR_CLASS_LIST, parameters: nil, headers: nil) { responseObj in
            
            let dataObj = responseObj["popular_class_list"] as? [Any] ?? [Any]()
            self.arrPopularClassList =  PopularClassList.getData(data: dataObj)
            self.clvPopularClasses.reloadData()
            self.hideLoader()
            
        } failure: { (error) in
            return true
        }
    }
    
    func getPopularTrainerList() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.GET_POPULAR_TRAINER_LIST, parameters: nil, headers: nil) { responseObj in
            
            let dataObj = responseObj["coach_list"] as? [Any] ?? [Any]()
            self.arrPopularTrainerList =  PopularTrainerList.getData(data: dataObj)
            self.clvPopularTrainer.reloadData()
            self.hideLoader()
            
        } failure: { (error) in
            return true
        }
    }
}
