//
//  UserMusclesForLiveClassViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 15/12/21.
//

import UIKit

class UserMusclesForLiveClassViewController: BaseViewController {

    static func viewcontroller() -> UserMusclesForLiveClassViewController {
        let vc = UIStoryboard(name: "Recipe", bundle: nil).instantiateViewController(withIdentifier: "UserMusclesForLiveClassViewController") as! UserMusclesForLiveClassViewController
        return vc
    }
    
    var arrMuscleList = [MuscleList]()
    
    @IBOutlet weak var clvMusclesType: UICollectionView!
    var paramDic = [String : Any]()
    var isFromEdit = false
    var classDetailDataObj = ClassDetailData()
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    func setUpUI() {
 
        clvMusclesType.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvMusclesType.delegate = self
        clvMusclesType.dataSource = self
        
        if Reachability.isConnectedToNetwork(){
            getMuscleGroupList()
        }
    }
    
    func setData() {
        
        for temp in arrMuscleList {
            let ind = classDetailDataObj.arrMuscleGroupList.firstIndex { obj in
                return obj.muscle_group_id == temp.id
            }
            
            if ind != nil {
                arrMuscleList[ind!].isSelected = true
            }
        }
    }
    
    
    
    //MARK: - Click Event
    @IBAction func clickToBtnUsedMuscles( _ sender: UIButton) {
        
    }
    
    @IBAction func clickToBtnNext( _ sender: UIButton) {
        var muscle_group = ""
        for temp in arrMuscleList {
            if temp.isSelected {
                if muscle_group.isEmpty {
                    muscle_group = temp.id
                } else {
                    muscle_group += "," + temp.id
                }
            }
        }
        
        if muscle_group.isEmpty {
            Utility.shared.showToast("Please select used muscles")
        } else {
            paramDic["muscle_group"] = muscle_group
            let vc = LiveClassAddEquipmentAndCaloriesViewController.viewcontroller()
            vc.paramDic = paramDic
            vc.isFromEdit = self.isFromEdit
            self.navigationController?.pushViewController(vc, animated: true)
        }
       
    }
    
    
}

extension UserMusclesForLiveClassViewController {
    func getMuscleGroupList() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.MUSCLE_GROUP_LIST, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()
                self.arrMuscleList = MuscleList.getData(data: dataObj)
                self.clvMusclesType.reloadData()
                
            }
            if self.isFromEdit {
                self.setData()
            }
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension UserMusclesForLiveClassViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        return arrMuscleList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MuscleItemCollectionViewCell", for: indexPath) as!  MuscleItemCollectionViewCell
        let obj  = arrMuscleList[indexPath.row]
        cell.lblTitle.text = obj.muscle_group_name
        if obj.isSelected {
            cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#526070")
        } else {
            cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        }
        //cell.setData(obj: arrPopularTrainerList[indexPath.row])
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width =  (clvMusclesType.frame.width - 40 ) / 3
        
        return CGSize(width: width, height: 40)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let obj  = arrMuscleList[indexPath.row]
        obj.isSelected = !obj.isSelected
        collectionView.reloadData()
    }
}

