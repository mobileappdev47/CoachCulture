//
//  CancelSubScription.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 30/12/21.
//

import UIKit

class CancelSubScription: UIView {

    @IBOutlet weak var lblSubUser: UILabel!
    @IBOutlet weak var lblEndDate: UILabel!
    
    
    internal var handlerForBtnYes: (() -> Void)?
    internal var handlerForBtnNo: (() -> Void)?

    
    public func tapToBtnYes(_ handler: @escaping () -> Void)
    {
        self.handlerForBtnYes = nil
        self.handlerForBtnYes = handler
    }
    
    public func tapToBtnNo(_ handler: @escaping () -> Void)
    {
        self.handlerForBtnNo = nil
        self.handlerForBtnNo = handler
    }
    
    
    @IBAction func clickToBtnYes() {
        
        if handlerForBtnYes != nil
        {
            handlerForBtnYes!()
        }
        
    }
    
    @IBAction func clickToBtnNo() {
        if handlerForBtnNo != nil
        {
            handlerForBtnNo!()
        }
    }

}
