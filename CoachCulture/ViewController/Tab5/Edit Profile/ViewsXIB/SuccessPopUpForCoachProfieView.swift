//
//  SuccessPopUpForCoachProfieView.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 04/12/21.
//

import UIKit

class SuccessPopUpForCoachProfieView: UIView {

    internal var handlerForBtnOk: (() -> Void)?


    
    public func tapToBtnOK(_ handler: @escaping () -> Void)
    {
        self.handlerForBtnOk = nil
        self.handlerForBtnOk = handler
    }
        
    
    @IBAction func clickToBtnOK() {
        
        if handlerForBtnOk != nil
        {
            handlerForBtnOk!()
        }
        
    }

}
