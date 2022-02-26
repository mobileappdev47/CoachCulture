//
//  CreateMealRecipeViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 10/12/21.
//

import UIKit

import MobileCoreServices


class CreateMealRecipeViewController: BaseViewController {
    
    static func viewcontroller() -> CreateMealRecipeViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "CreateMealRecipeViewController") as! CreateMealRecipeViewController
        return vc
    }
    
    @IBOutlet weak var imgThumbnail : UIImageView!
    
    @IBOutlet weak var txtRecipeSubTitile : UITextField!
    @IBOutlet weak var txtRecipeTitile : UITextField!
    
    @IBOutlet weak var lblRecipeDuration : UILabel!
    
    @IBOutlet weak var clvMealType: UICollectionView!
    
    @IBOutlet weak var tblAddStepOfRecipe: UITableView!
    
    @IBOutlet weak var lctAddStepOfRecipeTableHeight: NSLayoutConstraint!
    
    var addPhotoPopUp:AddPhotoPopUp!
    var photoData:Data!
    var classDuration : ClassDuration!
    var arrMealTypeListData = [MealTypeListData]()
    var arrAddStepOfRecipe = [AddStepOfRecipe]()
    var thumbnailImage = ""
    var recipeDetailDataObj = RecipeDetailData()
    var isFromEdit = false
    var isFromTemplate = false
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    // MARK: - Methods
    func setUpUI() {
        
        getMealTypeList()
        
        addPhotoPopUp = Bundle.main.loadNibNamed("AddPhotoPopUp", owner: nil, options: nil)?.first as? AddPhotoPopUp
        addPhotoPopUp.tapToBtnCamera {
            self.loadCameraView()
            self.removeAddPhotoView()
        }
        
        addPhotoPopUp.tapToBtnView {
            self.removeAddPhotoView()
        }
        
        addPhotoPopUp.tapToBtnGallery {
            self.loadPhotoGalleryView()
            self.removeAddPhotoView()
        }
        
        classDuration = Bundle.main.loadNibNamed("ClassDuration", owner: nil, options: nil)?.first as? ClassDuration
        classDuration.tapToBtnSelectItem { obj in
            self.lblRecipeDuration.text = obj + " mins"
        }
                
        tblAddStepOfRecipe.register(UINib(nibName: "AddStepOfRecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "AddStepOfRecipeTableViewCell")
        tblAddStepOfRecipe.delegate = self
        tblAddStepOfRecipe.dataSource = self
        tblAddStepOfRecipe.layoutIfNeeded()
        tblAddStepOfRecipe.reloadData()
        lctAddStepOfRecipeTableHeight.constant = tblAddStepOfRecipe.contentSize.height
        
        clvMealType.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvMealType.delegate = self
        clvMealType.dataSource = self
        
        if !isFromEdit {
            clickToBtnAddSteps(UIButton())
        }
        
    }
    
    func setData() {
        imgThumbnail.setImageFromURL(imgUrl: recipeDetailDataObj.thumbnail_image, placeholderImage: nil)
        thumbnailImage = recipeDetailDataObj.thumbnail_image
        txtRecipeTitile.text = recipeDetailDataObj.title
        txtRecipeSubTitile.text = recipeDetailDataObj.sub_title
        lblRecipeDuration.text = recipeDetailDataObj.duration
                
        for temp in recipeDetailDataObj.arrMealType {
            let ind = arrMealTypeListData.firstIndex { obj in
                return obj.id == temp.meal_type_id
            }
            
            if ind != nil {
                arrMealTypeListData[ind!].isSelected = !arrMealTypeListData[ind!].isSelected
            }
        }
        
        
        for temp in  recipeDetailDataObj.arrRecipeSteps {
            
            let str = temp.value as? String ?? ""
            let obj = AddStepOfRecipe()
            obj.description = str
            arrAddStepOfRecipe.append(obj)
        }
        
        clvMealType.reloadData()
        tblAddStepOfRecipe.layoutIfNeeded()
        tblAddStepOfRecipe.reloadData()
        lctAddStepOfRecipeTableHeight.constant = CGFloat(arrAddStepOfRecipe.count * 100)
    }
    
    func setAddPhotoView(){
        addPhotoPopUp.frame.size = self.view.frame.size
        self.view.addSubview(addPhotoPopUp)
    }
    
    func removeAddPhotoView(){
        if addPhotoPopUp != nil{
            addPhotoPopUp.removeFromSuperview()
        }
    }
    
    func setClassDurationView(){
        classDuration.frame.size = self.view.frame.size
        self.view.addSubview(classDuration)
    }
    
    func removeClassDurationView(){
        if classDuration != nil{
            classDuration.removeFromSuperview()
        }
        
    }
    
    
    //MARK: - Click EVENTS
    
    @IBAction func clickToBtnUplaodThumbnail(_ sender : UIButton) {
        setAddPhotoView()
        
    }
    
    @IBAction func clickToBtnRecipeDuration(_ sender : UIButton) {
        setClassDurationView()
    }
    
    @IBAction func clickToBtnDeleteRecipeStep(_ sender : UIButton) {
        arrAddStepOfRecipe.remove(at: sender.tag)
        tblAddStepOfRecipe.layoutIfNeeded()
        tblAddStepOfRecipe.reloadData()
        lctAddStepOfRecipeTableHeight.constant = CGFloat(arrAddStepOfRecipe.count * 100)
    }
    
    @IBAction func clickToBtnAddSteps(_ sender : UIButton) {
        let obj = AddStepOfRecipe()
        arrAddStepOfRecipe.append(obj)
        
        tblAddStepOfRecipe.layoutIfNeeded()
        tblAddStepOfRecipe.reloadData()
        lctAddStepOfRecipeTableHeight.constant = CGFloat(arrAddStepOfRecipe.count * 100)
    }
    
    @IBAction func clickToBtnNext(_ sender : UIButton) {
        view.endEditing(true)
        
        var meal_type = ""
        for temp in arrMealTypeListData {
            if temp.isSelected {
                if meal_type.isEmpty {
                    meal_type = temp.id
                } else {
                    meal_type += "," + temp.id
                }
            }
        }
        var isDescriptionAdded = true
        var dicObj = [String:String]()
        for (i,temp) in arrAddStepOfRecipe.enumerated() {
            if temp.description.isEmpty {
                isDescriptionAdded = false
            }
            dicObj["\(i + 1)"] = temp.description
        }
        
        if thumbnailImage.isEmpty {
            Utility.shared.showToast("Please select thumbnail Image")
        } else if txtRecipeTitile.text!.isEmpty {
            Utility.shared.showToast("Recipe title is mandatory field")
        } else if txtRecipeSubTitile.text!.isEmpty {
            Utility.shared.showToast("Recipe sub title is mandatory field")
        } else if lblRecipeDuration.text!.lowercased() == "0 mins".lowercased() {
            Utility.shared.showToast("Please select recipe preparation time duration")
        } else if meal_type.isEmpty {
            Utility.shared.showToast("Please select at least one meal type")
        } else if isDescriptionAdded == false {
            Utility.shared.showToast("Please enter recipe's step details")
        }else {
            
            let xvcx = jsonStringFromDictionaryOrArrayObject(obj: dicObj)
            
            var paramDic = [String:Any]()
            paramDic["thumbnail_image"] = thumbnailImage
            paramDic["title"] = txtRecipeTitile.text!
            paramDic["sub_title"] = txtRecipeSubTitile.text!
            paramDic["duration"] = lblRecipeDuration.text!
            paramDic["recipe_step"] = xvcx
            paramDic["meal_type"] = meal_type
            
            let vc = AddIngredientsForRecipeViewController.viewcontroller()
            vc.paramDic = paramDic
            vc.isFromEdit = isFromEdit
            vc.isFromTemplate = isFromTemplate
            vc.recipeDetailDataObj = self.recipeDetailDataObj
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
}


// MARK: - UIImagePickerControllerDelegate and Take a Photo or Choose from Gallery Methods
extension CreateMealRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        var editedImage:UIImage!
        
        editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if editedImage == nil {
            editedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        
        if editedImage.getSizeIn(.megabyte, recdData: self.photoData ?? Data()) > 5.0 {
            photoData = editedImage.jpegData(compressionQuality: 0.5)
        } else {
            photoData = editedImage.jpegData(compressionQuality: 1.0)
        }
        
        self.imgThumbnail.image = editedImage
        self.uploadRecipePhoto()
        
    }
    
    func loadCameraView() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.navigationBar.tintColor =  #colorLiteral(red: 0.2352941176, green: 0.5098039216, blue: 0.6666666667, alpha: 1)
            imagePickerController.sourceType = .camera
            imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            imagePickerController.showsCameraControls = true
            present(imagePickerController, animated: true, completion: nil)
        } else {
            
        }
    }
    
    func loadPhotoGalleryView() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            imagePickerController.allowsEditing = false
            imagePickerController.delegate = self
            
            
            present(imagePickerController, animated: true, completion: nil)
        } else {
            
        }
    }
}

// MARK: - API CALL
extension CreateMealRecipeViewController {
    func getMealTypeList() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.MEAL_TYPE_LIST, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()
                self.arrMealTypeListData = MealTypeListData.getData(data: dataObj)
                self.clvMealType.reloadData()
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
    
    
    
    func uploadRecipePhoto() {
        showLoader()
        
        var finalDataParameters = [AnyObject]()
        
        if photoData != nil {
            var imageDic = [String:AnyObject]()
            
            imageDic["file_data"] = photoData as AnyObject?
            imageDic["param_name"] =  "thumbnail_image" as AnyObject?
            imageDic["file_name"] = "image.jpeg" as AnyObject?
            imageDic["mime_type"] = "image" as AnyObject?
            
            finalDataParameters.append(imageDic as AnyObject)
        }
        
        ApiCallManager.callApiWithUpload(apiURL: API.UPLOAD_IMAGE_RECIPE, method: .post, parameters: nil, fileParameters: finalDataParameters, headers: nil, success: { (responseObj, code) in
            let resObj = responseObj as? [String:Any] ?? [String:Any]()
            
            let responseModel = ResponseDataModel(responseObj: resObj)
            
            let dataObj = resObj["data"] as? [String:Any] ?? [String:Any]()
            self.thumbnailImage = dataObj["file_path"] as? String ?? ""
            
            Utility.shared.showToast(responseModel.message)
            self.hideLoader()
        }, failure: { error, code in
            self.hideLoader()
            return true
        })
        
    }
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension CreateMealRecipeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        return arrMealTypeListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MuscleItemCollectionViewCell", for: indexPath) as!  MuscleItemCollectionViewCell
        let obj  = arrMealTypeListData[indexPath.row]
        cell.lblTitle.text = obj.meal_type_name
        
        if obj.isSelected {
            cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#526070")
        } else {
            cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width =  (clvMealType.frame.width - 40 ) / 3
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        arrMealTypeListData[indexPath.row].isSelected = !arrMealTypeListData[indexPath.row].isSelected
        collectionView.reloadData()
    }
    
    
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension CreateMealRecipeViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrAddStepOfRecipe.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddStepOfRecipeTableViewCell", for: indexPath) as! AddStepOfRecipeTableViewCell
        let obj = arrAddStepOfRecipe[indexPath.row]
        cell.txtAddStepRecipe.text = obj.description
        cell.txtAddStepRecipe.tag = indexPath.row
        cell.txtAddStepRecipe.delegate = self
        
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(self.clickToBtnDeleteRecipeStep(_:)), for: .touchUpInside)
        
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


extension CreateMealRecipeViewController : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let finalString = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        if finalString.count < 2000 {
            let obj = arrAddStepOfRecipe[textView.tag]
            obj.description = finalString
            
            let cell = tblAddStepOfRecipe.cellForRow(at: IndexPath(row: textView.tag, section: 0)) as! AddStepOfRecipeTableViewCell
            cell.lblCharCount.text = "\(finalString.count)" + "/2000"
        }
        
        return true
    }
    
}
