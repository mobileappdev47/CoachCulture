//
//  ClassDuration.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 07/12/21.
//

import UIKit

class ClassDuration: UIView {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerData = [String]()
    
    internal var handlerForBtnSelectDuration: ((String) -> Void)?
    var currentInd = 0
    
    public func tapToBtnSelectItem(_ handler: @escaping ( _ obj : String) -> Void)
    {
        self.handlerForBtnSelectDuration = nil
        self.handlerForBtnSelectDuration = handler
    }
    
    override func awakeFromNib() {
        
        var count = 0
        for _ in 1...24 {
            count += 5
            pickerData.append("\(count)")
        }
        
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        pickerView.reloadAllComponents()
    }
    
    @IBAction func clickToBtnSelect(_ sender : UIButton) {
        if handlerForBtnSelectDuration != nil
        {
            handlerForBtnSelectDuration!(pickerData[currentInd])
            self.removeFromSuperview()
            
            
        }
    }
    
}


extension ClassDuration: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentInd = row
    }
    
}
