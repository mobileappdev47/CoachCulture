//
//  AddIngredientsForRecipeViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 10/12/21.
//

import UIKit
import iOSDropDown

class AddIngredientsForRecipeViewController: BaseViewController {
    
    static func viewcontroller() -> AddIngredientsForRecipeViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "AddIngredientsForRecipeViewController") as! AddIngredientsForRecipeViewController
        return vc
    }
    
    @IBOutlet weak var clvDietaryRestriction: UICollectionView!
    
    @IBOutlet weak var lctvDietaryRestrictionHeight: NSLayoutConstraint!
    @IBOutlet weak var lctIntredientTableHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tblIntredienta: UITableView!
    
    var arrDietaryRestrictionListData = [DietaryRestrictionListData]()
    var arrAddIngredientsListData = [AddIngredients]()
    var paramDic = [String:Any]()
    
     var dropDown = DropDown()
    var recipeDetailDataObj = RecipeDetailData()
    var isFromEdit = false
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    // MARK: - Methods
    func setUpUI() {
        
        dropDown.dataSource  = ["Option 1", "Option 2", "Option 3"]
        
       
        
        clvDietaryRestriction.register(UINib(nibName: "MuscleItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MuscleItemCollectionViewCell")
        clvDietaryRestriction.delegate = self
        clvDietaryRestriction.dataSource = self
        
        tblIntredienta.register(UINib(nibName: "AddIngredientIemTableViewCell", bundle: nil), forCellReuseIdentifier: "AddIngredientIemTableViewCell")
        tblIntredienta.delegate = self
        tblIntredienta.dataSource = self
        tblIntredienta.layoutIfNeeded()
        tblIntredienta.reloadData()
        lctIntredientTableHeight.constant = tblIntredienta.contentSize.height
        
        //AddIngredientIemTableViewCell
        
        getDietaryList()
    }
    
    func setData() {
        
        for temp in recipeDetailDataObj.arrDietaryRestrictionListData {
            let ind = arrDietaryRestrictionListData.firstIndex { obj in
                return obj.id == temp.dietary_restriction_id
            }
            
            if ind != nil {
                arrDietaryRestrictionListData[ind!].isSelected = !arrDietaryRestrictionListData[ind!].isSelected
            }
        }
        
        clvDietaryRestriction.reloadData()
        
        for temp in recipeDetailDataObj.arrQtyIngredient {
            let str = temp.quantity.split{ !$0.isLetter }
            let obj = AddIngredients()
            obj.addIngredients = temp.ingredients
            obj.unit = String(str.first!)
            
            
            let arrQty = temp.quantity.components(separatedBy: obj.unit)
            obj.qty = arrQty.first!
            arrAddIngredientsListData.append(obj)
        }
        
        tblIntredienta.layoutIfNeeded()
        tblIntredienta.reloadData()
        lctIntredientTableHeight.constant = tblIntredienta.contentSize.height
    }
    
    // MARK: - Click events
    @IBAction func clickToBtnDeleteIngreint(_ sender : UIButton) {
        arrAddIngredientsListData.remove(at: sender.tag)
        tblIntredienta.layoutIfNeeded()
        tblIntredienta.reloadData()
        lctIntredientTableHeight.constant = tblIntredienta.contentSize.height
    }
    
    @IBAction func clickToBtnSelectUnit(_ sender : UIButton) {
        dropDown.show()
    }
    
    @IBAction func clickToBtnAddIngredient(_ sender : UIButton) {
        let obj = AddIngredients()
        arrAddIngredientsListData.append(obj)
        
        tblIntredienta.layoutIfNeeded()
        tblIntredienta.reloadData()
        lctIntredientTableHeight.constant = tblIntredienta.contentSize.height
    }
    
    @IBAction func clickToBtnSave(_ sender : UIButton) {
        var dietary_restriction = ""
        for temp in arrDietaryRestrictionListData {
            if temp.isSelected {
                if dietary_restriction.isEmpty {
                    dietary_restriction = temp.id
                } else {
                    dietary_restriction += "," + temp.id
                }
            }
        }
                        
        var qty_ingredient = [Any]()
        
        for temp in arrAddIngredientsListData {
            var param = [String:String]()
            param["ingredients"] = temp.addIngredients
            param["quantity"] = temp.qty + temp.unit
            qty_ingredient.append(param)
        }
        
        if dietary_restriction.isEmpty {
            Utility.shared.showToast("Please select dietary restriction")
        } else  if qty_ingredient.isEmpty {
            Utility.shared.showToast("Please select ingredient")
        }
        
        paramDic["dietary_restriction"] = dietary_restriction
        paramDic["qty_ingredient"] = jsonStringFromDictionaryOrArrayObject(obj: qty_ingredient)
        
        createRecipe()

    }
    
}



// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension AddIngredientsForRecipeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        return arrDietaryRestrictionListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "MuscleItemCollectionViewCell", for: indexPath) as!  MuscleItemCollectionViewCell
        let obj  = arrDietaryRestrictionListData[indexPath.row]
        cell.lblTitle.text = obj.dietary_restriction_name
        
        if obj.isSelected {
            cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#526070")
        } else {
            cell.viwContainer.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width =  (clvDietaryRestriction.frame.width - 40 ) / 3
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        arrDietaryRestrictionListData[indexPath.row].isSelected = !arrDietaryRestrictionListData[indexPath.row].isSelected
        collectionView.reloadData()
    }
    
    
}


// MARK: - API CALL
extension AddIngredientsForRecipeViewController {
    func getDietaryList() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.DIETARY_RES_LIST, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()
                self.arrDietaryRestrictionListData = DietaryRestrictionListData.getData(data: dataObj)
                self.clvDietaryRestriction.reloadData()
                self.lctvDietaryRestrictionHeight.constant = self.clvDietaryRestriction.collectionViewLayout.collectionViewContentSize.height
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

    
    func createRecipe() {
        showLoader()
        
        var url = API.CREATE_RECIPE
        if self.isFromEdit {
            url = API.EDIT_RECIPE
            
            paramDic["id"] = self.recipeDetailDataObj.id
        }
        _ =  ApiCallManager.requestApi(method: .post, urlString: url, parameters: paramDic, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                _ = responseObj["data"] as? [Any] ?? [Any]()
            }
            let vc = RecipeDetailsViewController.viewcontroller()
            vc.isNew = true
            let dic = responseModel.map.data?["coach_recipe"] as! [String:Any]
            vc.recipeID = "\(dic["recipe_id"] as! Int)"
            self.navigationController?.pushViewController(vc, animated: true)
            Utility.shared.showToast(responseModel.message)
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }

}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension AddIngredientsForRecipeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrAddIngredientsListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddIngredientIemTableViewCell", for: indexPath) as! AddIngredientIemTableViewCell
        let obj = arrAddIngredientsListData[indexPath.row]
        if isFromEdit {
            cell.lblUnit.text = obj.unit
            cell.txtQty.text = obj.qty
            cell.txtIngredient.text = obj.addIngredients
        }
        cell.lblUnit.tag = indexPath.row
        cell.txtIngredient.tag = indexPath.row
        cell.txtQty.tag = indexPath.row

        cell.dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            let obj = arrAddIngredientsListData[cell.lblUnit.tag]
            obj.unit = item
            cell.lblUnit.text = item
        }
        cell.txtQty.delegate = self
        cell.txtIngredient.delegate = self
        
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(self.clickToBtnDeleteIngreint(_:)), for: .touchUpInside)
        
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

//MARK: - UITextFieldDelegate
extension AddIngredientsForRecipeViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let finalString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        let cell = tblIntredienta.cellForRow(at: IndexPath(row: textField.tag, section: 0)) as! AddIngredientIemTableViewCell
        let obj = arrAddIngredientsListData[textField.tag]
        
        if textField ==  cell.txtIngredient {
            obj.addIngredients = finalString
        }
        
        if textField ==  cell.txtQty {
            obj.qty = finalString
        }
                
        return true
    }
    
}




