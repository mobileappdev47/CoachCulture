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
    
    @IBOutlet weak var btnOk: UIButton!
    
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
        
        return cell
    }
    
}
