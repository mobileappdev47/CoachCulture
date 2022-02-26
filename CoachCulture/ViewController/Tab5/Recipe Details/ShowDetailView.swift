//
//  ShowDetailVIewViewController.swift
//  CoachCulture
//
//  Created by Brainbinary Infotech on 25/02/22.
//

import UIKit

class ShowDetailView: UIView {

    @IBOutlet weak var viwDetailTop: UIView!
    
    @IBOutlet weak var viwDetailBtm: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tblRecipeIngrediment: UITableView!
    @IBOutlet weak var tblDescriptionDetail: UITableView!
    
    @IBOutlet weak var hightRecipeIngTbl: NSLayoutConstraint!
    @IBOutlet weak var heightDescriptionDetailTbl: NSLayoutConstraint!
    @IBOutlet weak var hightMainView: NSLayoutConstraint!
    @IBOutlet weak var hightScrollVew: NSLayoutConstraint!
    @IBOutlet weak var hightBottomView: NSLayoutConstraint!
    @IBOutlet weak var hightTopView: NSLayoutConstraint!
    
    internal var handlerForBtnOk: (() -> Void)?
    var recipeDetailDataObj = RecipeDetailData()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    public func tapToBtnOk(_ handler: @escaping () -> Void)
    {
        self.handlerForBtnOk = nil
    }
    
    @IBAction func clickBtnOk(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    func setData(title : String,SubTitle : String,Data : RecipeDetailData) {
        lblTitle.text = title
        lblSubTitle.text = SubTitle
        recipeDetailDataObj = Data
    }
    
    func setUpUI() {
        tblRecipeIngrediment.register(UINib(nibName: "RecipeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeIngredientTableViewCell")
        tblRecipeIngrediment.delegate = self
        tblRecipeIngrediment.dataSource = self
        
        tblDescriptionDetail.register(UINib(nibName: "RecipeTestCellTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeTestCellTableViewCell")
        tblDescriptionDetail.delegate = self
        tblDescriptionDetail.dataSource = self
        hightScrollVew.constant = hightTopView.constant
        hightMainView.constant = (hightScrollVew.constant + hightBottomView.constant)
    }
}

extension ShowDetailView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblRecipeIngrediment {
            return recipeDetailDataObj.arrQtyIngredient.count
        } else {
            return recipeDetailDataObj.arrRecipeSteps.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblRecipeIngrediment {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeIngredientTableViewCell") as! RecipeIngredientTableViewCell
            let obj = recipeDetailDataObj.arrQtyIngredient[indexPath.row]
            cell.lblQty.text = obj.quantity
            cell.lblIngredient.text = obj.ingredients
            cell.lblQty.font = UIFont(name: "SFProText-Bold", size: 13)
            cell.lblIngredient.font = UIFont(name: "SFProText-Bold", size: 13)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeTestCellTableViewCell") as! RecipeTestCellTableViewCell
            let obj = recipeDetailDataObj.arrRecipeSteps["\(indexPath.row + 1)"]
            cell.lblIndex.text = "\(indexPath.row + 1)"
            cell.lblRecipeData.text = "\(obj!)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let height = cell.frame.size.height
        
        if tableView == tblRecipeIngrediment {
            self.hightRecipeIngTbl.constant += height
            tblRecipeIngrediment.isScrollEnabled = false
        } else if tableView == tblDescriptionDetail {
            self.heightDescriptionDetailTbl.constant += height
            tblDescriptionDetail.isScrollEnabled = false
        }
        
        if hightMainView.constant > 618 {
            self.scrollView.isScrollEnabled = true
        } else {
            self.scrollView.isScrollEnabled = false
        }
        lblSubTitle.sizeToFit()
        hightTopView.constant = (lblTitle.frame.height + lblSubTitle.frame.height + hightRecipeIngTbl.constant + heightDescriptionDetailTbl.constant)

    }
}