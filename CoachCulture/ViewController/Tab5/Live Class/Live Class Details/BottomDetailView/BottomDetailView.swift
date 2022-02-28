//
//  BottomDetailView.swift
//  CoachCulture
//
//  Created by Brainbinary Infotech on 26/02/22.
//

import UIKit

class BottomDetailView: UIView {

    //MARK:-  OUTLATE
    @IBOutlet weak var lblTItle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    
    @IBOutlet weak var viwCalary: UIView!
    @IBOutlet weak var viewDuration: UIView!
    
    @IBOutlet weak var tblEqupment: UITableView!
    
    
    @IBOutlet weak var lblCalary: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    
    @IBOutlet weak var btnOk: UIButton!
    
    @IBOutlet weak var heightEqupmentTbl: NSLayoutConstraint!
    
    var classDetailDataObj = ClassDetailData()
    
    //MARK:- VIEW CONTROLLER LIFE CYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
    }
    
    //MARK:- OTHER FUNCTION
    func setUpUI() {
        tblEqupment.register(UINib(nibName: "LiveClassEquipmentItemTableViewCell", bundle: nil), forCellReuseIdentifier: "LiveClassEquipmentItemTableViewCell")
        tblEqupment.delegate = self
        tblEqupment.dataSource = self
        tblEqupment.layoutIfNeeded()
        tblEqupment.reloadData()
        
        viwCalary.applyBorder(4.0, borderColor: hexStringToUIColor(hex: "#CC2936"))
        viewDuration.applyBorder(4.0, borderColor: hexStringToUIColor(hex: "#1A82F6"))
        
    }
    
    func setData(title : String, SubTitle : String, calary: String, duration: String, Data : ClassDetailData) { lblCalary.text = calary
        lblDuration.text = duration
        lblTItle.text = title
        lblSubTitle.text = SubTitle
        classDetailDataObj = Data
    }
    
    //MARK:- ACTION
    @IBAction func didTapOk(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
}

//MARK:- UITABLEVIEW DATASOURCE AND DELEGATE
extension BottomDetailView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classDetailDataObj.arrEquipmentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveClassEquipmentItemTableViewCell", for: indexPath) as! LiveClassEquipmentItemTableViewCell
        
        let obj = classDetailDataObj.arrEquipmentList[indexPath.row]
        cell.lblTitle.text = obj.equipment_name
        cell.ledingCell.constant = 50
        cell.trelingCell.constant = 50
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let height = cell.frame.size.height
        if heightEqupmentTbl.constant > 180 {
            tblEqupment.isScrollEnabled = true
        }
        self.heightEqupmentTbl.constant += height
        lblSubTitle.sizeToFit()
        
    }
}
