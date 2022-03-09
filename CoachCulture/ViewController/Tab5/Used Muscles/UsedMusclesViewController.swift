//
//  UsedMusclesViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 07/12/21.
//

import UIKit

class UsedMusclesViewController: BaseViewController {
       
    //MARK: - OUTLET
    @IBOutlet weak var viewFrontBody: UIView!
    @IBOutlet weak var viewBackBody: UIView!
    @IBOutlet weak var btnImgBackLeftArm: UIButton!
    @IBOutlet weak var btnImgBackRightArm: UIButton!
    @IBOutlet weak var btnImgBackUpperBackLeft: UIButton!
    @IBOutlet weak var btnImgBackUpperBackRight: UIButton!
    @IBOutlet weak var btnImgBackLowerBackLeft: UIButton!
    @IBOutlet weak var btnImgBackLowerBackRight: UIButton!
    @IBOutlet weak var btnImgBackHarmstringsLeft: UIButton!
    @IBOutlet weak var btnImgBackHarmstringsRight: UIButton!
    @IBOutlet weak var btnImgBackCalfsLeft: UIButton!
    @IBOutlet weak var btnImgBackCalfsRight: UIButton!
    @IBOutlet weak var btnImgBackGlutesLeft: UIButton!
    @IBOutlet weak var btnImgBackGlutesRight: UIButton!
    @IBOutlet weak var clvMusclesType: UICollectionView!
        
    @IBOutlet weak var btnImgNeckLeft: UIButton!
    @IBOutlet weak var btnImgNeckRight: UIButton!
    @IBOutlet weak var btnChestLeft: UIButton!
    @IBOutlet weak var btnChestRight: UIButton!
    @IBOutlet weak var btnObliqueFrontLeft: UIButton!
    @IBOutlet weak var btnObliqueFrontRight: UIButton!
    @IBOutlet weak var btnObliqueBackLeft: UIButton!
    @IBOutlet weak var btnObliqueBackRight: UIButton!
    @IBOutlet weak var btnAbdominalsFrontLeft: UIButton!
    @IBOutlet weak var btnAbdominalsFrontRight: UIButton!
    @IBOutlet weak var btnShoulderBicepsForearmFrontLeft: UIButton!
    @IBOutlet weak var btnShoulderBicepsForearmFrontRight: UIButton!
    @IBOutlet weak var btnChestFrontLeft: UIButton!
    @IBOutlet weak var btnChestFrontRIght: UIButton!
    @IBOutlet weak var btnQuadricepsFrontLeft: UIButton!
    @IBOutlet weak var btnQuadricepsFrontRight: UIButton!
    @IBOutlet weak var btnCalfsFrontLeft: UIButton!
    @IBOutlet weak var btnCalfsFrontRight: UIButton!
    
    var paramDic = [String : Any]()
    static func viewcontroller() -> UsedMusclesViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "UsedMusclesViewController") as! UsedMusclesViewController
        return vc
    }
    
    var arrMuscleList = [MuscleList]()
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
        let tempArrMuscleList = arrMuscleList
        
        for (indexMain, temp) in arrMuscleList.enumerated() {
            for (_ , model) in classDetailDataObj.arrMuscleGroupList.enumerated() {
                if model.muscle_group_id == temp.id {
                    tempArrMuscleList[indexMain].isSelected = true
                    self.manageMusclesActivity(musclesModel: tempArrMuscleList[indexMain])
                    break
                }
            }
        }
        arrMuscleList = tempArrMuscleList
        self.clvMusclesType.reloadData()
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
            let vc = AddEquipmentAndCaloriesViewController.viewcontroller()
            vc.classDetailDataObj = self.classDetailDataObj
            vc.paramDic = paramDic
            vc.isFromEdit = self.isFromEdit
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension UsedMusclesViewController {
    func getMuscleGroupList() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.MUSCLE_GROUP_LIST, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()
                self.arrMuscleList = MuscleList.getData(data: dataObj)
                self.clvMusclesType.reloadData()
            }
            self.hideLoader()
            if self.isFromEdit {
                self.setData()
            }
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension UsedMusclesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
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
        self.manageMusclesActivity(musclesModel: obj)
        DispatchQueue.main.async {
            collectionView.reloadData()
        }
    }
    
    func manageMusclesActivity(musclesModel: MuscleList) {
        let muscleGroupName = musclesModel.muscle_group_name
        let isSelected = musclesModel.isSelected
        
        switch muscleGroupName {
        case MuscleGroupName.Neck:
            self.setNeckMuscles(isSelected: isSelected)
        case MuscleGroupName.Shoulder, MuscleGroupName.Biceps, MuscleGroupName.Forearm:
            self.setShoulderBicepsForearmMuscles()
        case MuscleGroupName.Chest:
            self.setChestMuscles(isSelected: isSelected)
        case MuscleGroupName.Abdominals:
            self.setAbdominalsMuscles(isSelected: isSelected)
        case MuscleGroupName.Oblique:
            self.setObliqueMuscles(isSelected: isSelected)
        case MuscleGroupName.Quadriceps:
            self.setQuadricepsMuscles(isSelected: isSelected)
        case MuscleGroupName.Calfs:
            self.setCalfsMuscles(isSelected: isSelected)
        case MuscleGroupName.UpperBack:
            self.setUpperBackMuscles(isSelected: isSelected)
        case MuscleGroupName.LowerBack:
            self.setLowerBackMuscles(isSelected: isSelected)
        case MuscleGroupName.Hamstrings:
            self.setHarmstringsMuscles(isSelected: isSelected)
        case MuscleGroupName.Glutes:
            self.setGlutesMuscles(isSelected: isSelected)
        default:
            break
        }
    }
    
    func setGlutesMuscles(isSelected: Bool) {
        btnImgBackGlutesLeft.setImage(UIImage(named: "ic_glutes_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackGlutesLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnImgBackGlutesRight.setImage(UIImage(named: "ic_glutes_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackGlutesRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setHarmstringsMuscles(isSelected: Bool) {
        btnImgBackHarmstringsLeft.setImage(UIImage(named: "ic_hamstrings_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackHarmstringsLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnImgBackHarmstringsRight.setImage(UIImage(named: "ic_hamstrings_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackHarmstringsRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setLowerBackMuscles(isSelected: Bool) {
        btnImgBackLowerBackLeft.setImage(UIImage(named: "ic_lower_back_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackLowerBackLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnImgBackLowerBackRight.setImage(UIImage(named: "ic_lower_back_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackLowerBackRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setUpperBackMuscles(isSelected: Bool) {
        btnImgBackUpperBackLeft.setImage(UIImage(named: "ic_upper_back_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackUpperBackLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnImgBackUpperBackRight.setImage(UIImage(named: "ic_upper_back_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackUpperBackRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setCalfsMuscles(isSelected: Bool) {
        btnCalfsFrontLeft.setImage(UIImage(named: "ic_calfs_front_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnCalfsFrontLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnCalfsFrontRight.setImage(UIImage(named: "ic_calfs_front_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnCalfsFrontRight.tintColor = isSelected ? COLORS.THEME_RED : .white
        
        btnImgBackCalfsLeft.setImage(UIImage(named: "ic_calfs_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackCalfsLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnImgBackCalfsRight.setImage(UIImage(named: "ic_calfs_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgBackCalfsRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setQuadricepsMuscles(isSelected: Bool) {
        btnQuadricepsFrontLeft.setImage(UIImage(named: "ic_quadriceps_front_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnQuadricepsFrontLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnQuadricepsFrontRight.setImage(UIImage(named: "ic_quadriceps_front_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnQuadricepsFrontRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setObliqueMuscles(isSelected: Bool) {
        btnObliqueBackLeft.setImage(UIImage(named: "ic_oblique__back_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnObliqueBackLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnObliqueBackRight.setImage(UIImage(named: "ic_oblique__back_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnObliqueBackRight.tintColor = isSelected ? COLORS.THEME_RED : .white

        btnObliqueFrontLeft.setImage(UIImage(named: "ic_oblique_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnObliqueFrontLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnObliqueFrontRight.setImage(UIImage(named: "ic_oblique_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnObliqueFrontRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setAbdominalsMuscles(isSelected: Bool) {
        btnAbdominalsFrontLeft.setImage(UIImage(named: "ic_abdominals_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnAbdominalsFrontLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnAbdominalsFrontRight.setImage(UIImage(named: "ic_abdominals_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnAbdominalsFrontRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setChestMuscles(isSelected: Bool) {
        btnChestFrontLeft.setImage(UIImage(named: "ic_chest_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnChestFrontLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnChestFrontRIght.setImage(UIImage(named: "ic_chest_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnChestFrontRIght.tintColor = isSelected ? COLORS.THEME_RED : .white
    }

    func setShoulderBicepsForearmMuscles() {
        let tempArrMuscleList = self.arrMuscleList.filter { (musclesModel) -> Bool in
            musclesModel.muscle_group_name == MuscleGroupName.Shoulder || musclesModel.muscle_group_name == MuscleGroupName.Biceps || musclesModel.muscle_group_name == MuscleGroupName.Forearm
        }
        
        var shoulderSelected = false
        var bicepsSelected = false
        var forearmSelected = false

        for (_, musclesModel) in tempArrMuscleList.enumerated() {
            
            if musclesModel.muscle_group_name == MuscleGroupName.Shoulder {
                shoulderSelected = musclesModel.isSelected
            }
            if musclesModel.muscle_group_name == MuscleGroupName.Biceps {
                bicepsSelected = musclesModel.isSelected
            }
            if musclesModel.muscle_group_name == MuscleGroupName.Forearm {
                forearmSelected = musclesModel.isSelected
            }
        }
        
        if shoulderSelected && bicepsSelected && forearmSelected {
            btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_biceps_forearm_selected_front_left"), for: .normal)
            btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_biceps_forearm_selected_front_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_forearm_bothselected"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_forearm_bothselected"), for: .normal)
        } else if forearmSelected && bicepsSelected {            
            self.btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_biceps_forearm_bothselected_front_left"), for: .normal)
            self.btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_biceps_forearm_bothselected_front_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_forearm_selectedonly"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_forearm_selectedonly"), for: .normal)
        } else if shoulderSelected && bicepsSelected {
            btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_biceps_bothselected_forearm_front_left"), for: .normal)
            btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_biceps_bothselected_forearm_front_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_selectedonly_forearm"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_selectedonly_forearm"), for: .normal)
        } else if shoulderSelected && forearmSelected {
            btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_forearm_bothselected_biceps_front_left"), for: .normal)
            btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_forearm_bothselected_biceps_front_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_forearm_bothselected"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_forearm_bothselected"), for: .normal)
        } else if shoulderSelected {
            btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_selectedonly_biceps_forearm_front_left"), for: .normal)
            btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_selectedonly_biceps_forearm_front_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_selectedonly_forearm"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_selectedonly_forearm"), for: .normal)
        } else if bicepsSelected {
            btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_biceps_selectedonly_forearm_front_left"), for: .normal)
            btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_biceps_selectedonly_forearm_front_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_forearm"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_forearm"), for: .normal)
        } else if forearmSelected {
            btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_biceps_forearm_selectedonly_front_left"), for: .normal)
            btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_biceps_forearm_selectedonly_front_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_forearm_selectedonly"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_forearm_selectedonly"), for: .normal)
        } else {
            btnShoulderBicepsForearmFrontLeft.setImage(UIImage(named: "ic_shoulder_biceps_forearm_front_left_group"), for: .normal)
            btnShoulderBicepsForearmFrontRight.setImage(UIImage(named: "ic_shoulder_biceps_forearm_front_left_right"), for: .normal)
            
            btnImgBackLeftArm.setImage(UIImage(named: "ic_back_left_shoulder_forearm"), for: .normal)
            btnImgBackRightArm.setImage(UIImage(named: "ic_back_right_shoulder_forearm"), for: .normal)
        }
        self.view.layoutIfNeeded()
    }

    func setNeckMuscles(isSelected: Bool) {
        btnImgNeckLeft.setImage(UIImage(named: "ic_neck_left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgNeckLeft.tintColor = isSelected ? COLORS.THEME_RED : .white
        btnImgNeckRight.setImage(UIImage(named: "ic_neck_right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnImgNeckRight.tintColor = isSelected ? COLORS.THEME_RED : .white
    }
}

struct MuscleGroupName {
    static let Neck = "Neck"
    static let Shoulder = "Shoulder"
    static let Chest = "Chest"
    static let Biceps = "Biceps"
    static let Forearm = "Forearm"
    static let Abdominals = "Abdominals"
    static let Oblique = "Oblique"
    static let UpperBack = "Upper Back"
    static let LowerBack = "Lower Back"
    static let Quadriceps = "Quadriceps"
    static let Hamstrings = "Hamstrings"
    static let Calfs = "Calfs"
    static let Glutes = "Glutes"
}

extension UIView {

    func asImage() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
            defer { UIGraphicsEndImageContext() }
            guard let currentContext = UIGraphicsGetCurrentContext() else {
                return nil
            }
            self.layer.render(in: currentContext)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
}
